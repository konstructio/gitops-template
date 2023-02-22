resource "gitlab_group" "kubefirst" {
  name                   = "kubefirst"
  path                   = "kubefirst"
  description            = "a private group for kubefirst repositories"
  request_access_enabled = false
  visibility_level       = "private"
}

resource "gitlab_group" "admins" {
  name        = "admins"
  path        = "admins"
  description = "admins group"
}

resource "gitlab_group" "developers" {
  name        = "developers"
  path        = "developers"
  description = "developers group"
}

resource "gitlab_group_share_group" "admins" {
  group_id       = gitlab_group.kubefirst.id
  share_group_id = gitlab_group.admins.id
  group_access   = "owner"
}

resource "gitlab_group_share_group" "developers" {
  group_id       = gitlab_group.kubefirst.id
  share_group_id = gitlab_group.developers.id
  group_access   = "maintainer"
}
