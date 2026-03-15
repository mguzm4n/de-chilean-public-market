

# Introduction

This project will follow the processes of an ELT pipeline. That is, we will follow the steps of extract, load and transform our data. 

# Core technologies

In this project, the main cloud provider will be the Google Cloud Platform, using the free available credits on the creation of a new account.

Since we will use the ELT strategy, we need a place to load all of our data. We will use Google Cloud Storage, specifically GCP Buckets, that will be our datalake, that is, the place were we will be dumping data of different types, in this case, CSV and JSON files for schemas.

The transformations of our data will occur inside of our data warehouse. BigQuery, from GCP, is a widely used columnar database. That is, it doesn't store data at a row level with all its columns, like a traditional SQL database, but groups the columns instead. So, querying specific columns is really fsat. And you should never do a SELECT *.

# Infrastructure

The core infrastructure is set up with terraform files. We will need a bucket for the lake and a bigquery dataset created for the warehouse. More importantly, we will need to spin up a server (VM) to hold our Airflow UI. This VM will be the compute resource that will run our DAGs.

In order to start the project, you should locate the `compute` and `data` folders under the `infra` directory. 
1. `data`: This terraform script will provide the data sources infrastructure needed to run our projects. Run this script first.
2. `compute`: This terraform script will create a service account, create a VM to run Airflow, and land safely the environment variables into the VM.

## Checking the VM

Since I will be using GCP, I downloaded the gcloud CLI to not handle risky credential files. Use this approach and avoid using credential files locally.


1. To SSH into the VM do: `gcloud compute ssh airflow-server-vm --zone=<zone> --project=<project_id>`
2. Check Airflow service is up and running: Use `docker ps` and `tail -f  my-docker-compose.log`. You should see all services with "Healthy" tags.
3. To run DAGs with backfill options, use the Web UI server, forwarding the remote port to your local machine:

If using unix based OS:

```
gcloud compute ssh airflow-server-vm \
    --zone=<zone> \
    --project=<project_id> \
    -- -L 8080:localhost:8080
```

Powershell:

```
gcloud compute ssh airflow-server-vm --zone=<zone> --project=<project_id> --ssh-flag="-L 8080:localhost:8080"
```
## Managing the VM

Using the GCP CLI:

1. Shut down: `gcloud compute instances stop airflow-server-vm --zone=<zone>`
2. Boot up: `gcloud compute instances start airflow-server-vm --zone=<zone>`

# Ingest of data

The ingesting pipeline is only for historical data, that is, the data will be uploaded in batches, in a monthly schedule. In order to fill the data, ssh into the VM as we did in earlier steps, and run:

```
docker compose exec -e AIRFLOW__CORE__MAX_ACTIVE_RUNS_PER_DAG=4 airflow-scheduler airflow dags backfill -s 2024-02-01 -e 2024-12-01 historical_ingest_gcs_to_bq_for_month 
```

You can choose any range of dates. The DAG will first fetch the data from the official API and store it, raw, in GCS Buckets. Then, it will move the data from the buckets and land them, as one big table, inside bigquery- still raw data but merged for all months.

# Modelling

# Transformations

Since I'm using dbt, you should install it locally and setup the connections with BigQuery/GCP. 

## Managing dbt

1. `dbt run --select <model>`: Run a single model. 
2. `dbt run`: Run all models.
3. `dbt build`: Run models, tests, seeds, etc.
4. `dbt build --select <prefix><model><suffix>`: 
    - Upstream: Use "+" as a prefix to build every model <model> depends on, back to the source.
    - Downstream: Use "+" as a suffix to build downstream dependencies.

# Dashboard 
