output "cache_bucket_name" {
  value       = google_storage_bucket.cache.name
  description = "the FQDN of the cache bucket"
}

output "cache_service_account_email" {
  value       = google_service_account.cache_admin.email
  description = "the service account email of the service account created to access the cache bucket"
}

output "cache_service_account_name" {
  value       = google_service_account.cache_admin.name
  description = "the service account name of the service account created to access the cache bucket"
}