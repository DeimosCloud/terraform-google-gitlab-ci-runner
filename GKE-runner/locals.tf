locals {
  node_pool_name = var.runner_node_pool_name != null ? var.runner_node_pool_name : "gitlab-runner-${random_id.random_suffix.hex}"

  runner_node_roles = distinct(concat([
    "roles/logging.logWriter",
    "roles/monitoring.metricWriter",
    "roles/monitoring.viewer"
  ], var.additional_node_service_account_roles))

  cred_file                   = "/secrets/gcs_cred"
  cache_secret_name           = "google-application-credentials"
  cache_type                  = "gcs"
  cache_service_account_email = var.cache_create_service_account == true ? "${google_service_account.cache_admin[0].email}" : var.cache_service_account.email
  cache_service_account_name  = var.cache_create_service_account == true ? "${google_service_account.cache_admin[0].name}" : var.cache_service_account.name
}
