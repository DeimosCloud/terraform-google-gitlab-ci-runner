locals {
  runner_node_roles = distinct(concat([
    "roles/logging.logWriter",
    "roles/monitoring.metricWriter",
    "roles/monitoring.viewer"
  ], var.additional_node_service_account_roles))

  cache_type        = "gcs"
  cred_file         = "/secrets/gcs_cred"
  count             = var.cache_type == "gcs" ? 1 : 0
  cache_secret_name = "google-application-credentials"
}
