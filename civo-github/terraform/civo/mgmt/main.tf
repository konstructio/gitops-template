terraform {
  backend "s3" {
    bucket   = "k1-state-store-feedkray-one-mp-rah8um"
    key      = "registry/test-new-tf/infrastructure/provider-config/terraform.tfstate"
    endpoint = "https://objectstore.LON1.civo.com"

    region = "LON1"

    skip_credentials_validation = true
    skip_metadata_api_check     = true
    skip_region_validation      = true
    force_path_style            = true
  }
  required_providers {
    civo = {
      source = "civo/civo"
    }
    kubernetes = {
      source = "hashicorp/kubernetes"
      version = "2.23.0"
    }
    vault = {
      source = "hashicorp/vault"
      version = "3.19.0"
    }
  }
}
provider "civo" {
  region = "LON1"
}

locals {
  cluster_name         = "test-new-tf"
  kube_config_filename = "../../../kubeconfig"
}

resource "civo_network" "kubefirst" {
  label = local.cluster_name
}

resource "civo_firewall" "kubefirst" {
  name                 = local.cluster_name
  network_id           = civo_network.kubefirst.id
  create_default_rules = true
}

resource "civo_kubernetes_cluster" "kubefirst" {
  name        = local.cluster_name
  network_id  = civo_network.kubefirst.id
  firewall_id = civo_firewall.kubefirst.id
  pools {
    label      = local.cluster_name
    size       = "g4s.kube.medium"
    node_count = 4
  }
}

resource "vault_generic_secret" "clusters" {
  path = "secret/clusters/${local.cluster_name}"

  data_json = jsonencode(
    {
      kubeconfig              = civo_kubernetes_cluster.kubefirst.kubeconfig
      client_certificate      = base64decode(yamldecode(civo_kubernetes_cluster.kubefirst.kubeconfig).users[0].user.client-certificate-data)
      client_key              = base64decode(yamldecode(civo_kubernetes_cluster.kubefirst.kubeconfig).users[0].user.client-key-data)
      cluster_ca_certificate  = base64decode(yamldecode(civo_kubernetes_cluster.kubefirst.kubeconfig).clusters[0].cluster.certificate-authority-data)
      host                    = data.civo_kubernetes_cluster.workload_cluster.api_endpoint
      cluster_name            = local.cluster_name
    }
  )
}

provider "kubernetes" {
  host = "https://cloud-blue.feedkray.one"

  client_certificate     = base64decode(yamldecode(data.kubernetes_secret_v1.vcluster_kubeconfig.data.config).users[0].user.client-certificate-data)
  client_key             = base64decode(yamldecode(data.kubernetes_secret_v1.vcluster_kubeconfig.data.config).users[0].user.client-key-data)
  cluster_ca_certificate = base64decode(yamldecode(data.kubernetes_secret_v1.vcluster_kubeconfig.data.config).clusters[0].cluster.certificate-authority-data)
}

resource "kubernetes_namespace_v1" "external_dns" {
  metadata {
    name = "external-dns"
  }
}

data "vault_generic_secret" "external_dns" {
  path = "secret/external-dns"
}

resource "kubernetes_secret_v1" "external_dns" {
  metadata {
    name = "civo-creds"
    namespace = kubernetes_namespace_v1.external_dns.metadata.0.name
  }
  data = {
    civo-token = var.civo_token 
    cf-api-token = var.cloudflare_token 
  }
  type = "Opaque"
}


resource "kubernetes_namespace_v1" "external_secrets_operator" {
  metadata {
    name = "external-secrets-operator"
  }
}

resource "kubernetes_service_account_v1" "external_secrets" {
  metadata {
    name = "external-secrets"
    namespace = kubernetes_namespace_v1.external_secrets_operator.metadata.0.name
  }
  secret {
    name = "external-secrets-token"
  }
}

resource "kubernetes_secret_v1" "external_secrets" {
  metadata {
    name = "external-secrets-token"
    namespace = kubernetes_namespace_v1.external_secrets_operator.metadata.0.name
    annotations = {
      "kubernetes.io/service-account.name" = "external-secrets"
    }
  }
  type = "kubernetes.io/service-account-token"
  depends_on = [ kubernetes_service_account_v1.external_secrets ]
}
