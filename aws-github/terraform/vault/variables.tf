locals {
  cluster_name = "<CLUSTER_NAME>"
}

variable "b64_docker_auth" {
  type = string
}

variable "github_token" {
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

variable "vault_token" {
  default = ""
  type    = string
}
