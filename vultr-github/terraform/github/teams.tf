resource "github_team" "admins" {
  name        = "<ADMIN_TEAM>"
  description = "administrators of the kubefirst platform"
  privacy     = "closed"
}

resource "github_team" "developers" {
  name        = "<DEVELOPER-TEAM>"
  description = "developers using the kubefirst plaftform"
  privacy     = "closed"
}
