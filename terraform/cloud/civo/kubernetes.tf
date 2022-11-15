# external-dns doesn't support civo nor does crossplane
# resource "civo_dns_domain_name" "feedkray_one" {
#   name = "feedkray.one"
# }

locals {
  cluster_name = "kubefirst-1"
}

resource "civo_network" "kubefirst" {
    label = local.cluster_name
}

resource "civo_firewall" "kubefirst" {
  name       = local.cluster_name
  network_id = civo_network.kubefirst.id
  create_default_rules = true
}

# 38bfb0c1-b40e-483f-ba7d-15d984ddd453
data "civo_size" "medium" {
    filter {
        key = "type"
        values = ["kubernetes"]
    }

    sort {
        key = "ram"
        direction = "asc"
    }
}

resource "civo_kubernetes_cluster" "kubefirst" {
    name = local.cluster_name
    network_id = civo_network.kubefirst.id
    firewall_id = civo_firewall.kubefirst.id
    pools {
        label = local.cluster_name // Optional
        size = "g4s.kube.medium" # element(data.civo_size.xsmall.sizes, 0).name
        node_count = 3
    }
}
