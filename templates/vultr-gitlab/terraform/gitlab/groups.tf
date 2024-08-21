data "gitlab_group" "owner" {
  group_id = tonumber(var.owner_group_id)
}

resource "gitlab_group" "admins" {
  name        = "admins"
  path        = "admins"
  parent_id   = data.gitlab_group.owner.group_id
  description = "admins group"
}

resource "gitlab_group" "developers" {
  name        = "developers"
  path        = "developers"
  parent_id   = data.gitlab_group.owner.group_id
  description = "developers group"
}

resource "gitlab_group_share_group" "admins" {
  group_id       = data.gitlab_group.owner.id
  share_group_id = gitlab_group.admins.id
  group_access   = "owner"
}

resource "gitlab_group_share_group" "developers" {
  group_id       = data.gitlab_group.owner.id
  share_group_id = gitlab_group.developers.id
  group_access   = "maintainer"
}
