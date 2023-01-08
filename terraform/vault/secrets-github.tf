resource "vault_generic_secret" "ci_secrets" {
  path = "${vault_mount.secret.path}/ci-secrets"

  data_json = jsonencode(
    {
      BASIC_AUTH_USER = "admin",
      BASIC_AUTH_PASS = random_password.chartmuseum_user_password.result,
      USERNAME = "kubefirst",
      PERSONAL_ACCESS_TOKEN = var.github_token,
      SSH_PRIVATE_KEY = var.ssh_private_key,
    }
  )
}

resource "vault_generic_secret" "atlantis_secrets" {
  path = "${vault_mount.secret.path}/atlantis"

  data_json = jsonencode(
  {
	ARGOCD_AUTH_USERNAME = "admin",
	ARGOCD_INSECURE = "false",
	ARGOCD_SERVER = "argocd.<AWS_HOSTED_ZONE_NAME>:443",
	ARGO_SERVER_URL = "argo.<AWS_HOSTED_ZONE_NAME>:443",
	ATLANTIS_GH_HOSTNAME = "<GITHUB_HOST>",
	ATLANTIS_GH_TOKEN = var.github_token,
	ATLANTIS_GH_USER = "<GITHUB_USER>",
	ATLANTIS_GH_WEBHOOK_SECRET = var.atlantis_repo_webhook_secret,
	AWS_DEFAULT_REGION = "<AWS_DEFAULT_REGION>",
	AWS_ROLE_TO_ASSUME = "arn:aws:iam::<AWS_ACCOUNT_ID>:role/KubernetesAdmin",
	AWS_SESSION_NAME = "GitHubAction",
	GITHUB_OWNER = "<GITHUB_OWNER>",
	GITHUB_TOKEN = var.github_token,
	KUBECONFIG = "/.kube/config",
	TF_VAR_atlantis_repo_webhook_secret = var.atlantis_repo_webhook_secret,
	TF_VAR_aws_account_id = "<AWS_ACCOUNT_ID>",
	TF_VAR_aws_region = "<AWS_DEFAULT_REGION>",
	TF_VAR_email_address = var.email_address,
	TF_VAR_github_token = var.github_token,
	TF_VAR_hosted_zone_id = var.hosted_zone_id,
	TF_VAR_hosted_zone_name = var.hosted_zone_name,
	TF_VAR_kubefirst_bot_ssh_public_key = var.kubefirst_bot_ssh_public_key,
	TF_VAR_ssh_private_key = var.ssh_private_key
	TF_VAR_vault_addr = var.vault_addr,
	TF_VAR_vault_token = var.vault_token,
	TF_VAR_ami_type = var.ami_type,
	TF_VAR_instance_type = var.instance_type,
	VAULT_ADDR = "https://vault.<AWS_HOSTED_ZONE_NAME>",
	VAULT_TOKEN = var.vault_token,
}
)
}
