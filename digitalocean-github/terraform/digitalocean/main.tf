terraform {
  backend "s3" {
    endpoint = "<KUBEFIRST_STATE_STORE_BUCKET_HOSTNAME>"
    key      = "terraform/digitalocean/terraform.tfstate"
    bucket   = "<KUBEFIRST_STATE_STORE_BUCKET>"
    // Don't change this.
    region = "us-east-1"

    skip_credentials_validation = true
    skip_metadata_api_check     = true
  }
  required_providers {
    digitalocean = {
      source  = "digitalocean/digitalocean"
      version = "~> 2.0"
    }
  }
}

variable "do_token" {
  type = string
}

provider "digitalocean" {
  token = var.do_token
}

locals {
  cluster_name         = "<CLUSTER_NAME>"
  pool_name            = "${local.cluster_name}-node-pool"
  pool_instance_size   = "s-4vcpu-8gb"
  kube_config_filename = "../../../kubeconfig"
  kubernetes_version   = "1.26.3-do.0"
}

resource "digitalocean_kubernetes_cluster" "kubefirst" {
  name    = local.cluster_name
  region  = "<CLOUD_REGION>"
  version = local.kubernetes_version

  node_pool {
    name       = local.pool_name
    size       = local.pool_instance_size
    node_count = 3
  }
}

resource "local_file" "kubeconfig" {
  content  = digitalocean_kubernetes_cluster.kubefirst.kube_config.0.raw_config
  filename = local.kube_config_filename
}
