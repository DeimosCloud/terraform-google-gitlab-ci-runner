locals {
  node_pool_name = var.runner_node_pool_name != null ? var.runner_node_pool_name : "gitlab-runner-${random_id.random_suffix.hex}"

  runner_node_roles = distinct(concat([
    "roles/logging.logWriter",
    "roles/monitoring.metricWriter",
    "roles/monitoring.viewer"
  ], var.additional_node_service_account_roles))

  # runner_name       = var.runner_name != null ? var.runner_name : "runner-${random_id.random_suffix.hex}"
  cred_file         = "/secrets/gcs_cred"
  count             = var.cache_type == "gcs" ? 1 : 0
  cache_secret_name = "google-application-credentials"
  # cache_bucket_name = var.cache_bucket_name != null ? var.cache_bucket_name : "${var.prefix}-cache-${random_id.random_suffix.hex}"


  gcs_config = {
    CredentialsFile = local.cred_file
    BucketName      = "${module.cache.0.cache_bucket_name}"
  }
  gcs = var.cache_type == "gcs" ? local.gcs_config : {}
  # release = var.runner_release_name != null ? var.runner_release_name : "runner-${random_id.random_suffix.hex}"
}
