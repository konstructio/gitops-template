provider "google" {
  project = var.project
  region  = var.google_region
}

provider "google-beta" {
  project = var.project
  region  = var.google_region
}

terraform {
  backend "gcs" {
    bucket = "<KUBEFIRST_STATE_STORE_BUCKET>"
    prefix = "terraform/google/terraform.tfstate"
  }
}
