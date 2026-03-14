
import zipfile
import tempfile

import os

import requests

import io
import shutil
import tempfile


from google.cloud import storage

def fetch_and_upload(year: str, month: str, gcs_prefix: str, bucket_name: str, **context):
    print("month:", month)
    print("year:", year)
    
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