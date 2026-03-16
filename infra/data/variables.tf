variable "project_id" {
  description = "The Google Cloud Project ID"
  type        = string
}

variable "region" {
  description = "The default compute region"
  type        = string
  default     = "southamerica-west1"
}

variable "gcs_bucket_name" {
  description = "The name of the BigQuery dataset"
  type        = string
}

variable "data_location" {
  description = "The location for BigQuery and Cloud Storage"
  type        = string
  default     = "southamerica-west1"
}

variable "bq_dataset_id" {
  description = "The name of the BigQuery dataset"
  type        = string
}