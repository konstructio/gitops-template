module "civo_kubernetes_cluster" {
  source         = "${path.module}/../civo-cluster"
  cluster_name   = var.cluster_name
  cluster_region = var.cluster_region
  environment    = var.environment
  node_count     = var.node_count
  node_type      = var.node_type
  cluster_type   = var.cluster_type
  labels = {
    "nvidia.com/gpu.deploy.operator-validator" = "false"
  }
  mgmt_cluster_id = "<CLUSTER_ID>"
}


// TODO Fix: I don't like the idea we are configuring the provider here and inside the module

provider "kubernetes" {
  host                   = module.civo_kubernetes_cluster.api_endpoint
  client_certificate     = base64decode(yamldecode(module.civo_kubernetes_cluster.kubeconfig).users[0].user.client-certificate-data)
  client_key             = base64decode(yamldecode(module.civo_kubernetes_cluster.kubeconfig).users[0].user.client-key-data)
  cluster_ca_certificate = base64decode(yamldecode(module.civo_kubernetes_cluster.kubeconfig).clusters[0].cluster.certificate-authority-data)
}

provider "helm" {
  repository_config_path = "${path.module}/.helm/repositories.yaml"
  repository_cache       = "${path.module}/.helm"
  kubernetes {
    host                   = module.civo_kubernetes_cluster.api_endpoint
    client_certificate     = base64decode(yamldecode(module.civo_kubernetes_cluster.kubeconfig).users[0].user.client-certificate-data)
    client_key             = base64decode(yamldecode(module.civo_kubernetes_cluster.kubeconfig).users[0].user.client-key-data)
    cluster_ca_certificate = base64decode(yamldecode(module.civo_kubernetes_cluster.kubeconfig).clusters[0].cluster.certificate-authority-data)
  }
}