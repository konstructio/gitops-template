# # note: when you uncomment and change admin_one below 
# # to your admin's firstname_lastname, you must also uncomment 
# # and change the "admins_membership" list above to match your
# # individual's firstname_lastname. create as many admin modules
# # as you have admin personnel.
  
# module "admin_one" {
#   source = "./modules/user/github"

#   acl_policies            = ["admin"]
#   email                   = "your.admin@your-company.io"
#   first_name              = "Admin"
#   github_username         = "admin_one_github_username"
#   last_name               = "One"
#   team_id                 = data.github_team.admins.id
#   username                = "aone"
#   user_disabled           = false
#   userpass_accessor       = data.vault_auth_backend.userpass.accessor
# }
