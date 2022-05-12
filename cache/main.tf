resource "random_id" "suffix" {
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
# create service account with access to the above created bucket
#----------------------------------------------------------------



resource "google_service_account" "cache_admin" {
  account_id   = local.id
  display_name = "GitLab CI Worker"
}

resource "google_storage_bucket_iam_member" "cache-member" {
  bucket = google_storage_bucket.cache.name
  role   = "roles/storage.admin"
  member = "serviceAccount:${google_service_account.cache_admin.email}"
}