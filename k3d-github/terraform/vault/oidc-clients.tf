module "argo" {
  source = "./modules/oidc-client"

  depends_on = [
    vault_identity_oidc_provider.kubefirst
  ]

  app_name               = "argo"
  oidc_provider_key_name = vault_identity_oidc_key.key.name
  redirect_uris = [
    "https://argo.<DOMAIN_NAME>/oauth2/callback",
  ]
  secret_mount_path = "secret"
}

module "argocd" {
  source = "./modules/oidc-client"

  depends_on = [
    vault_identity_oidc_provider.kubefirst
  ]

  app_name               = "argocd"
  oidc_provider_key_name = vault_identity_oidc_key.key.name
  redirect_uris = [
    "https://argocd.<DOMAIN_NAME>/auth/callback",
  ]
  secret_mount_path = "secret"
}

module "gitlab" {
  source = "./modules/oidc-client"

  depends_on = [
    vault_identity_oidc_provider.kubefirst
  ]

  app_name               = "gitlab"
  oidc_provider_key_name = vault_identity_oidc_key.key.name
  redirect_uris = [
    "https://gitlab.<DOMAIN_NAME>/users/auth/openid_connect/callback",
  ]
  secret_mount_path = "secret"
}

module "console" {
  source = "./modules/oidc-client"

  depends_on = [
    vault_identity_oidc_provider.kubefirst
  ]

  app_name               = "console"
  oidc_provider_key_name = vault_identity_oidc_key.key.name
  redirect_uris = [
    "https://vouch.<DOMAIN_NAME>/auth",
  ]
  secret_mount_path = "secret"
}

# todo kubectl-oidc
