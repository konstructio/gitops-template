resource "aws_ecr_repository" "repo" {
  count                = var.repository_name == "" ? 0 : 1
  name                 = var.repository_name
  image_tag_mutability = "IMMUTABLE"
  force_delete         = true

  image_scanning_configuration {
    scan_on_push = true
  }
}
