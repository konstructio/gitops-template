terraform {
  backend "s3" {
    bucket = "<KUBEFIRST_STATE_STORE_BUCKET>"
    key     = "terraform/civo/tfstate.tf"
    endpoint = "https://objectstore.<CLOUD_REGION>.civo.com"

    region = "<CLOUD_REGION>"

    skip_credentials_validation = true
    skip_metadata_api_check = true
    skip_region_validation = true
    force_path_style = true
  }
  required_providers {
    civo = {
      source = "civo/civo"
    }
  }
}

# export CIVO_TOKEN=$MYTOKEN is set 
provider "civo" {
  region = "<CLOUD_REGION>"
}

locals {
  cluster_name = "<CLUSTER_NAME>"
}

resource "civo_network" "kubefirst" {
    label = local.cluster_name
}

resource "civo_firewall" "kubefirst" {
  name       = local.cluster_name
  network_id = civo_network.kubefirst.id
  create_default_rules = true
}

resource "civo_kubernetes_cluster" "kubefirst" {
    name = local.cluster_name
    network_id = civo_network.kubefirst.id
    firewall_id = civo_firewall.kubefirst.id
    pools {
        label = local.cluster_name
        size = "g4s.kube.medium"
        node_count = 5
    }
}

resource "local_file" "kubeconfig" {
    content  = civo_kubernetes_cluster.kubefirst.kubeconfig
    filename = "../../../kubeconfig"
}

