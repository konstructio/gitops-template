resource "github_team" "admins" {
  name        = "admins"
  description = "administrators of the kubefirst platform"
  privacy     = "closed"
}

resource "github_team" "developers" {
  name        = "developers"
  description = "developers using the kubefirst plaftform"
  privacy     = "closed"
}
