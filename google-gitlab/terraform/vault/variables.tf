locals {
  cluster_name = "<CLUSTER_NAME>"
}

variable "<EXTERNAL_DNS_PROVIDER_NAME>_secret" {
  default = ""
  type    = string
}

variable "b64_docker_auth" {
  type = string
}

variable "container_registry_auth" {
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

variable "owner_group_id" {
  description = "gitlab owner group id"
  type        = string
}

variable "vault_token" {
  default = ""
  type    = string
}

variable "google_region" {
  description = "Google Cloud Region"
  type        = string

  default = "<CLOUD_REGION>"
}

variable "project" {
  description = "Google Project ID"
  type        = string

  default = "<GOOGLE_PROJECT>"
}
