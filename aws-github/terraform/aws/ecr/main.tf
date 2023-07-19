resource "aws_ecr_repository" "repo" {
  count                = var.use_ecr ? 1 : 0
  name                 = var.repository_name
  image_tag_mutability = "IMMUTABLE"
  force_delete         = true

  image_scanning_configuration {
    scan_on_push = true
  }
}
