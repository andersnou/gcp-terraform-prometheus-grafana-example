terraform {
  required_providers {
    google = {
      source = "hashicorp/google"
      version = "3.52.0"
    }
    kubernetes = {
      source = "hashicorp/kubernetes"
      version = ">= 2.0.1"
    }
  }
}

data "terraform_remote_state" "gke" {
  backend = "local"

  config = {
    path = "../terraform.tfstate"
  }
}

provider "google" {
  project = data.terraform_remote_state.gke.outputs.project_id
  region  = data.terraform_remote_state.gke.outputs.region
}

data "google_client_config" "default" {}

data "google_container_cluster" "my_cluster" {
  name     = data.terraform_remote_state.gke.outputs.kubernetes_cluster_name
  location = data.terraform_remote_state.gke.outputs.zone
}

provider "kubernetes" {
  host = data.terraform_remote_state.gke.outputs.kubernetes_cluster_host

  token                  = data.google_client_config.default.access_token
  cluster_ca_certificate = base64decode(data.google_container_cluster.my_cluster.master_auth[0].cluster_ca_certificate)
}

resource "kubernetes_namespace" "monitor" {
  metadata {
    name = "monitor"
  }
}
