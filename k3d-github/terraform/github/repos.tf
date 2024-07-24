# todo add organization support
module "gitops" {
  source             = "./modules/repository"
  visibility         = "private"
  repo_name          = "<GIT-REPO-NAME>"
  archive_on_destroy = false
  auto_init          = false # set to false if importing an existing repository
}

module "metaphor" {
  source = "./modules/repository"

  repo_name          = "<METPAHOR-REPO-NAME>"
  archive_on_destroy = false
  auto_init          = false # set to false if importing an existing repository
}
