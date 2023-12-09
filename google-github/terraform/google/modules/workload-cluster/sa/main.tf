###################################
# IAM For Kubernetes Applications #
###################################

# Service Account

resource "google_service_account" "this" {
  account_id   = var.service_account_name
  display_name = var.display_name
  project      = var.project
}

# Binding Service Account to Kubernetes Service Account

resource "google_service_account_iam_member" "this" {
  service_account_id = google_service_account.this.name
  role               = data.google_iam_role.workload_identity_user.name

  member = "serviceAccount:${var.project}.svc.id.goog[${var.service_account_namespace}/${var.kubernetes_service_account_name}]"
}

# Role Memberships

resource "google_project_iam_member" "this" {
  member  = "serviceAccount:${google_service_account.this.email}"
  project = var.project
  role    = var.role
}