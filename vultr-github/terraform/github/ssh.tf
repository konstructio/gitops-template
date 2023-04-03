resource "github_user_ssh_key" "kbot" {
  title = "kbot-<CLUSTER_NAME>"
  key   = var.kbot_ssh_public_key
}

variable "kbot_ssh_public_key" {
  type    = string
  default = ""
}
