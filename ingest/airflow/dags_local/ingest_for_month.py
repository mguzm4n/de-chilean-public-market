from airflow import DAG
from airflow.providers.standard.operators.python import PythonOperator
from datetime import datetime

import os

import requests
from google.cloud import storage

DEFAULT_GCS_PREFIX = "historical"

def _resolve_bucket_name(
    *,
    project_id: str, 
    bucket_override: str | None,
    bucket_env: str | None, 
    bucket_default: str = "",
) -> str: 
    bucket_suffix = bucket_override or bucket_env or bucket_default
    return f"{project_id}-{bucket_suffix}"    
    
def fetch_and_upload(year, month, gcs_prefix=None, **context):
    params = context.get("params") or {}
    
    env_project_id = os.getenv("GCP_PROJECT_ID")
    project_id = env_project_id or "sublime-seat-484418-h6"
    
    bucket_override = params.get("bucket_name")
    bucket_env = os.getenv("GCP_GCS_BUCKET")
    bucket_name = _resolve_bucket_name(
        project_id=project_id,
        bucket_override=bucket_override,
        bucket_env=bucket_env,
        bucket_default="airflow_datazoomcap_project_bucket",
    )                 
    
    url = f"https://api.example.com/data/{year}/{month}"
    object_name = f"{gcs_prefix}/year={year}/month={int(month):02d}/data.csv"

    print(f"Fetching data from {url}...")

    with requests.get(url, stream=True, timeout=(10, 300)) as r:
        r.raise_for_status()

        client = storage.Client()
        bucket = client.bucket(bucket_name)
        blob = bucket.blob(object_name)

        blob.content_type = r.headers.get("Content-Type", "text/csv")
        blob.chunk_size = 8 * 1024 * 1024  # 8 MiB
        r.raw.decode_content = True
        
        blob.upload_from_file(r.raw, rewind=False, timeout=600)

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
            "month": "{{ logical_date.month }}"
        }
    )