#----------------------------
# create GCS bucket for cache
#-----------------------------
resource "google_storage_bucket" "cache" {
  name          = var.bucket_name
  location      = var.cache_location
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
  labels = var.labels
}


#----------------------------------------------------------------
# create service account with access to the above created bucket
#----------------------------------------------------------------
resource "google_service_account" "cache_admin" {
  account_id   = "${var.prefix}-gitlab-runner-cache"
  display_name = "GitLab CI Worker"
}

resource "google_storage_bucket_iam_member" "cache-member" {
  bucket = google_storage_bucket.cache.name
  role   = "roles/storage.admin"
  member = "serviceAccount:${google_service_account.cache_admin.email}"
}