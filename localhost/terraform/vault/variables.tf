variable "email_address" {
  type = string
}

variable "github_token" {
  type = string
}

variable "vault_addr" {
  type = string
}

variable "vault_token" {
  type = string
}

variable "ssh_private_key" {
  type        = string
  default     = ""
  description = "SSH Private Key to auth on git"
}

variable "kubefirst_bot_ssh_public_key" {
  default = ""
  type = string 
}

variable "atlantis_repo_webhook_secret" {
  default = ""
  type = string 
}