from datetime import datetime
from airflow import DAG
from airflow.providers.google.cloud.transfers.local_to_gcs import LocalFilesystemToGCSOperator

from utils.resolvers import resolve_bucket_config

with DAG(
    dag_id="refresh_schema_gcs",
    start_date=datetime(2020, 1, 1),
    schedule=None,
    catchup=False,
    params={
        "bucket_name": None,
    },
    user_defined_macros={
        "get_config": resolve_bucket_config,
    }
) as dag:
    
    bucket_name_resolved = "{{ get_config('sublime-seat-484418-h6', 'airflow_datazoomcap_project_bucket', params)['bucket_name'] }}"
    
    upload_schema_to_gcs = LocalFilesystemToGCSOperator(
        task_id="upload_schema_to_gcs",
        bucket=bucket_name_resolved,
        src="/opt/airflow/dags/schemas/raw_orders.json", 
        dst="schemas/raw_orders.json",
    )
    