terraform {
  backend "s3" {
    bucket   = "<KUBEFIRST_STATE_STORE_BUCKET>"
    key      = "terraform/vultr/terraform.tfstate"
    endpoint = "<KUBEFIRST_STATE_STORE_BUCKET_HOSTNAME>"

    // Don't change this.
    // https://www.vultr.com/docs/how-to-store-terraform-state-in-vultr-object-storage/
    region = "us-east-1"

    skip_credentials_validation = true
    skip_metadata_api_check     = true
    skip_region_validation      = true
    force_path_style            = true
  }
  required_providers {
    vultr = {
      source = "vultr/vultr"
    }
  }
}

provider "vultr" {
  region = "<CLOUD_REGION>"
}

locals {
  cluster_name         = "<CLUSTER_NAME>"
  kube_config_filename = "../../../kubeconfig"
}

resource "vultr_kubernetes" "kubefirst" {
  label   = local.cluster_name
  version = "v1.23.5+1"

  node_pools {
    node_quantity = 1
    plan          = "vc2-2c-4gb"
    label         = "my-label"
    auto_scaler   = true
    min_nodes     = 4
    max_nodes     = 4
  }
}

resource "local_file" "kubeconfig" {
  content  = vultr_kubernetes.kubefirst.kube_config
  filename = local.kube_config_filename
}
