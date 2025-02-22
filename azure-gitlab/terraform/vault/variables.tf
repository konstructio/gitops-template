locals {
  cluster_name = "<CLUSTER_NAME>"
}

variable "b64_docker_auth" {
  type = string
}

variable "gitlab_token" {
  type = string
}

variable "kbot_ssh_private_key" {
  default = ""
  type    = string
}

variable "kbot_ssh_public_key" {
  default = ""
  type    = string
}

variable "atlantis_repo_webhook_secret" {
  default = ""
  type    = string
}

variable "atlantis_repo_webhook_url" {
  default = ""
  type    = string
}

variable "azure_storage_account" {
  default = ""
  type    = string
}

variable "azure_storage_access_key" {
  default   = ""
  type      = string
  sensitive = true
}

variable "arm_client_id" {
  default   = ""
  type      = string
  sensitive = true
}

variable "arm_client_secret" {
  default   = ""
  type      = string
  sensitive = true
}

variable "arm_tenant_id" {
  default   = ""
  type      = string
  sensitive = true
}

variable "arm_subscription_id" {
  default   = ""
  type      = string
  sensitive = true
}

variable "container_registry_auth" {
  type = string
}

variable "owner_group_id" {
  description = "gitlab owner group id"
  type        = string
}

variable "vault_token" {
  default = ""
  type    = string
}
