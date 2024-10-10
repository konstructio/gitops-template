output "kubeconfig" {
  value = civo_kubernetes_cluster.kubefirst.kubeconfig
}

output "api_endpoint" {
  value = civo_kubernetes_cluster.kubefirst.api_endpoint
}