# todo add organization support
module "gitops" {
  source             = "./modules/repository"
  visibility         = "private"
  repo_name          = "gitops"
  archive_on_destroy = false
  auto_init          = false # set to false if importing an existing repository
}

resource "github_repository_webhook" "gitops_atlantis_webhook" {
  count = tobool(var.create_repo_webhook) ? 1 : 0

  repository = module.gitops.repo_name

  configuration {
    url          = var.atlantis_repo_webhook_url
    content_type = "json"
    insecure_ssl = false
    secret       = var.atlantis_repo_webhook_secret
  }

  active = true

  events = ["pull_request_review", "push", "issue_comment", "pull_request"]
}


module "metaphor_frontend" {
  source = "./modules/repository"

  repo_name          = "metaphor-frontend"
  archive_on_destroy = false
  auto_init          = false # set to false if importing an existing repository
  create_ecr         = false
}


variable "atlantis_repo_webhook_secret" {
  type    = string
  default = ""
}

variable "atlantis_repo_webhook_url" {
  type = string
}

variable "create_repo_webhook" {
  type    = string
  default = "false"
}
