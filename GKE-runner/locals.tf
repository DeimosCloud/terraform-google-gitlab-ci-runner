locals {
  runner_node_roles = distinct(concat([
    "roles/logging.logWriter",
    "roles/monitoring.metricWriter",
    "roles/monitoring.viewer"
  ], var.additional_node_service_account_roles))

  cache_type        = "gcs"
  cache_secret_name = "google-application-credentials"
  cred_file         = "/secrets/gcs_cred"
}
