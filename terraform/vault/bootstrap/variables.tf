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
}
variable "gitlab_token" {
  type = string
}
variable "atlantis_github_webhook_token" {
  description = "GitHub Webhook token to be used on atlantis"
  type = string
}
variable "hosted_zone_name" {
  type = string
}
variable "git_provider" {
  type = string
  default = "gitlab"
  description = "Git provider, default gitlab, accepts: gitlab | github"
}
variable "ssh_private_key" {
  type = string
  default = ""
  description = "SSH Private Key to auth on git"
}
