terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
}

resource "google_storage_bucket" "data_lake" {
  name          = var.gcs_bucket_name
  location      = var.data_location
  force_destroy = false 
}

resource "google_bigquery_dataset" "data_warehouse" {
  dataset_id                 = var.bq_dataset_id
  location                   = var.data_location
  delete_contents_on_destroy = false
}

resource "google_storage_bucket_object" "raw_orders_schema" {
  name   = "schemas/raw_orders.json"
  source = "${path.module}/../../ingest/airflow/dags/schemas/raw_orders.json"
  bucket = google_storage_bucket.data_lake.name
}