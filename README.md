# gcp-terraform-prometheus-grafana-example

Deploying Prometheus-Grafana stack with a provisioned Kubernetes cluster to Google Cloud Platform (GCP). Automation is with Terraform.

> :warning: Warning Google Cloud Platform charges about ten cents per hour for each **standard** Google Kubernetes Engine. However, one Zonal cluster per month should be covered by the free tier.

Zonal cluster is a cluster which zone is specified, such as `us-central1-a`. If the region is specified, such as `us-central1`, then the cluster is a regional cluster.

## Prerequisites

* [a GCP account](https://console.cloud.google.com/)
* [a configured gcloud SDK](https://cloud.google.com/sdk/docs/quickstarts)
* [kubectl](https://kubernetes.io/docs/tasks/tools/)
* a GCP project

## Quick-guide

Setup

1) Install/Setup prerequisites
2) Run `gcloud init`
3) Run `gcloud auth application-default login` and authenticate with Google
4) Replace the `project_id` value with your GCP project id and optionally the `region` and `zone` in the `terraform.tfvars` file

Running the Kubernetes cluster

1) Run `terraform init`
2) Run `terraform apply`
3) Run `gcloud container clusters get-credentials $(terraform output -raw kubernetes_cluster_name) --region $(terraform output -raw region)` to retrieve access credentials for the cluster and automatically configure kubectl

Deploy & configure Grafana & Prometheus

1) Navigate to the kubernetes folder `cd resources`
2) Run `terraform init`
3) Run `terraform apply`
4) Navigate to Grafana UI
5) Setup a datasource in Grafana to listen to Prometheus
6) Setup a dashboard in Grafana to read metrics from Prometheus

## Overview

`gke.tf` provisions a Google Kubernetes Engine (GKE) cluster.

`vpc.tf` provisions a VPC and subnet.

`terraform.tfvars` contains the variables

`versions.tf` sets the terraform version to at least 0.14.

`resources/prometheus-deploy` contains prometheus deployment code

`resources/prometheus-service` contains prometheus service code

`resources/grafana-deploy` contains grafana deployment code

`resources/grafana-service` contains grafana service code

All the resources are installed under `monitor` namespace.

### Provisioning a Kubernetes cluster 

> :warning: [Compute Engine API](https://console.cloud.google.com/apis/api/compute.googleapis.com/overview) and [Kubernetes Engine API](https://cloud.google.com/kubernetes-engine) are required for running `terraform apply`. They need to be enabled in the Google Cloud Console

Kubernetes cluster is created by running `terraform apply` in the directory. The process should take approximately 10 minutes.

### Managing Kubernetes resources with Terraform

The resources are managed in the `kubernetes.tf` file with the [Kubernetes Provider](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs).

### Grafana deployment & service

`resource "kubernetes_deployment" "grafana"` in `kubernetes.tf` will deploy Grafana. We will pull the latest grafana image (`grafana/grafana:latest`) and specify the port (`3000`) and protocol (`TCP`). In this case, we will mount an `empty_dir` volume (for persistence, a kubernetes_persistent_volume has to be created)

A Kubernetes service for the Grafana is created with `resource "kubernetes_service" "grafana_service"`. We will specify the selector to match the deployment resource name and the ports. In this case, the type is `LoadBalancer` which allows us to access the Grafana UI directly from the browser through an IP:PORT.

### Prometheus deployment & service

`resource "kubernetes_deployment" "prometheus"` in `kubernetes.tf` will deploy Prometheus. We will pull the latest Prometheus image (`prom/prometheus:latest`) and specify the port (`9090`) and protocol (`TCP`). 

A Kubernetes service for the Prometheus is created with `resource "kubernetes_service" "prometheus_service"`. We will specify the selector to match the deployment resource name and the ports. In this case, the type is `LoadBalancer` which allows us to access the Prometheus UI directly from the browser through an IP:PORT.

### Accessing Prometheus & Grafana UI

Since the service type is "LoadBalancer" then the UI's can be accessed thorugh an external IP. The IP's can be found in either he Google Cloud Console under Kubernetes Engine -> Services & Ingress OR through `kubectl` with the command `kubectl get services --namespace=monitor` (the monitor is the namespace that we installed the resources on). Access the UI through the `<EXTERNAL-IP:PORT>` 

The credentials for Grafana are:
**username**: admin
**password**: admin

### Adding a Datasource to Grafana

* On the left, "Configuration" -> "Data Sources" -> Add data source
* Type: "Prometheus"
* URL: use either the `<IP:PORT>` of the Prometheus service or `http://prometheus:9090`
* Click "Save & Test"

The process can be automated through configuration files!

### Creating a Dashboard to read metrics from Prometheus

* On the left menu, "Create" -> "Dashboard"
* "Add new panel" and fill the fields
* Data source: Prometheus
* Metrics can be any prometheus metric, for example: `prometheus_http_requests_total`
* Click Apply

### Cleanup

Run `terraform destroy` in the kubernetes folder and the main directory to clean up.


