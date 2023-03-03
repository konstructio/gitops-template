# todo add organization support
module "gitops" {
  source             = "./modules/repository"
  visibility         = "private"
  repo_name          = "gitops"
  archive_on_destroy = false
  auto_init          = false # set to false if importing an existing repository
}

module "metaphor_frontend" {
  source = "./modules/repository"

  repo_name          = "metaphor-frontend"
  archive_on_destroy = false
  auto_init          = false # set to false if importing an existing repository
  create_ecr         = false
}
