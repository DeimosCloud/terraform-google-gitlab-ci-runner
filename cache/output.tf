output "cache_bucket_name" {
  value = google_storage_bucket.cache.name
}

output "cache_service_account_email" {
  value = google_service_account.cache_admin.email
}

output "cache_service_account_name" {
  value = google_service_account.cache_admin.name
}