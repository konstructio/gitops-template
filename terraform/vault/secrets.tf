locals {
  secrets_github = <<EOT
  {
	  "atlantis": {
  		"ARGOCD_AUTH_USERNAME": "admin",
  		"ARGOCD_INSECURE": "false",
  		"ARGOCD_SERVER": "argocd.<AWS_HOSTED_ZONE_NAME>:443",
  		"ARGO_SERVER_URL": "argo.<AWS_HOSTED_ZONE_NAME>:443",
  		"ATLANTIS_GH_HOSTNAME": "<GITHUB_HOST>",
  		"ATLANTIS_GH_TOKEN": "${var.github_token}",
  		"ATLANTIS_GH_USER": "<GITHUB_USER>",
      		"ATLANTIS_GH_WEBHOOK_SECRET":  "${var.atlantis_repo_webhook_secret}",
  		"GITHUB_TOKEN": "${var.github_token}",
  		"GITHUB_OWNER": "<GITHUB_OWNER>",
  		"AWS_DEFAULT_REGION": "<AWS_DEFAULT_REGION>",
  		"AWS_ROLE_TO_ASSUME": "arn:aws:iam::<AWS_ACCOUNT_ID>:role/KubernetesAdmin",
  		"AWS_SESSION_NAME": "GitHubAction",
  		"KUBECONFIG": "/.kube/config",
  		"VAULT_ADDR": "https://vault.<AWS_HOSTED_ZONE_NAME>",
  		"VAULT_TOKEN": "${var.vault_token}",
      		"TF_VAR_kubefirst_bot_ssh_public_key": "${var.kubefirst_bot_ssh_public_key}",
      		"TF_VAR_atlantis_repo_webhook_secret": "${var.atlantis_repo_webhook_secret}",
  		"TF_VAR_aws_account_id": "<AWS_ACCOUNT_ID>",
  		"TF_VAR_aws_region": "<AWS_DEFAULT_REGION>",
  		"TF_VAR_email_address": "${var.email_address}",
  		"TF_VAR_hosted_zone_id": "${var.hosted_zone_id}",
  		"TF_VAR_hosted_zone_name": "${var.hosted_zone_name}",
  		"TF_VAR_vault_addr": "${var.vault_addr}",
  		"TF_VAR_vault_token": "${var.vault_token}"
  	}
}
EOT
  secrets_gitlab = <<EOT
  {
    "atlantis": {
      "ARGOCD_AUTH_USERNAME": "admin",
      "ARGOCD_INSECURE": "false",
      "ARGOCD_SERVER": "argocd.<AWS_HOSTED_ZONE_NAME>:443",
      "ARGO_SERVER_URL": "argo.<AWS_HOSTED_ZONE_NAME>:443",
      "ATLANTIS_GITLAB_HOSTNAME": "gitlab.<AWS_HOSTED_ZONE_NAME>",
      "ATLANTIS_GITLAB_USER": "root",
      "AWS_DEFAULT_REGION": "<AWS_DEFAULT_REGION>",
      "AWS_ROLE_TO_ASSUME": "arn:aws:iam::<AWS_ACCOUNT_ID>:role/KubernetesAdmin",
      "AWS_SESSION_NAME": "GitHubAction",
      "GITLAB_BASE_URL": "https://gitlab.<AWS_HOSTED_ZONE_NAME>",
      "GITLAB_TOKEN": "${var.gitlab_token}",
      "ATLANTIS_GITLAB_TOKEN": "${var.gitlab_token}",
      "KUBECONFIG": "/.kube/config",
      "TF_VAR_aws_account_id": "<AWS_ACCOUNT_ID>",
      "TF_VAR_aws_region": "<AWS_DEFAULT_REGION>",
      "TF_VAR_email_address": "${var.email_address}",
      "TF_VAR_gitlab_runner_token": "${var.gitlab_runner_token}",
      "TF_VAR_gitlab_token": "${var.gitlab_token}",
      "TF_VAR_gitlab_url": "gitlab.<AWS_HOSTED_ZONE_NAME>",
      "TF_VAR_hosted_zone_id": "${var.hosted_zone_id}",
      "TF_VAR_hosted_zone_name": "${var.hosted_zone_name}",
      "TF_VAR_vault_addr": "${var.vault_addr}",
      "TF_VAR_vault_token": "${var.vault_token}",
      "VAULT_ADDR": "https://vault.<AWS_HOSTED_ZONE_NAME>",
      "VAULT_TOKEN": "${var.vault_token}"
    }
  }
EOT
}

resource "random_password" "chartmuseum_user_password" {
  length           = 16
  special          = true
  override_special = "!@"
}

resource "vault_generic_secret" "chartmuseum_secrets" {
  path = "${vault_mount.secret.path}/chartmuseum"

  data_json = <<EOT
{
  "BASIC_AUTH_USER" : "admin",
  "BASIC_AUTH_PASS" : "${random_password.chartmuseum_user_password.result}"
}
EOT
}

resource "vault_generic_secret" "gitlab_runner_secrets" {
  path = "${vault_mount.secret.path}/gitlab-runner"

  data_json = <<EOT
{
  "RUNNER_REGISTRATION_TOKEN": "${var.gitlab_runner_token}",
  "RUNNER_TOKEN": ""
}
EOT
}

resource "vault_generic_secret" "ci_secrets" {
  path = "${vault_mount.secret.path}/ci-secrets"

  data_json = <<EOT
{
  "BASIC_AUTH_USER" : "admin",
  "BASIC_AUTH_PASS" : "${random_password.chartmuseum_user_password.result}",
  "USERNAME" : "kubefirst",
  "PERSONAL_ACCESS_TOKEN" : "${var.gitlab_token}",
  "SSH_PRIVATE_KEY": "${var.ssh_private_key}"
}
EOT
}

resource "vault_generic_secret" "atlantis_secrets" {
  path = "${vault_mount.secret.path}/atlantis"

  data_json = var.git_provider == "github" ? local.secrets_github : local.secrets_gitlab
}

resource "vault_generic_secret" "development_metaphor" {
  path = "${vault_mount.secret.path}/development/metaphor"
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
  path = "${vault_mount.secret.path}/staging/metaphor"
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
  path = "${vault_mount.secret.path}/production/metaphor"
  # note: these secrets are not actually sensitive.
  # do not hardcode passwords in git under normal circumstances.
  data_json = <<EOT
{
  "SECRET_ONE" : "production secret 1",
  "SECRET_TWO" : "production secret 2"
}
EOT
}
