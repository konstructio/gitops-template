module "vault_keys" {
  source = "./modules/kms"

  keyring  = "vault-${local.cluster_name}"
  keys     = ["vault-unseal", "vault-encrypt"]
  location = "global"
  project  = var.project
}
