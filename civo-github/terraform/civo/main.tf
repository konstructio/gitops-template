terraform {
  required_providers {
    civo = {
      source = "civo/civo"
    }
  }
}

# export CIVO_TOKEN=$MYTOKEN is set 
provider "civo" {
  region = "NYC1"
}

locals {
  cluster_name = "bugfix-cluster-test"
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