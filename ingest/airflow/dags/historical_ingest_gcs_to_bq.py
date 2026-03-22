from airflow import DAG
from airflow.operators.python import PythonOperator
from airflow.operators.bash import BashOperator
from airflow.providers.google.cloud.transfers.gcs_to_bigquery import GCSToBigQueryOperator
from datetime import datetime


from utils.resolvers import resolve_bucket_config
from utils.fetch_and_upload import fetch_and_upload


DEFAULT_GCS_PREFIX = "historical"
   
with DAG(
    dag_id="historical_ingest_gcs_to_bq_for_month",
    start_date=datetime(2020, 1, 1),
    schedule="@monthly",
    catchup=False,
    params={
        "gcs_prefix": DEFAULT_GCS_PREFIX,
        "project_id": None,
        "bucket_name": None,
        "dataset_id": None,
    },
    user_defined_macros={
        "get_config": resolve_bucket_config,
    }
) as dag:
    
    bucket_name_resolved = "{{ get_config(params)['bucket_name'] }}"

    task_fetch_data = PythonOperator(
        task_id="fetch_and_upload_to_gcs",
        python_callable=fetch_and_upload,
        op_kwargs={
            "year": "{{ logical_date.year }}",
            "month": "{{ logical_date.month }}",
            "gcs_prefix": "{{ params.gcs_prefix }}",
            "bucket_name": bucket_name_resolved,
        },
    )
    
    load_historical_data_to_bq = GCSToBigQueryOperator(
        task_id='task_historical_gcs_to_bq',
        bucket=bucket_name_resolved,
        
        schema_object="schemas/raw_orders.json",
        schema_update_options=['ALLOW_FIELD_ADDITION', 'ALLOW_FIELD_RELAXATION'],
        
        source_objects=[
            "{{ params.gcs_prefix }}/year={{ logical_date.year }}/month={{ logical_date.strftime('%m') }}/data.csv"
        ], 
        destination_project_dataset_table=(
            "{{ get_config(params)['project_id'] }}"
            ".{{ get_config(params)['dataset_id'] }}_raw.raw_orders${{ logical_date.strftime('%Y%m') }}"
        ),

        write_disposition='WRITE_TRUNCATE', 
        source_format='CSV',
        field_delimiter=';',
        skip_leading_rows=1,
        allow_quoted_newlines=True,
        
        time_partitioning={
            "type": "MONTH" 
        },
        
        autodetect=False,
    )
    
    dbt_build_models = BashOperator(
        task_id="dbt_build_models",
        bash_command=(
            "/opt/airflow/dbt_venv/bin/dbt build "
            "--project-dir /opt/airflow/dbt_project "
            "--profiles-dir /opt/airflow/dbt_project "
            "--target-path /tmp/dbt/target "
            "--target prod "
            "--log-path /tmp/dbt/logs "
            "--vars '{\"logical_date\": \"{{ logical_date.strftime(\"%Y-%m-%d\") }}\", \"year\": \"{{ logical_date.year }}\", \"month\": \"{{ logical_date.month }}\"}' "
            "2>&1"
        )
    )
    
    task_fetch_data >> load_historical_data_to_bq >> dbt_build_models