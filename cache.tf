module "cache_gcs" {
  source                       = "./cache"
  count                        = var.create_cache_bucket ? 1 : 0
  bucket_name                  = local.bucket_name
  bucket_location              = var.cache_location != null ? var.cache_location : var.region
  bucket_labels                = local.runners_labels
  prefix                       = var.prefix
  runner_service_account_email = google_service_account.agent.email
}
