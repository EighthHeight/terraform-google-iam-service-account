output "service_account" {
  value = google_service_account.service_account
}

output "email" {
  value = google_service_account.service_account.email
}

output "id" {
  value = google_service_account.service_account.id
}