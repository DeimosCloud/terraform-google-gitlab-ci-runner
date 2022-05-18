resource "random_id" "suffix" {
  count       = var.bucket_name == null ? 1 : 0
  byte_length = 4
}


#----------------------------
# create GCS bucket for cache
#-----------------------------

resource "google_storage_bucket" "cache" {
  name          = local.bucket_name
  location      = var.bucket_location
  force_destroy = true
  storage_class = var.bucket_storage_class

  versioning {
    enabled = var.bucket_versioning
  }

  uniform_bucket_level_access = true

  lifecycle_rule {
    condition {
      age = var.bucket_expiration_days
    }
    action {
      type = "Delete"
    }
  }
  labels = var.bucket_labels
}

#----------------------------------------------------------------
# Grant runner service account access to the above created bucket
#----------------------------------------------------------------

resource "google_storage_bucket_iam_member" "cache-member" {
  bucket = google_storage_bucket.cache.name
  role   = "roles/storage.admin"
  member = "serviceAccount:${var.runner_service_account_email}"
  # member = "serviceAccount:${google_service_account.cache_admin.email}"
}