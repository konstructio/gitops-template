resource "aws_ecr_repository" "repo" {
  name                 = "metaphor-<CLUSTER_NAME>"
  image_tag_mutability = "IMMUTABLE"
  force_delete         = true

  image_scanning_configuration {
    scan_on_push = true
  }
}
