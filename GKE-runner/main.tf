
#--------------------------------------------------------------------
# create service account for cluster nodes and assign them IAM roles
#--------------------------------------------------------------------

resource "google_service_account" "runner_nodes" {
  account_id   = "${var.prefix}-gitlab-runner-nodes"
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

resource "google_container_node_pool" "gitlab_runner_pool" {
  name               = var.runner_node_pool_name
  cluster            = var.cluster_id
  initial_node_count = var.initial_node_count

  autoscaling {
    min_node_count = var.min_node_count
    max_node_count = var.max_node_count
  }

  upgrade_settings {
    max_surge       = var.max_surge
    max_unavailable = var.max_unavailable
  }

  node_config {
    machine_type    = var.machine_type
    labels          = var.node_labels
    service_account = google_service_account.runner_nodes.email
    taint           = var.node_taints

    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform"
    ]
  }
}


#----------------------------------------------------------
# create gcs bucket for distribute caching with the runners
#-----------------------------------------------------------

module "cache" {
  source                  = "/Users/daphneyigwe/Desktop/terraform-google-gitlab-ci-runner/cache"
  count                   = var.create_cache_bucket ? 1 : 0
  bucket_name             = var.bucket_name
  cache_location          = var.cache_location
  labels                  = var.node_labels
  cache_storage_class     = var.cache_storage_class
  cache_bucket_versioning = var.cache_bucket_versioning
  cache_expiration_days   = var.cache_expiration_days
  prefix                  = var.prefix
}


#--------------------------------------------------------
# create kubernetes secret from service account cred file
#--------------------------------------------------------

resource "google_service_account_key" "cache_admin" {
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
  metadata {
    name      = "google-application-credentials"
    namespace = kubernetes_namespace.runner_namespace.metadata[0].name
  }

  binary_data = {
    gcs_cred = google_service_account_key.cache_admin.private_key
  }

  depends_on = [
    kubernetes_namespace.runner_namespace,
    module.cache
  ]
}


#----------------------------------------------------------------------
# set up gitlab runner using the deimos kubernetes gitlab runner module
#-----------------------------------------------------------------------
module "kubernetes_gitlab_runner" {
  # source = "DeimosCloud/gitlab-runner/kubernetes"
  source = "/Users/daphneyigwe/Desktop/terraform-kubernetes-gitlab-runner"

  release_name  = var.release_name
  chart_version = var.chart_version
  namespace     = var.namespace

  gitlab_url = var.gitlab_url
  concurrent = var.concurrent
  replicas   = var.replicas

  runner_name               = var.runner_name
  runner_tags               = var.runner_tags
  runner_registration_token = var.runner_registration_token
  runner_locked             = var.runner_locked
  runner_image              = var.runner_image
  run_untagged_jobs         = var.runner_untagged_jobs

  manager_node_selectors   = var.node_labels
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
  create_service_account             = var.create_service_account
  service_account_clusterwide_access = var.service_account_clusterwide_access

  cache_shared      = var.cache_shared
  cache_path        = var.cache_path
  cache_type        = local.cache_type
  cache_secret_name = local.cache_secret_name

  gcs_cache_conf = {
    BucketName      = "${var.bucket_name}"
    CredentialsFile = local.cred_file
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
      protected = true
    }
  }

  depends_on = [
    kubernetes_secret.cache_secret
  ]
}