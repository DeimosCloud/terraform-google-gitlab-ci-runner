
#---------------------------
# get cluster information
#---------------------------

data "google_container_cluster" "this_cluster" {
  name     = var.cluster_name
  location = var.cluster_location
}

#--------------------------------------------------------------------
# create service account for cluster nodes and assign them IAM roles
#--------------------------------------------------------------------

resource "google_service_account" "runner_nodes" {
  account_id   = "${var.prefix}-nodes-${random_id.random_suffix.hex}"
  display_name = "GitLab CI Runner"
}

resource "google_project_iam_member" "this" {
  for_each = toset(local.runner_node_roles)
  project  = var.project
  role     = each.value
  member   = "serviceAccount:${google_service_account.runner_nodes.email}"
}

#--------------------------------
# create runner node pool
#--------------------------------

resource "random_id" "random_suffix" {
  count       = var.runner_node_pool_name != null ? 1 : 0
  byte_length = 4
}

resource "google_container_node_pool" "gitlab_runner_pool" {
  name               = local.node_pool_name
  cluster            = data.google_container_cluster.this_cluster.id
  initial_node_count = var.initial_node_count
  node_locations     = var.runner_node_pool_zones

  autoscaling {
    min_node_count = var.runner_node_pool_min_node_count
    max_node_count = var.runner_node_pool_max_node_count
  }

  node_config {
    image_type      = var.runner_node_pool_image_type
    disk_size_gb    = var.runner_node_pool_disk_size_gb
    disk_type       = var.runner_node_pool_disk_type
    machine_type    = var.runner_node_pool_machine_type
    labels          = var.runner_node_pool_node_labels
    service_account = google_service_account.runner_nodes.email
    taint           = var.runner_node_pool_node_taints

    oauth_scopes = var.runner_node_pool_oauth_scopes
  }
}


#----------------------------------------------------------
# create gcs bucket for distribute caching with the runners
#-----------------------------------------------------------

module "cache" {
  source = "../cache"
  count  = local.count
  # bucket_name            = local.cache_bucket_name
  bucket_location        = var.cache_location
  bucket_labels          = var.cache_labels
  bucket_storage_class   = var.cache_storage_class
  bucket_versioning      = var.cache_bucket_versioning
  bucket_expiration_days = var.cache_expiration_days
  prefix                 = var.prefix
}


#--------------------------------------------------------
# create kubernetes secret from service account cred file
#--------------------------------------------------------

resource "google_service_account_key" "cache_admin" {
  count              = local.count
  service_account_id = module.cache.0.cache_service_account_name
}


resource "kubernetes_namespace" "runner_namespace" {
  metadata {
    name = var.namespace
  }

  depends_on = [
    google_container_node_pool.gitlab_runner_pool
  ]
}

resource "kubernetes_secret" "cache_secret" {
  count = local.count
  metadata {
    name      = local.cache_secret_name
    namespace = kubernetes_namespace.runner_namespace.metadata[0].name
  }

  binary_data = {
    gcs_cred = google_service_account_key.cache_admin[0].private_key
  }

  depends_on = [
    google_container_node_pool.gitlab_runner_pool,
    kubernetes_namespace.runner_namespace
  ]
}


#----------------------------------------------------------------------
# set up gitlab runner using the deimos kubernetes gitlab runner module
#-----------------------------------------------------------------------
module "kubernetes_gitlab_runner" {
  source  = "DeimosCloud/gitlab-runner/kubernetes"
  version = "~>1.3.0"

  release_name  = var.runner_release_name
  chart_version = var.chart_version
  namespace     = var.namespace

  gitlab_url = var.gitlab_url
  concurrent = var.concurrent
  replicas   = var.replicas

  runner_name               = var.runner_name
  runner_token              = var.runner_token
  runner_tags               = var.runner_tags
  runner_registration_token = var.runner_registration_token
  runner_locked             = var.runner_locked
  runner_image              = var.runner_image
  run_untagged_jobs         = var.run_untagged_jobs
  unregister_runners        = var.unregister_runners

  manager_node_selectors   = var.runner_node_pool_node_labels
  manager_node_tolerations = var.manager_node_tolerations
  manager_pod_annotations  = var.manager_pod_annotations
  manager_pod_labels       = var.manager_pod_labels

  build_job_node_selectors        = var.build_job_node_selectors
  build_job_node_tolerations      = var.build_job_node_tolerations
  build_job_secret_volumes        = var.build_job_secret_volumes
  build_job_mount_docker_socket   = var.build_job_mount_docker_socket
  build_job_run_container_as_user = var.build_job_run_container_as_user

  docker_fs_group = var.docker_fs_group

  image_pull_secrets                 = var.image_pull_secrets
  create_service_account             = var.runner_create_service_account
  service_account_clusterwide_access = var.runner_service_account_clusterwide_access

  cache = {
    type   = var.cache_type
    path   = var.cache_path
    shared = var.cache_shared
    gcs    = local.gcs
    s3     = {}
    azure  = {}
  }

  additional_secrets = var.additional_secrets

  values_file = var.values_file

  values = {
    metrics = {
      enabled = var.enable_prometheus_exporter
      service_monitor = {
        enabled = var.enable_target_auto_detection
      }
    }
    service = {
      enabled = var.enable_metrics_service
    }
    runner = {
      protected = var.runner_protected
    }
  }

  depends_on = [
    google_container_node_pool.gitlab_runner_pool
  ]
}