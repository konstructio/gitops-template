module "metaphor" {
  source = "./modules/repository"

  repo_name          = "metaphor"
  archive_on_destroy = false
  auto_init          = false # set to false if importing an existing repository
  create_ecr         = true
  team_developers_id = github_team.developers.id
  team_admins_id     = github_team.admins.id
}

module "metaphor_go" {
  source = "./modules/repository"

  repo_name          = "metaphor-go"
  archive_on_destroy = false
  auto_init          = false # set to false if importing an existing repository
  create_ecr         = true
  team_developers_id = github_team.developers.id
  team_admins_id     = github_team.admins.id
}

module "metaphor_frontend" {
  source = "./modules/repository"

  repo_name          = "metaphor-frontend"
  archive_on_destroy = false
  auto_init          = false # set to false if importing an existing repository
  create_ecr         = true
  team_developers_id = github_team.developers.id
  team_admins_id     = github_team.admins.id
}
