resource "vault_generic_secret" "chartmuseum_secrets" {
  path = "secret/chartmuseum"

  # todo need to fix this user and password to be sensitive
  data_json = jsonencode(
    {
      BASIC_AUTH_USER       = "k-ray",
      BASIC_AUTH_PASS       = "feedkraystars",
      AWS_ACCESS_KEY_ID     = var.aws_access_key_id,
      AWS_SECRET_ACCESS_KEY = var.aws_secret_access_key,
    }
  )

  depends_on = [vault_mount.secret]
}

resource "vault_generic_secret" "external_dns_secrets" {
  path = "secret/external-dns"

  data_json = jsonencode(
    {
      civo-token = var.civo_token,
    }
  )

  depends_on = [vault_mount.secret]
}

resource "vault_generic_secret" "civo_creds" {
  path = "secret/argo"

  data_json = jsonencode(
    {
      accesskey = var.aws_access_key_id,
      secretkey = var.aws_secret_access_key,
    }
  )

  depends_on = [vault_mount.secret]
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

  depends_on = [vault_mount.secret]
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

  depends_on = [vault_mount.secret]
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

  depends_on = [vault_mount.secret]
}

resource "vault_generic_secret" "ci_secrets" {
  path = "secret/ci-secrets"

  data_json = jsonencode(
    {
      accesskey       = var.aws_access_key_id,
      secretkey       = var.aws_secret_access_key,
      BASIC_AUTH_USER = "k-ray",
      BASIC_AUTH_PASS = "feedkraystars",
      SSH_PRIVATE_KEY = var.kbot_ssh_private_key,
    }
  )

  depends_on = [vault_mount.secret]
}

resource "vault_generic_secret" "atlantis_secrets" {
  path = "secret/atlantis"

  data_json = jsonencode(
    {
      ARGO_SERVER_URL                     = "argo.argo.svc.cluster.local:2746",
      ATLANTIS_GH_HOSTNAME                = "github.com",
      ATLANTIS_GH_TOKEN                   = var.github_token,
      ATLANTIS_GH_USER                    = "<GITHUB_USER>",
      ATLANTIS_GH_WEBHOOK_SECRET          = var.atlantis_repo_webhook_secret,
      TF_VAR_atlantis_repo_webhook_secret = var.atlantis_repo_webhook_secret,
      TF_VAR_atlantis_repo_webhook_url    = var.atlantis_repo_webhook_url,
      AWS_ACCESS_KEY_ID                   = var.aws_access_key_id,
      AWS_SECRET_ACCESS_KEY               = var.aws_secret_access_key,
      TF_VAR_aws_access_key_id            = var.aws_access_key_id,
      TF_VAR_aws_secret_access_key        = var.aws_secret_access_key,
      CIVO_TOKEN                          = var.civo_token,
      TF_VAR_civo_token                   = var.civo_token,
      GITHUB_OWNER                        = "<GITHUB_OWNER>",
      GITHUB_TOKEN                        = var.github_token,
      TF_VAR_github_token                 = var.github_token,
      TF_VAR_kbot_ssh_public_key          = var.kbot_ssh_public_key,
      TF_VAR_kbot_ssh_private_key         = var.kbot_ssh_private_key,
      VAULT_ADDR                          = "http://vault.vault.svc.cluster.local:8200",
      TF_VAR_vault_addr                   = "http://vault.vault.svc.cluster.local:8200",
      VAULT_TOKEN                         = var.vault_token,
      TF_VAR_vault_token                  = var.vault_token,
    }
  )

  depends_on = [vault_mount.secret]
}
