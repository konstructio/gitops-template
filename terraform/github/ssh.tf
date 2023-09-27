resource "github_user_ssh_key" "kbot" {
  count = var.kbot_ssh_public_key == "" ? 0 : 1
  title = "kbot-test-digitalocean-api-9"
  key   = var.kbot_ssh_public_key
}
variable "kbot_ssh_public_key" {
  type    = string
  default = ""
}
