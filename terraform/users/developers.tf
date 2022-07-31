resource "gitlab_group" "developer" {
  name        = "developer"
  path        = "developer"
  description = "developer group"
}

resource "gitlab_group_share_group" "kubefirst_developer" {
  group_id       = data.gitlab_group.kubefirst.id
  share_group_id = gitlab_group.developer.id
  group_access   = "developer"
}

module "developer_one" {
  source   = "./templates/oidc-user"
  admins_group_id    = gitlab_group.admins.id
  developer_group_id = gitlab_group.developer.id
  username           = "developer1"
  fullname           = "Developer One"
  email              = "developer1@yourcompany.com"
}

module "developer_two" {
  source   = "./templates/oidc-user"
  admins_group_id    = gitlab_group.admins.id
  developer_group_id = gitlab_group.developer.id
  username           = "developer2"
  fullname           = "Developer Two"
  email              = "developer2@yourcompany.com"
}
