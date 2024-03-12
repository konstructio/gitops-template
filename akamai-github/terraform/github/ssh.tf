resource "github_user_ssh_key" "kbot" {
  count = var.kbot_ssh_public_key == "" ? 0 : 1
  title = "kbot-<CLUSTER_NAME>"
  key   = var.kbot_ssh_public_key
}
variable "kbot_ssh_public_key" {
  type    = string
  default = ""
}
