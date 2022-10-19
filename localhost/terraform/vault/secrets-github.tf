resource "vault_generic_secret" "ci_secrets" {
  path = "secret/ci-secrets"

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
  path = "secret/atlantis"

  data_json = jsonencode(
  {
	ARGOCD_AUTH_USERNAME = "admin",
	ARGOCD_INSECURE = "false",
	ARGOCD_SERVER = "argocd.local.k3d:443",
	ARGO_SERVER_URL = "argo.local.k3d:443", # todo is this port correct
	ATLANTIS_GH_HOSTNAME = "github.com",
	ATLANTIS_GH_TOKEN = var.github_token,
	ATLANTIS_GH_USER = "",
	ATLANTIS_GH_WEBHOOK_SECRET = var.atlantis_repo_webhook_secret,
	GITHUB_OWNER = "your-dns-io",
	GITHUB_TOKEN = var.github_token,
	TF_VAR_atlantis_repo_webhook_secret = var.atlantis_repo_webhook_secret,
	TF_VAR_email_address = var.email_address,
	TF_VAR_github_token = var.github_token,
	TF_VAR_kubefirst_bot_ssh_public_key = var.kubefirst_bot_ssh_public_key,
	TF_VAR_ssh_private_key = var.ssh_private_key
	TF_VAR_vault_addr = var.vault_addr,
	TF_VAR_vault_token = var.vault_token,
	VAULT_ADDR = "https://vault.local.k3d",
	VAULT_TOKEN = var.vault_token,
}
)
}
