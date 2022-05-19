output "runners_name" {
  value       = var.runners_name
  description = "name of the gitlab runner"
}

output "cache_bucket_name" {
  value       = module.cache_gcs.0.cache_bucket_name
  description = "name of the gcs bucket used a s runner cache"
}

