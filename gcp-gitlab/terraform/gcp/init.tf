locals {
  access_token = data.google_service_account_access_token.terraform_cicd_sa.access_token
}

data "google_service_account_access_token" "terraform_cicd_sa" {
  provider               = google.tokengenerator
  target_service_account = "terraform@${var.project}.iam.gserviceaccount.com"
  lifetime               = "3600s"
  scopes = [
    "https://www.googleapis.com/auth/cloud-platform",
  ]
}

provider "google" {
  alias   = "tokengenerator"
  project = var.project
  region  = var.gcp_region
}

provider "google" {
  access_token = local.access_token
  project      = var.project
  region       = var.gcp_region
}

terraform {
  backend "gcs" {
    bucket = "<KUBEFIRST_STATE_STORE_BUCKET>"
    prefix = "terraform/gcp/terraform.tfstate"
  }
}
