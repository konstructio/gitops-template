module "argo" {
  source = "./modules/oidc-client"

  depends_on = [
    vault_identity_oidc_provider.kubefirst
  ]

  app_name               = "argo"
  identity_group_ids     = [vault_identity_group.admins.id, vault_identity_group.developers.id]
  oidc_provider_key_name = vault_identity_oidc_key.key.name
  redirect_uris = [
    "https://argo.do.kuberfu.com/oauth2/callback",
  ]
  secret_mount_path = "secret"
}

module "argocd" {
  source = "./modules/oidc-client"

  depends_on = [
    vault_identity_oidc_provider.kubefirst
  ]

  app_name               = "argocd"
  identity_group_ids     = [vault_identity_group.admins.id, vault_identity_group.developers.id]
  oidc_provider_key_name = vault_identity_oidc_key.key.name
  redirect_uris = [
    "https://argocd.do.kuberfu.com/auth/callback",
  ]
  secret_mount_path = "secret"
}

module "console" {
  source = "./modules/oidc-client"

  depends_on = [
    vault_identity_oidc_provider.kubefirst
  ]

  app_name               = "console"
  identity_group_ids     = [vault_identity_group.admins.id, vault_identity_group.developers.id]
  oidc_provider_key_name = vault_identity_oidc_key.key.name
  redirect_uris = [
    "https://vouch.do.kuberfu.com/auth",
  ]
  secret_mount_path = "secret"
}

# todo kubectl-oidc
