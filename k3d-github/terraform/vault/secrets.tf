resource "vault_generic_secret" "atlantis_ngrok_secrets" {
  path = "${vault_mount.secret.path}/atlantis-ngrok"

  data_json = jsonencode(
    {
      GIT_PROVIDER    = "<GIT_PROVIDER>",
      GIT_OWNER       = "<GITHUB_OWNER>",
      GIT_TOKEN       = var.github_token,
      GIT_REPOSITORY  = "gitops",
      NGROK_AUTHTOKEN = var.ngrok_authtoken,
    }
  )
}

resource "random_password" "chartmuseum_password" {
  length           = 22
  special          = true
  override_special = "!#$"
}

resource "vault_generic_secret" "chartmuseum_secrets" {
  path = "${vault_mount.secret.path}/chartmuseum"

  data_json = jsonencode(
    {
      AWS_ACCESS_KEY_ID     = var.aws_access_key_id,
      AWS_SECRET_ACCESS_KEY = var.aws_secret_access_key,
      BASIC_AUTH_USER       = "kbot",
      BASIC_AUTH_PASS       = random_password.chartmuseum_password.result,
    }
  )
}

resource "vault_generic_secret" "crossplane" {
  path = "${vault_mount.secret.path}/crossplane"

  data_json = jsonencode(
    {
      AWS_ACCESS_KEY_ID     = var.aws_access_key_id,
      AWS_SECRET_ACCESS_KEY = var.aws_secret_access_key,
      VAULT_ADDR            = "http://vault.vault.svc.cluster.local:8200"
      VAULT_TOKEN           = var.vault_token
      password              = var.github_token
      username              = "<GITHUB_USER>"
    }
  )
}

resource "vault_generic_secret" "docker_config" {
  path = "${vault_mount.secret.path}/dockerconfigjson"

  data_json = jsonencode(
    {
      dockerconfig = jsonencode({ "auths" : { "ghcr.io" : { "auth" : "${var.b64_docker_auth}" } } }),
    }
  )
}

resource "vault_generic_secret" "regsitry_auth" {
  path = "${vault_mount.secret.path}/registry-auth"

  data_json = jsonencode(
    {
      auth = jsonencode({ "auths" : { "ghcr.io" : { "auth" : "${var.b64_docker_auth}" } } }),
    }
  )
}

resource "vault_generic_secret" "minio_creds" {
  path = "${vault_mount.secret.path}/minio"

  data_json = jsonencode(
    {
      accesskey = var.aws_access_key_id,
      secretkey = var.aws_secret_access_key,
    }
  )
}

resource "vault_generic_secret" "external_secrets_token" {
  path = "${vault_mount.secret.path}/external-secrets-store"

  data_json = jsonencode(
    {
      token = var.vault_token
    }
  )
}

resource "vault_generic_secret" "metaphor" {
  for_each = toset(["development", "staging", "production"])

  path = "${vault_mount.secret.path}/${each.key}/metaphor"
  # note: these secrets are not actually sensitive.
  # do not hardcode passwords in git under normal circumstances.
  data_json = jsonencode(
    {
      SECRET_ONE = "${each.key} secret 1"
      SECRET_TWO = "${each.key} secret 2"
    }
  )
}

resource "vault_generic_secret" "ci_secrets" {
  path = "${vault_mount.secret.path}/ci-secrets"

  data_json = jsonencode(
    {
      accesskey             = var.aws_access_key_id,
      secretkey             = var.aws_secret_access_key,
      BASIC_AUTH_USER       = "kbot",
      BASIC_AUTH_PASS       = random_password.chartmuseum_password.result,
      SSH_PRIVATE_KEY       = var.kbot_ssh_private_key,
      PERSONAL_ACCESS_TOKEN = var.github_token,
    }
  )
}

resource "vault_generic_secret" "atlantis_secrets" {
  path = "${vault_mount.secret.path}/atlantis"

  data_json = jsonencode(
    {
      ARGO_SERVER_URL                     = "argo.argo.svc.cluster.local:2746",
      ATLANTIS_GH_HOSTNAME                = "github.com",
      ATLANTIS_GH_TOKEN                   = var.github_token,
      ATLANTIS_GH_USER                    = "<GITHUB_OWNER>",
      ATLANTIS_GH_WEBHOOK_SECRET          = var.atlantis_repo_webhook_secret,
      GITHUB_OWNER                        = "<GITHUB_OWNER>",
      GITHUB_TOKEN                        = var.github_token,
      TF_VAR_atlantis_repo_webhook_secret = var.atlantis_repo_webhook_secret,
      TF_VAR_aws_access_key_id            = var.aws_access_key_id,
      TF_VAR_aws_secret_access_key        = var.aws_secret_access_key,
      TF_VAR_b64_docker_auth              = var.b64_docker_auth,
      TF_VAR_github_token                 = var.github_token,
      TF_VAR_kbot_ssh_public_key          = var.kbot_ssh_public_key,
      TF_VAR_kbot_ssh_private_key         = var.kbot_ssh_private_key,
      TF_VAR_kubernetes_api_endpoint      = var.kubernetes_api_endpoint,
      TF_VAR_ngrok_authtoken              = var.ngrok_authtoken,
      TF_VAR_vault_addr                   = "http://vault.vault.svc.cluster.local:8200",
      TF_VAR_vault_token                  = var.vault_token,
      VAULT_ADDR                          = "http://vault.vault.svc.cluster.local:8200",
      VAULT_TOKEN                         = var.vault_token,
    }
  )
}
