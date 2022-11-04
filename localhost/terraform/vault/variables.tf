variable "github_token" {
  type = string
}

variable "kubefirst_bot_ssh_public_key" {
  default = ""
  type = string 
}

variable "atlantis_repo_webhook_secret" {
  default = ""
  type = string 
}

variable "atlantis_repo_webhook_url" {
  default = ""
  type = string 
}
