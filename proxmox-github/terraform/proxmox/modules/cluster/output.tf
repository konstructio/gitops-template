resource "talos_cluster_kubeconfig" "this" {
  client_configuration = talos_machine_secrets.this.client_configuration
  node                 = local.endpoints[0]
  depends_on           = [talos_machine_bootstrap.controlplane]
}

output "kubeconfig" {
  value = talos_cluster_kubeconfig.this.kubeconfig_raw
}

resource "local_file" "kubeconfig" {
  filename = "kubeconfig"
  content  = "Kubeconfig ${talos_cluster_kubeconfig.this.kubeconfig_raw}"
}
