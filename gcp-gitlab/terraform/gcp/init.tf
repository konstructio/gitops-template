provider "google" {
  project = var.project
  region  = var.gcp_region
}

provider "google-beta" {
  project = var.project
  region  = var.gcp_region
}

terraform {
  backend "gcs" {
    bucket = "<KUBEFIRST_STATE_STORE_BUCKET>"
    prefix = "terraform/gcp/terraform.tfstate"
  }
}
