resource "vault_identity_oidc" "this" {
  issuer = "https://vault.<DOMAIN_NAME>"
}

resource "vault_identity_oidc_key" "federated" {
  name      = "federated"
  algorithm = "RS256"
}

resource "vault_identity_oidc_role" "federated" {
  name = "federated"
  key  = vault_identity_oidc_key.federated.id
  # This is temporary
  client_id = "kubefirst.konstruct.io/federated"
  ttl       = 3600
  template  = <<EOT
  {
  "kubernetes.io": {
    "serviceaccount": {
      "name": {{identity.entity.aliases.${vault_auth_backend.k8s.accessor}.metadata.service_account_name}},
       "namespace": {{identity.entity.aliases.${vault_auth_backend.k8s.accessor}.metadata.service_account_namespace}},
       "uid": {{identity.entity.aliases.${vault_auth_backend.k8s.accessor}.metadata.service_account_uid}}
      }
    }
  }
EOT
}

resource "vault_identity_oidc_key_allowed_client_id" "role" {
  key_name          = vault_identity_oidc_key.federated.name
  allowed_client_id = vault_identity_oidc_role.federated.client_id
}
