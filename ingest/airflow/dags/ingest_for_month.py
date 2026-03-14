from airflow import DAG
from airflow.operators.python import PythonOperator
from datetime import datetime

import zipfile
import tempfile

import os

import requests
from google.cloud import storage

from utils.resolvers import resolve_bucket_name, resolve_project_id

import io
import shutil
import tempfile

DEFAULT_GCS_PREFIX = "historical"
    
def fetch_and_upload(year: str, month: str, gcs_prefix=None, **context):
    print("month:", month)
    print("year:", year)
    
    params = context.get("params") or {}

    project_id = resolve_project_id(
        project_id_env=os.getenv("GCP_PROJECT_ID"), 
        project_id_default="sublime-seat-484418-h6",
    )
    
    bucket_name = resolve_bucket_name(
        project_id=project_id,
        bucket_override=params.get("bucket_name"),
        bucket_env=os.getenv("GCP_GCS_BUCKET"),
        bucket_default="airflow_datazoomcap_project_bucket",
    )                 
    
    month_formatted = month.lstrip("0")
    url = f"https://transparenciachc.blob.core.windows.net/oc-da/{year}-{month_formatted}.zip"
    object_name = f"{gcs_prefix}/year={year}/month={int(month):02d}/data.csv"

    print(f"Fetching data from {url}...")
    with requests.get(url, stream=True, timeout=(10, 300)) as r:
        r.raise_for_status()

        print("Buffering ZIP to temp file...")
        with tempfile.NamedTemporaryFile(suffix=".zip", delete=False) as tmp_zip:
            tmp_zip_path = tmp_zip.name
            for chunk in r.iter_content(chunk_size=8 * 1024 * 1024):
                tmp_zip.write(chunk)
    try:
        print("Extracting CSV from ZIP...")
        with zipfile.ZipFile(tmp_zip_path) as zf:
            csv_filename = f"{year}-{month_formatted}.csv"

            if csv_filename not in zf.namelist():
                raise FileNotFoundError(
                    f"Expected '{csv_filename}' inside ZIP, found: {zf.namelist()}"
                )

            print("Converting encoding and buffering to a temporary CSV file...")
            # 1. Open the temp file in text mode ('w') and use 'utf-8-sig'. 
            # This automatically handles adding the BOM and encodes the text properly.
            with tempfile.NamedTemporaryFile(suffix=".csv", delete=False, mode="w", encoding="utf-8-sig", newline="") as tmp_csv:
                tmp_csv_path = tmp_csv.name

                with zf.open(csv_filename) as raw_csv_file:
                    # 2. Wrap the raw binary zip byte-stream.
                    # We use 'b' (Excel's standard Latin encoding) 
                    # and errors='replace' to prevent crashes from stray bad bytes.
                    with io.TextIOWrapper(raw_csv_file, encoding="windows-1252", errors="replace") as text_csv_file:
                        # 3. Safely stream the file without manual chunk boundaries.
                        shutil.copyfileobj(text_csv_file, tmp_csv)

        print("Uploading converted CSV to GCS...")
        client = storage.Client()
        bucket = client.bucket(bucket_name)
        blob = bucket.blob(object_name)

        blob.content_type = "text/csv"
        blob.chunk_size = 8 * 1024 * 1024
        
        # 4. Open the finalized temp file in binary mode for the upload
        with open(tmp_csv_path, "rb") as final_csv:
            blob.upload_from_file(final_csv, rewind=False, timeout=600)

    finally: # cleanup two files
        if os.path.exists(tmp_zip_path):
            os.remove(tmp_zip_path)
        if 'tmp_csv_path' in locals() and os.path.exists(tmp_csv_path):
            os.remove(tmp_csv_path)


    print(f"Uploaded {url} -> gs://{bucket_name}/{object_name}")
    
    
with DAG(
    dag_id="historical_ingest_for_month",
    start_date=datetime(2020, 1, 1),
    schedule="@monthly",
    catchup=False,
    params={
        "gcs_prefix": DEFAULT_GCS_PREFIX,
        "project_id": None,
        "bucket_name": None,
    },
) as dag:

    task_fetch_data = PythonOperator(
        task_id="fetch_and_upload_to_gcs",
        python_callable=fetch_and_upload,
        op_kwargs={
            "year": "{{ logical_date.year }}",
            "month": "{{ logical_date.month }}",
            "gcs_prefix": "{{ params.gcs_prefix }}"
        }
    )