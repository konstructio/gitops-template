module "kbot" {
  source = "../modules/user"

  acl_policies      = ["admin"]
  email             = "<ALERTS_EMAIL>"
  first_name        = "K"
  fullname          = "kbot"
  gitlab_username   = "<GITLAB_USER>"
  group_id          = data.vault_identity_group.admins.group_id
  last_name         = "Bot"
  initial_password  = var.initial_password
  username          = "kbot"
  user_disabled     = false
  userpass_accessor = data.vault_auth_backend.userpass.accessor
}

variable "initial_password" {
  type    = string
  default = ""
}
