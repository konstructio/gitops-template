resource "vault_identity_oidc_scope" "group_scope" {
  name        = "groups"
  template    = <<EOF
{
  "groups": {{identity.entity.groups.names}}
}
EOF
  description = "Groups scope."
}

resource "vault_identity_oidc_scope" "user_scope" {
  name        = "user"
  template    = <<EOF
{
    "username": {{identity.entity.aliases.${vault_auth_backend.userpass.accessor}.name}},
    "contact": {
        "email": {{identity.entity.metadata.email}}
    }
}
EOF
  description = "User scope."
}

resource "vault_identity_oidc_scope" "email_scope" {
  name        = "email"
  template    = <<EOF
{
  "email": {{identity.entity.metadata.email}}
}
EOF
  description = "Email scope."
}

resource "vault_identity_oidc_scope" "profile_scope" {
  name        = "profile"
  template    = <<EOF
{
  "profile": {{identity.entity.metadata.email}}
}
EOF
  description = "Profile scope."
}
