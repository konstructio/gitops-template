module "argo" {
  source = "./modules/oidc-client"

  depends_on = [
    vault_identity_oidc_provider.kubefirst
  ]

  app_name               = "argo"
  oidc_provider_key_name = vault_identity_oidc_key.key.name
  redirect_uris = [
    "https://argo.<AWS_HOSTED_ZONE_NAME>/oauth2/callback",
  ]
  secret_mount_path = vault_mount.secret.path
}

module "argocd" {
  source = "./modules/oidc-client"

  depends_on = [
    vault_identity_oidc_provider.kubefirst
  ]

  app_name               = "argocd"
  oidc_provider_key_name = vault_identity_oidc_key.key.name
  redirect_uris = [
    "<ARGOCD_INGRESS_URL>/auth/callback",
  ]
  secret_mount_path = vault_mount.secret.path
}

module "gitlab" {
  source = "./modules/oidc-client"

  depends_on = [
    vault_identity_oidc_provider.kubefirst
  ]

  app_name               = "gitlab"
  oidc_provider_key_name = vault_identity_oidc_key.key.name
  redirect_uris = [
    "https://gitlab.<AWS_HOSTED_ZONE_NAME>/users/auth/openid_connect/callback",
  ]
  secret_mount_path = vault_mount.secret.path
}

module "console" {
  source = "./modules/oidc-client"

  depends_on = [
    vault_identity_oidc_provider.kubefirst
  ]

  app_name               = "console"
  oidc_provider_key_name = vault_identity_oidc_key.key.name
  redirect_uris = [
    "https://vouch.<AWS_HOSTED_ZONE_NAME>/auth",
  ]
  secret_mount_path = vault_mount.secret.path
}

# todo kubectl-oidc
