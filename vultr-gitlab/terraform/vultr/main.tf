terraform {
  backend "s3" {
    endpoint ="https://<CLOUD_REGION>.vultrobjects.com"
    key      = "terraform/vultr/terraform.tfstate"
    endpoint = ""https://<CLOUD_REGION>.vultrobjects.com""

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

provider "vultr" {}

locals {
  cluster_name         = "<CLUSTER_NAME>"
  pool_name            = "${local.cluster_name}-node-pool"
  pool_instance_type   = "vc2-4c-8gb"
  kube_config_filename = "../../../kubeconfig"
  kubernetes_version   = "v1.26.5+1"
}

resource "vultr_kubernetes" "kubefirst" {
  region  = "<CLOUD_REGION>"
  label   = local.cluster_name
  version = local.kubernetes_version

  node_pools {
    node_quantity = 3
    plan          = local.pool_instance_type
    label         = local.pool_name
    auto_scaler   = true
    min_nodes     = 3
    max_nodes     = 5
  }
}

resource "local_file" "kubeconfig" {
  content  = base64decode(vultr_kubernetes.kubefirst.kube_config)
  filename = local.kube_config_filename
}
