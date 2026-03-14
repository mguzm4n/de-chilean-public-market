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
  zone    = var.zone
}

data "google_storage_bucket" "data_lake" {
  name = var.gcs_bucket_name
}

data "google_bigquery_dataset" "data_warehouse" {
  project = var.project_id
  dataset_id = var.bq_dataset_id
}

resource "google_service_account" "airflow_vm_sa" {
  account_id   = "airflow-runtime-sa"
  display_name = "Airflow VM Runtime Service Account"
}

resource "google_project_iam_member" "sa_bigquery_editor" {
  project = var.project_id
  role    = "roles/bigquery.dataEditor"
  member  = "serviceAccount:${google_service_account.airflow_vm_sa.email}"
}

resource "google_project_iam_member" "sa_storage_admin" {
  project = var.project_id
  role    = "roles/storage.objectAdmin"
  member  = "serviceAccount:${google_service_account.airflow_vm_sa.email}"
}

resource "google_compute_instance" "airflow_server" {
  name         = "airflow-server-vm"
  machine_type = "e2-medium" # recommended for Airflow/Docker
  zone         = "us-central1-a"

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-12"
      size  = 30 # GB
    }
  }

  network_interface {
    network = "default"
    access_config {
      # gives the VM an external public IP to access the Airflow UI
    }
  }

  # attach s.a.
  service_account {
    email  = google_service_account.airflow_vm_sa.email
    scopes = ["cloud-platform"]
  }

  metadata_startup_script = file("${path.module}/startup.sh")
}