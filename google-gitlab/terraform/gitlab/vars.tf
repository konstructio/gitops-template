variable "owner_group_id" {
  description = "gitlab owner group id"
  type        = string
}
variable "atlantis_repo_webhook_url" {
  description = "webhook url for atlantis for the gitops project"
  type        = string
}

variable "atlantis_repo_webhook_secret" {
  description = "webhook secret for atlantis for the gitops project"
  type        = string
}
