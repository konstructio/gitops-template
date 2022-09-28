resource "github_user_ssh_key" "kubefirst_bot" {
  title = "kubefirst-bot"
  key   = var.kubefirst_bot_ssh_public_key
}

variable "kubefirst_bot_ssh_public_key" {
  type = string
  default = ""
}
