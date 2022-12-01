resource "aws_s3_bucket" "argo_artifact_bucket" {
  bucket        = "<ARGO_ARTIFACT_BUCKET>"
  acl           = "private"
  force_destroy = true

  tags = {
    Name = "<ARGO_ARTIFACT_BUCKET>"
  }
}

resource "aws_s3_bucket" "chartmuseum_artifact_bucket" {
  bucket        = "<CHARTMUSEUM_ARTIFACT_BUCKET>"
  acl           = "private"
  force_destroy = true

  tags = {
    Name = "<CHARTMUSEUM_ARTIFACT_BUCKET>"
  }
}
