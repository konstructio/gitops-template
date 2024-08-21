terraform {
  required_providers {
    gitlab = {
      source  = "gitlabhq/gitlab"
      version = "3.20.0"
    }
  }
}

resource "vault_identity_oidc_key" "key" {
  name               = "kubefirst"
  algorithm          = "RS256"
  allowed_client_ids = ["*"] # todo make explicit list of client ids
  verification_ttl   = 2500  # 41min
}

resource "vault_identity_oidc_provider" "kubefirst" {
  name          = "kubefirst"
  https_enabled = true
  issuer_host   = "vault.<DOMAIN_NAME>"
  allowed_client_ids = [
    "*" # todo make explicit list of client ids
  ]
  scopes_supported = [
    vault_identity_oidc_scope.group_scope.name,
    vault_identity_oidc_scope.user_scope.name,
    vault_identity_oidc_scope.email_scope.name,
    vault_identity_oidc_scope.profile_scope.name
  ]
}
