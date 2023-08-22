resource "random_string" "uniqueness" {
  length           = 5
  special          = false
  lower            = true

  lifecycle {
    ignore_changes = [
      length,
      lower,
    ]
  }
}

module "vault_keys" {
  source = "./modules/kms"

  keyring  = "vault-${local.cluster_name}-${lower(random_string.uniqueness.result)}"
  keys     = ["vault-unseal", "vault-encrypt"]
  location = "global"
  project  = var.project
}
