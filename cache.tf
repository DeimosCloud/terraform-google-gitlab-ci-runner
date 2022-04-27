module "cache_gcs" {
  source = "./cache"
  count = var.create_cache_bucket ? 1 : 0
  bucket_name = local.bucket_name
  cache_location = var.cache_location != null ? var.cache_location : var.region
  labels = local.runners_labels
  prefix = var.prefix
}
