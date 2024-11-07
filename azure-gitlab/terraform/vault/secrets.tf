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

resource "vault_generic_secret" "container_registry_auth" {
  path = "${vault_mount.secret.path}/deploy-tokens/container-registry-auth"

  data_json = jsonencode(
    {
      auth = jsonencode({ "auths" : { "registry.gitlab.com" : { "username" : "container-registry-auth", "password" : "${var.container_registry_auth}", "email" : "kbo@example.com", "auth" : "${var.b64_docker_auth}" } } }),
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

resource "vault_generic_secret" "docker_config" {
  path = "${vault_mount.secret.path}/dockerconfigjson"

  data_json = jsonencode(
    {
      dockerconfig = jsonencode({ "auths" : { "registry.gitlab.com" : { "username" : "container-registry-auth", "password" : "${var.container_registry_auth}", "email" : "kbot@example.com", "auth" : "${var.b64_docker_auth}" } } }),
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
      PERSONAL_ACCESS_TOKEN = var.gitlab_token
    }
  )
}

resource "gitlab_user_runner" "shared_runner" {
  group_id  = var.owner_group_id
  runner_type = "group_type"
  description = "Shared Runner for Group Projects"
  tag_list    = ["shared"]
  untagged = true
}

resource "vault_generic_secret" "gitlab_runner" {
  path      = "${vault_mount.secret.path}/gitlab-runner"
  data_json = <<EOT
{
  "RUNNER_TOKEN" : "${gitlab_user_runner.shared_runner.token}",
  "RUNNER_REGISTRATION_TOKEN" : ""
}
EOT
}

resource "vault_generic_secret" "atlantis_secrets" {
  path = "${vault_mount.secret.path}/atlantis"

  data_json = jsonencode(
    {
      ARGO_SERVER_URL                     = "argo.argo.svc.cluster.local:2746",
      ATLANTIS_GITLAB_HOSTNAME            = "gitlab.com",
      ATLANTIS_GITLAB_TOKEN               = var.gitlab_token,
      ATLANTIS_GITLAB_USER                = "<GITLAB_USER>",
      ATLANTIS_GITLAB_WEBHOOK_SECRET      = var.atlantis_repo_webhook_secret,
      TF_VAR_atlantis_repo_webhook_secret = var.atlantis_repo_webhook_secret,
      TF_VAR_atlantis_repo_webhook_url    = var.atlantis_repo_webhook_url,
      ARM_CLIENT_ID                       = var.arm_client_id
      ARM_CLIENT_SECRET                   = var.arm_client_secret
      ARM_TENANT_ID                       = var.arm_tenant_id
      ARM_SUBSCRIPTION_ID                 = var.arm_subscription_id
      TF_VAR_b64_docker_auth              = var.b64_docker_auth,
      GITLAB_OWNER                        = "<GITLAB_OWNER>",
      GITLAB_TOKEN                        = var.gitlab_token,
      TF_VAR_gitlab_token                 = var.gitlab_token,
      TF_VAR_container_registry_auth      = var.container_registry_auth,
      TF_VAR_owner_group_id               = var.owner_group_id,
      TF_VAR_kbot_ssh_public_key          = var.kbot_ssh_public_key,
      TF_VAR_kbot_ssh_private_key         = var.kbot_ssh_private_key,
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
      password            = var.gitlab_token
      username            = "<GITLAB_USER>"
    }
  )
}
