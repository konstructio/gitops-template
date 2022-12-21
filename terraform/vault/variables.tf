variable "aws_account_id" {
  type = string
}
variable "aws_region" {
  type = string
}
variable "vault_token" {
  type = string
}
variable "email_address" {
  type = string
}
variable "vault_addr" {
  type = string
}
variable "hosted_zone_id" {
  type = string
}
variable "gitlab_runner_token" {
  type = string
  default = ""
}
variable "gitlab_token" {
  type = string
  default = ""
}
variable "github_token" {
  type = string
  default = ""
}
variable "hosted_zone_name" {
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
variable "ami_type" {
  description = "The chipset of nodes"
  default = "AL2_x86_64"
  type = string
}

variable "instance_type" {
  description = "The instance type of node group"
  default = "t3.medium"
  type = string
}
