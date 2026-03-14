import os 

def resolve_project_id(
    *,
    project_id_env: str | None, 
    project_id_default: str,
) -> str: 
    return project_id_env or project_id_default

def resolve_bucket_name(
    *,
    project_id: str, 
    bucket_override: str | None,
    bucket_env: str | None, 
    bucket_default: str = "",
) -> str: 
    bucket_suffix = bucket_override or bucket_env or bucket_default
    return f"{project_id}-{bucket_suffix}" 


def resolve_bucket_config(project_default, bucket_default, params=None, **context):
    if params is None:
        params = context.get("params") or {}

    project_id = resolve_project_id(
        project_id_env=os.getenv("GCP_PROJECT_ID"),
        project_id_default=project_default
    )
    
    bucket_name = resolve_bucket_name(
        project_id=project_id,
        bucket_override=params.get("bucket_name"),
        bucket_env=os.getenv("GCP_GCS_BUCKET"),
        bucket_default=bucket_default,
    )
    
    return {
        "project_id": project_id,
        "bucket_name": bucket_name
    }