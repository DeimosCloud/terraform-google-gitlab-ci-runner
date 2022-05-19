output "cache_bucket_name" {
  value       = google_storage_bucket.cache.name
  description = "the FQDN of the cache bucket"
}
