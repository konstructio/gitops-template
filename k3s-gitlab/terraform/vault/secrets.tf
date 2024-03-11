resource "vault_generic_secret" "atlantis_ngrok_secrets" {
  path = "secret/atlantis-ngrok"

  data_json = jsonencode(
    {
      GIT_PROVIDER   = "<GIT_PROVIDER>",
      GIT_OWNER      = "<GITHUB_OWNER>",
      GIT_TOKEN      = var.gitlab_token,
      GIT_REPOSITORY = "gitops",
    }
  )

  depends_on = [vault_mount.secret]
}

resource "random_password" "chartmuseum_password" {
  length           = 22
  special          = true
  override_special = "!#$"
}

resource "vault_generic_secret" "chartmuseum_secrets" {
  path = "secret/chartmuseum"

  data_json = jsonencode(
    {
      AWS_ACCESS_KEY_ID     = var.aws_access_key_id,
      AWS_SECRET_ACCESS_KEY = var.aws_secret_access_key,
      BASIC_AUTH_USER       = "kbot",
      BASIC_AUTH_PASS       = random_password.chartmuseum_password.result,
    }
  )

  depends_on = [vault_mount.secret]
}

resource "vault_generic_secret" "docker_config" {
  path = "secret/dockerconfigjson"

  data_json = jsonencode(
    {
      dockerconfig = jsonencode({ "auths" : { "registry.gitlab.com" : { "username" : "container-registry-auth", "password" : "${var.container_registry_auth}", "email" : "kbot@example.com", "auth" : "${var.b64_docker_auth}" } } }),
    }
  )

  depends_on = [vault_mount.secret]
}

resource "vault_generic_secret" "container_registry_auth" {
  path = "secret/deploy-tokens/container-registry-auth"

  data_json = jsonencode(
    {
      auth = jsonencode({ "auths" : { "registry.gitlab.com" : { "username" : "container-registry-auth", "password" : "${var.container_registry_auth}", "email" : "kbo@example.com", "auth" : "${var.b64_docker_auth}" } } }),
    }
  )

  depends_on = [vault_mount.secret]
}

resource "vault_generic_secret" "minio_creds" {
  path = "secret/minio"

  data_json = jsonencode(
    {
      accesskey = var.aws_access_key_id,
      secretkey = var.aws_secret_access_key,
    }
  )

  depends_on = [vault_mount.secret]
}

resource "vault_generic_secret" "external_secrets_token" {
  path = "secret/external-secrets-store"

  data_json = jsonencode(
    {
      token = var.vault_token
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
      accesskey             = var.aws_access_key_id,
      secretkey             = var.aws_secret_access_key,
      BASIC_AUTH_USER       = "kbot",
      BASIC_AUTH_PASS       = random_password.chartmuseum_password.result,
      SSH_PRIVATE_KEY       = var.kbot_ssh_private_key,
      PERSONAL_ACCESS_TOKEN = var.gitlab_token
      username              = "gitlabpat"
      password              = var.gitlab_token
    }
  )

  depends_on = [vault_mount.secret]
}

resource "vault_generic_secret" "atlantis_secrets" {
  path = "secret/atlantis"

  data_json = jsonencode(
    {
      ARGO_SERVER_URL                     = "argo.argo.svc.cluster.local:2746",
      ATLANTIS_GITLAB_HOSTNAME            = "gitlab.com",
      ATLANTIS_GITLAB_TOKEN               = var.gitlab_token,
      ATLANTIS_GITLAB_USER                = "<GITLAB_USER>",
      ATLANTIS_GITLAB_WEBHOOK_SECRET      = var.atlantis_repo_webhook_secret,
      GITLAB_OWNER                        = "<GITLAB_OWNER>",
      GITLAB_TOKEN                        = var.gitlab_token,
      TF_VAR_atlantis_repo_webhook_secret = var.atlantis_repo_webhook_secret,
      TF_VAR_aws_access_key_id            = var.aws_access_key_id,
      TF_VAR_aws_secret_access_key        = var.aws_secret_access_key,
      TF_VAR_b64_docker_auth              = var.b64_docker_auth,
      TF_VAR_gitlab_token                 = var.gitlab_token,
      TF_VAR_container_registry_auth      = var.container_registry_auth,
      TF_VAR_kbot_ssh_public_key          = var.kbot_ssh_public_key,
      TF_VAR_kbot_ssh_private_key         = var.kbot_ssh_private_key,
      TF_VAR_kubernetes_api_endpoint      = var.kubernetes_api_endpoint,
      TF_VAR_owner_group_id               = "<GITLAB_OWNER_GROUP_ID>"
      TF_VAR_vault_addr                   = "http://vault.vault.svc.cluster.local:8200",
      TF_VAR_vault_token                  = var.vault_token,
      VAULT_ADDR                          = "http://vault.vault.svc.cluster.local:8200",
      VAULT_TOKEN                         = var.vault_token,
    }
  )

  depends_on = [vault_mount.secret]
}
