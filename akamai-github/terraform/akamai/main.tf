terraform {
  backend "s3" {
    bucket   = "<KUBEFIRST_STATE_STORE_BUCKET>"
    key      = "terraform/civo/terraform.tfstate"
    endpoint = "https://<CLUSTER_NAME>.us-east-1.linodeobjects.com" #! edit

    region = "us-east-1" #! edit

    skip_credentials_validation = true
    skip_metadata_api_check     = true
    skip_region_validation      = true
    force_path_style            = true
  }
  required_providers {
    linode = {
      source  = "linode/linode"
      version = "2.16.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.23.0"
    }
    vault = {
      source  = "hashicorp/vault"
      version = "3.19.0"
    }
  }
}
provider "linode" {}

locals {
  cluster_name         = "<CLUSTER_NAME>"
  kube_config_filename = "../../../kubeconfig"
}

resource "linode_lke_cluster" "kubefirst" {
  label       = local.cluster_name
  k8s_version = "1.28"
  region      = "us-central"
  tags        = ["<CLUSTER_NAME>"]

  pool {
    # NOTE: If count is undefined, the initial node count will
    # equal the minimum autoscaler node count.
    type = "<NODE_TYPE>" # "g6-standard-4" 4

    autoscaler {
      min = tonumber("<NODE_COUNT>") # tonumber() is used for a string token value
      max = tonumber("<NODE_COUNT>") # tonumber() is used for a string token value
    }
  }
}

resource "local_file" "kubeconfig" {
  content  = base64decode(linode_lke_cluster.kubefirst.kubeconfig)
  filename = local.kube_config_filename
}

