resource "random_password" "chartmuseum_password" {
  length           = 22
  special          = true
  override_special = "!#$"
}

resource "vault_generic_secret" "chartmuseum_secrets" {
  path = "${vault_mount.secret.path}/chartmuseum"

  data_json = jsonencode(
    {
      BASIC_AUTH_USER          = "kbot",
      BASIC_AUTH_PASS          = random_password.chartmuseum_password.result,
      AZURE_STORAGE_ACCOUNT    = var.azure_storage_account,
      AZURE_STORAGE_ACCESS_KEY = var.azure_storage_access_key,
    }
  )
}

resource "vault_generic_secret" "azure_creds" {
  path = "${vault_mount.secret.path}/argo"

  data_json = jsonencode(
    {
      client_id         = var.arm_client_id
      arm_client_secret = var.arm_client_secret
      tenant_id         = var.arm_tenant_id
      subscription_id   = var.arm_subscription_id
    }
  )
}

resource "vault_generic_secret" "crossplane" {
  path = "${vault_mount.secret.path}/crossplane"

  data_json = jsonencode(
    {
      ARM_CLIENT_ID       = var.arm_client_id
      ARM_CLIENT_SECRET   = var.arm_client_secret
      ARM_TENANT_ID       = var.arm_tenant_id
      ARM_SUBSCRIPTION_ID = var.arm_subscription_id
      VAULT_ADDR          = "http://vault.vault.svc.cluster.local:8200"
      VAULT_TOKEN         = var.vault_token
      password            = var.github_token
      username            = "<GITHUB_USER>"
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
      client_id             = var.arm_client_id
      arm_client_secret     = var.arm_client_secret
      tenant_id             = var.arm_tenant_id
      subscription_id       = var.arm_subscription_id
      BASIC_AUTH_USER       = "kbot"
      BASIC_AUTH_PASS       = random_password.chartmuseum_password.result
      SSH_PRIVATE_KEY       = var.kbot_ssh_private_key
      PERSONAL_ACCESS_TOKEN = var.github_token
    }
  )
}

resource "vault_generic_secret" "cloudflare" {
  path = "${vault_mount.secret.path}/cloudflare"

  data_json = jsonencode(
    {
      origin-ca-api-key = var.cloudflare_origin_ca_api_key,
      cf-api-key        = var.cloudflare_api_key,
      cloudflare-token  = var.cloudflare_api_key,
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
      ATLANTIS_GH_USER                    = "<GITHUB_USER>",
      ATLANTIS_GH_WEBHOOK_SECRET          = var.atlantis_repo_webhook_secret,
      TF_VAR_atlantis_repo_webhook_secret = var.atlantis_repo_webhook_secret,
      TF_VAR_atlantis_repo_webhook_url    = var.atlantis_repo_webhook_url,
      ARM_CLIENT_ID                       = var.arm_client_id
      ARM_CLIENT_SECRET                   = var.arm_client_secret
      ARM_TENANT_ID                       = var.arm_tenant_id
      ARM_SUBSCRIPTION_ID                 = var.arm_subscription_id
      TF_VAR_b64_docker_auth              = var.b64_docker_auth,
      GITHUB_OWNER                        = "<GITHUB_OWNER>",
      GITHUB_TOKEN                        = var.github_token,
      TF_VAR_github_token                 = var.github_token,
      TF_VAR_kbot_ssh_public_key          = var.kbot_ssh_public_key,
      TF_VAR_kbot_ssh_private_key         = var.kbot_ssh_private_key,
      TF_VAR_cloudflare_origin_ca_api_key = var.cloudflare_origin_ca_api_key
      TF_VAR_cloudflare_api_key           = var.cloudflare_api_key
      VAULT_ADDR                          = "http://vault.vault.svc.cluster.local:8200",
      TF_VAR_vault_addr                   = "http://vault.vault.svc.cluster.local:8200",
      VAULT_TOKEN                         = var.vault_token,
      TF_VAR_vault_token                  = var.vault_token,
    }
  )
}

resource "vault_generic_secret" "azure_dns" {
  path = "${vault_mount.secret.path}/azure-dns"

  data_json = jsonencode({
    "azure.json" = jsonencode({
      tenantId                    = data.azurerm_client_config.current.tenant_id
      subscriptionId              = data.azurerm_client_config.current.subscription_id
      resourceGroup               = "dns-zones"
      useManagedIdentityExtension = true
      userAssignedIdentityID      = data.azurerm_kubernetes_cluster.kubefirst.kubelet_identity[0].client_id
    })
  })
}
