output "kubeconfig" {
  value     = module.k3s.kube_config
  sensitive = true
}
