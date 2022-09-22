# these two resources are plural because `admin` is a
# reserved word in GitLab
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
