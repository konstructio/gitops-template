# # note: uncomment the below to create a new developer, and be sure to
# # adjust module name developer_one below to your developer's firstname_lastname.
# # create as many developer module files as you have developer personnel.

# module "developer_one" {
#   source = "../modules/user"

#   acl_policies            = ["developer"]
#   email                   = "developer.one@your-company.io"
#   first_name              = "developer"
#   fullname                = "developer one"
#   group_id                = data.vault_identity_group.developers.group_id
#   gitlab_username         = "your-developers-gilab-username"
#   last_name               = "one"
#   username                = "done"
#   user_disabled           = false
#   userpass_accessor       = data.vault_auth_backend.userpass.accessor
# }
