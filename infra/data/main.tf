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
  force_destroy = true 
}

resource "google_bigquery_dataset" "datawarehouse_raw_layer" {
  dataset_id                 = "${var.bq_dataset_id}_raw"
  location                   = var.data_location
  delete_contents_on_destroy = true
}
resource "google_bigquery_dataset" "datawarehouse_prod_layer" {
  dataset_id                 = "${var.bq_dataset_id}_prd"
  location                   = var.data_location
  delete_contents_on_destroy = true
}
resource "google_bigquery_dataset" "datawarehouse_dev_layer" {
  dataset_id                 = "${var.bq_dataset_id}_dev" 
  location                   = var.data_location
  delete_contents_on_destroy = true
}

resource "google_storage_bucket_object" "raw_orders_schema" {
  name   = "schemas/raw_orders.json"
  source = "${path.module}/../../ingest/airflow/dags/schemas/raw_orders.json"
  bucket = google_storage_bucket.data_lake.name
}