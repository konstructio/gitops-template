output "service_account_email" {
  value = google_service_account.this.email
}

output "service_account_id" {
  value = google_service_account.this.id
}
