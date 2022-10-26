resource "vault_generic_secret" "ci_secrets" {
  path = "secret/ci-secrets"

  data_json = jsonencode(
    {
      BASIC_AUTH_USER       = "k-ray",
      BASIC_AUTH_PASS       = "feedkraystars",
      USERNAME              = "<GITHUB_USER>",
      PERSONAL_ACCESS_TOKEN = var.github_token,
      username              = "<GITHUB_USER>",
      password              = var.github_token,
    }
  )
}

resource "vault_generic_secret" "atlantis_secrets" {
  path = "secret/atlantis"

  data_json = jsonencode(
    {
      ARGOCD_AUTH_USERNAME                = "admin",
      ARGOCD_INSECURE                     = "true",
      ARGOCD_SERVER                       = "http://localhost:8080",
      ARGO_SERVER_URL                     = "argo.argo.svc.cluster.local:2746",
      ATLANTIS_GH_HOSTNAME                = "github.com",
      ATLANTIS_GH_TOKEN                   = var.github_token,
      ATLANTIS_GH_USER                    = "<GITHUB_OWNER>",
      ATLANTIS_GH_WEBHOOK_SECRET          = var.atlantis_repo_webhook_secret,
      GITHUB_OWNER                        = "<GITHUB_OWNER>",
      GITHUB_TOKEN                        = var.github_token,
      TF_VAR_atlantis_repo_webhook_secret = var.atlantis_repo_webhook_secret,
      TF_VAR_github_token                 = var.github_token,
      TF_VAR_kubefirst_bot_ssh_public_key = var.kubefirst_bot_ssh_public_key,
      TF_VAR_vault_addr                   = "http://vault.vault.svc.cluster.local:8200",
      TF_VAR_vault_token                  = "k1_local_vault_token",
      VAULT_ADDR                          = "http://vault.vault.svc.cluster.local:8200",
      VAULT_TOKEN                         = "k1_local_vault_token",
    }
  )
}
