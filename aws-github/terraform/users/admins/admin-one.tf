# # note: uncomment the below to create a new admin, and be sure to
# # adjust module name admin_one below to your admin's firstname_lastname.
# # create as many admin modules files as you have admin personnel.

# module "admin_one" {
#   source = "../modules/user"

#   acl_policies            = ["admin"]
#   email                   = "your.admin@your-company.io"
#   first_name              = "Admin"
#   github_username         = "admin-one-github-username"
#   last_name               = "One"
#   team_id                 = data.github_team.admins.id
#   username                = "aone"
#   user_disabled           = false
#   userpass_accessor       = data.vault_auth_backend.userpass.accessor
# }
