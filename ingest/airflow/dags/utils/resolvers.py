import os 

def resolve_bucket_config(params=None, **context):
    if params is None:
        params = context.get("params") or {}

    project_id = params.get("project_id") or os.getenv("GCP_PROJECT_ID")
    bucket_name = params.get("bucket_name") or os.getenv("GCP_GCS_BUCKET")
    dataset_id = params.get("dataset_id") or os.getenv("GCP_BQ_DATASET")
    
    if not project_id:
        raise ValueError("Missing project_id: Provide it via Airflow params or the 'GCP_PROJECT_ID' environment variable.")
        
    if not bucket_name:
        raise ValueError("Missing bucket_name: Provide it via Airflow params or the 'GCP_GCS_BUCKET' environment variable.")
    
    return {
        "project_id": project_id,
        "bucket_name": bucket_name,
        "dataset_id": dataset_id,
    }