resource "random_password" "chartmuseum_user_password" {
  length           = 16
  special          = true
  override_special = "!@"
}

resource "vault_generic_secret" "chartmuseum_secrets" {
  path = "secret/chartmuseum"

  data_json = <<EOT
{
  "BASIC_AUTH_USER" : "admin",
  "BASIC_AUTH_PASS" : "${random_password.chartmuseum_user_password.result}"
}
EOT
}

resource "vault_generic_secret" "development_metaphor" {
  path = "secret/development/metaphor"
  # note: these secrets are not actually sensitive.
  # do not hardcode passwords in git under normal circumstances.
  data_json = <<EOT
{
  "SECRET_ONE" : "development secret 1",
  "SECRET_TWO" : "development secret 2"
}
EOT
}

resource "vault_generic_secret" "staging_metaphor" {
  path = "secret/staging/metaphor"
  # note: these secrets are not actually sensitive.
  # do not hardcode passwords in git under normal circumstances.
  data_json = <<EOT
{
  "SECRET_ONE" : "staging secret 1",
  "SECRET_TWO" : "staging secret 2"
}
EOT
}

resource "vault_generic_secret" "production_metaphor" {
  path = "secret/production/metaphor"
  # note: these secrets are not actually sensitive.
  # do not hardcode passwords in git under normal circumstances.
  data_json = <<EOT
{
  "SECRET_ONE" : "production secret 1",
  "SECRET_TWO" : "production secret 2"
}
EOT
}
