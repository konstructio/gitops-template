locals {
  l_servers_public_ips      = length(var.list_servers_public_ips) != 0 ? var.list_servers_public_ips : var.list_servers_private_ips
  l_tls_san_from_public_ips = length(var.list_servers_public_ips) != 0 ? ["--tls-san ${join(",", [for item in var.list_servers_public_ips : format("%s", item)])}"] : []
}
module "k3s" {
  source  = "xunleii/k3s/module"
  version = "3.4.0"
  # cluster_domain = "kubefirst.local"
  k3s_version = "v1.28.4+k3s1"

  drain_timeout = "30s"

  # managed_fields = ["labels", "taints"]
  managed_fields = []

  servers = {
    # The node name will be automatically provided by
    # the module using the field name... any usage of
    # --node-name in additional_flags will be ignored
    for idx, ip in var.list_servers_private_ips : "k1-master-${idx + 1}" => {
      ip = ip // internal node IP
      connection = {
        user        = var.ssh_user
        private_key = file(var.ssh_private_key)
        host        = local.l_servers_public_ips[idx]
      },
      flags = local.l_tls_san_from_public_ips != [] ? concat(var.servers_args, local.l_tls_san_from_public_ips, ["--node-external-ip ${local.l_servers_public_ips[idx]}"]) : var.servers_args
    }
  }
  # INFO:kubefirst k3s agents is postpone, but not dropped
  # that why we left the block, and let you use this base if you need for you stuff
  agents = var.list_agents_ips != [] ? {
    for idx, ip in var.list_agents_ips : "k1-agent-${idx + 1}" => {
      ip = ip
      connection = {
        user        = var.ssh_user
        private_key = var.ssh_private_key
      },
    }
  } : {}
}

locals {
  kubeconfig           = module.k3s.kube_config
  kube_config_filename = "../../../kubeconfig"
}

resource "local_file" "kubeconfig" {
  depends_on = [module.k3s]
  content    = local.kubeconfig
  filename   = local.kube_config_filename
}
