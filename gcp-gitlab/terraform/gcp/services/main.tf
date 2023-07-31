resource "google_project_service" "cloud_kms" {
  project = var.project
  service = "cloudkms.googleapis.com"
  disable_dependent_services = true
}

resource "google_project_service" "cloud_resource_manager" {
  project = var.project
  service = "cloudresourcemanager.googleapis.com"
  disable_dependent_services = true
}

resource "google_project_service" "compute_engine" {
  project = var.project
  service = "compute.googleapis.com"
  disable_dependent_services = true
}

resource "google_project_service" "iam" {
  project = var.project
  service = "iam.googleapis.com"
  disable_dependent_services = true
}

resource "google_project_service" "iam_sa" {
  project = var.project
  service = "iamcredentials.googleapis.com"
  disable_dependent_services = true
}

resource "google_project_service" "kubernetes_engine" {
  project = var.project
  service = "container.googleapis.com"
  disable_dependent_services = true
}
