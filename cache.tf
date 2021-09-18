resource "google_storage_bucket" "cache" {
  count         = var.create_cache_bucket ? 1 : 0
  name          = local.bucket_name
  location      = var.cache_location != null ? var.cache_location : var.region
  force_destroy = true
  storage_class = var.cache_storage_class

  versioning {
    enabled = var.cache_bucket_versioning
  }

  uniform_bucket_level_access = true

  lifecycle_rule {
    condition {
      age = var.cache_expiration_days
    }
    action {
      type = "Delete"
    }
  }
  labels = local.runners_labels
}

resource "google_storage_bucket_iam_member" "cache-member" {
  count  = var.create_cache_bucket ? 1 : 0
  bucket = google_storage_bucket.cache[0].name
  role   = "roles/storage.admin"
  member = "serviceAccount:${google_service_account.agent.email}"
}
