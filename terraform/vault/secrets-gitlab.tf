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

  data_json = jsonencode(
    {
      BASIC_AUTH_USER       = "admin",
      BASIC_AUTH_PASS       = random_password.chartmuseum_user_password.result,
      USERNAME              = "kubefirst",
      PERSONAL_ACCESS_TOKEN = var.gitlab_token,
      SSH_PRIVATE_KEY       = var.ssh_private_key,
    }
  )
}

resource "vault_generic_secret" "atlantis_secrets" {
  path = "${vault_mount.secret.path}/atlantis"

  data_json = jsonencode(
    {
      ARGOCD_AUTH_USERNAME       = "admin",
      ARGOCD_INSECURE            = "false",
      ARGOCD_SERVER              = "argocd.<AWS_HOSTED_ZONE_NAME>:443",
      ARGO_SERVER_URL            = "argo.<AWS_HOSTED_ZONE_NAME>:443",
      ATLANTIS_GITLAB_HOSTNAME   = "gitlab.<AWS_HOSTED_ZONE_NAME>",
      ATLANTIS_GITLAB_USER       = "root",
      AWS_DEFAULT_REGION         = "<AWS_DEFAULT_REGION>",
      AWS_ROLE_TO_ASSUME         = "arn:aws:iam::<AWS_ACCOUNT_ID>:role/KubernetesAdmin",
      AWS_SESSION_NAME           = "GitHubAction",
      GITLAB_BASE_URL            = "https://gitlab.<AWS_HOSTED_ZONE_NAME>",
      GITLAB_TOKEN               = var.gitlab_token,
      ATLANTIS_GITLAB_TOKEN      = var.gitlab_token,
      KUBECONFIG                 = "/.kube/config",
      TF_VAR_aws_account_id      = "<AWS_ACCOUNT_ID>",
      TF_VAR_aws_region          = "<AWS_DEFAULT_REGION>",
      TF_VAR_email_address       = var.email_address,
      TF_VAR_gitlab_runner_token = var.gitlab_runner_token,
      TF_VAR_gitlab_token        = var.gitlab_token,
      TF_VAR_gitlab_url          = "gitlab.<AWS_HOSTED_ZONE_NAME>",
      TF_VAR_hosted_zone_id      = var.hosted_zone_id,
      TF_VAR_hosted_zone_name    = var.hosted_zone_name,
      TF_VAR_ssh_private_key     = var.ssh_private_key,
      TF_VAR_vault_addr          = var.vault_addr,
      TF_VAR_vault_token         = var.vault_token,
      VAULT_ADDR                 = "https://vault.<AWS_HOSTED_ZONE_NAME>",
      VAULT_TOKEN                = var.vault_token,
    }
  )
}
