resource "vault_generic_secret" "chartmuseum_secrets" {
  path = "secret/chartmuseum"

  data_json = <<EOT
{
  "BASIC_AUTH_USER" : "k-ray",
  "BASIC_AUTH_PASS" : "feedkraystars",
  "AWS_ACCESS_KEY_ID" : "k-ray",
  "AWS_SECRET_ACCESS_KEY" : "feedkraystars"
}
EOT
}

resource "vault_generic_secret" "minio_creds" {
  path = "secret/minio"

  data_json = <<EOT
{
  "accesskey" : "k-ray",
  "secretkey" : "feedkraystars"
}
EOT
}

resource "vault_generic_secret" "external_secrets_token" {
  path = "secret/external-secrets-store"

  data_json = <<EOT
{
  "token" : "k1_local_vault_token"
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

data "gitlab_group" "owner" {
  group_id = var.owner_group_id
}

resource "vault_generic_secret" "gitlab_runner" {
  path      = "secret/gitlab-runner"
  data_json = <<EOT
{
  "RUNNER_TOKEN" : "",
  "RUNNER_REGISTRATION_TOKEN" : "${data.gitlab_group.owner.runners_token}"
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

resource "vault_generic_secret" "ci_secrets" {
  path = "secret/ci-secrets"

  data_json = jsonencode(
    {
      accesskey             = var.aws_access_key_id,
      secretkey             = var.aws_secret_access_key,
      BASIC_AUTH_USER       = "k-ray",
      BASIC_AUTH_PASS       = "feedkraystars",
      SSH_PRIVATE_KEY       = var.kubefirst_bot_ssh_private_key,
      PERSONAL_ACCESS_TOKEN = var.gitlab_token
      username              = "gitlabpat"
      password              = var.gitlab_token
    }
  )

  # depends_on = [vault_mount.secret] #! this will be added back in when vault is not in development mode
}

resource "vault_generic_secret" "atlantis_secrets" {
  path = "secret/atlantis"

  data_json = jsonencode(
    {
      ARGO_SERVER_URL                     = "argo.argo.svc.cluster.local:2746",
      ATLANTIS_GITLAB_HOSTNAME            = "gitlab.com",
      ATLANTIS_GITLAB_TOKEN               = var.gitlab_token,
      ATLANTIS_GITLAB_USER                = "<GITLAB_OWNER>",
      ATLANTIS_GITLAB_WEBHOOK_SECRET      = var.atlantis_repo_webhook_secret,
      GITLAB_OWNER                        = "<GITLAB_OWNER>",
      GITLAB_TOKEN                        = var.gitlab_token,
      TF_VAR_atlantis_repo_webhook_secret = var.atlantis_repo_webhook_secret,
      TF_VAR_atlantis_repo_webhook_url    = var.atlantis_repo_webhook_url,
      TF_VAR_gitlab_token                 = var.gitlab_token,
      TF_VAR_kubefirst_bot_ssh_public_key = var.kubefirst_bot_ssh_public_key,
      TF_VAR_owner_group_id               = "<GITLAB_OWNER_GROUP_ID>"
      TF_VAR_vault_addr                   = "http://vault.vault.svc.cluster.local:8200",
      TF_VAR_vault_token                  = "k1_local_vault_token",
      VAULT_ADDR                          = "http://vault.vault.svc.cluster.local:8200",
      VAULT_TOKEN                         = "k1_local_vault_token",
    }
  )
}
