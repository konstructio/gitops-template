# module "admin_one" {
#   source = "../modules/user"

#   acl_policies            = ["admin"]
#   email                   = "your.admin@your-company.io"
#   first_name              = "Admin"
#   fullname                = "Admin One"
#   group_id                = data.vault_identity_group.admins.group_id
#   gitlab_username         = "your-admins-gitlab-username"
#   last_name               = "One"
#   username                = "aone"
#   user_disabled           = false
#   userpass_accessor       = data.vault_auth_backend.userpass.accessor
# }
