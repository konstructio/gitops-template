provider "aws" {
  region = "<AWS_DEFAULT_REGION>"
}

resource "aws_ecr_repository" "ecr_repo_metaphor" {
  name                 = "metaphor-<CLUSTER_NAME>"
  image_tag_mutability = "IMMUTABLE"
  force_delete         = true

  image_scanning_configuration {
    scan_on_push = true
  }
}

resource "aws_ecr_repository" "ecr_repo_metaphor_go" {
  name                 = "metaphor-go-<CLUSTER_NAME>"
  image_tag_mutability = "IMMUTABLE"
  force_delete         = true

  image_scanning_configuration {
    scan_on_push = true
  }
}

resource "aws_ecr_repository" "ecr_repo_metaphor_frontend" {
  name                 = "metaphor-frontend-<CLUSTER_NAME>"
  image_tag_mutability = "IMMUTABLE"
  force_delete         = true

  image_scanning_configuration {
    scan_on_push = true
  }
}
