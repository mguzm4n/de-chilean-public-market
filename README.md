

# Introduction

This project will follow the processes of an ELT pipeline. That is, we will follow the steps of extract, load and transform our data. 

# Core technologies

In this project, the main cloud provider will be the Google Cloud Platform, using the free available credits on the creation of a new account.

Since we will use the ELT strategy, we need a place to load all of our data. We will use Google Cloud Storage, specifically GCP Buckets, that will be our datalake, that is, the place were we will be dumping data of different types, in this case, CSV and JSON files for schemas.

The transformations of our data will occur inside of our data warehouse. BigQuery, from GCP, is a widely used columnar database. That is, it doesn't store data at a row level with all its columns, like a traditional SQL database, but groups the columns instead. So, querying specific columns is really fsat. And you should never do a SELECT *.

# Infrastructure

The core infrastructure is set up with terraform files. We will need a bucket for the lake and a bigquery dataset created for the warehouse. More importantly, we will need to spin up a server (VM) to hold our project.

There are two ways to manage the infrastructure, locally, through the creation of a service account with a key to manage resources or assigning directly a service account to a Virtual Machine (VM) that will run the entire project.

# Ingest of data

# Transformations

# Modelling
