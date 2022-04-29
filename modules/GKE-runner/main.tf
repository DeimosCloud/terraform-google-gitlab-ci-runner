
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

# resource "google_container_node_pool" "gitlab_runner_pool" {
#   name               = var.runner_node_pool_name
#   # cluster            = var.cluster_id
#   cluster            = data.google_container_cluster.this_cluster.id
#   initial_node_count = var.initial_node_count

#   autoscaling {
#     min_node_count = var.min_node_count
#     max_node_count = var.max_node_count
#   }

#   upgrade_settings {
#     max_surge       = var.max_surge
#     max_unavailable = var.max_unavailable
#   }

#   node_config {
#     machine_type    = var.machine_type
#     labels          = var.node_labels
#     service_account = google_service_account.runner_nodes.email
#     taint           = var.node_taints

#     oauth_scopes = [
#       "https://www.googleapis.com/auth/cloud-platform"
#     ]
#   }
# }

module "gke_node_pool" {
  source = "/Users/daphneyigwe/Desktop/terraform-google-gke/modules/gke-node-pool"
  # source  = "DeimosCloud/gke/google//modules/gke-node-pool"
  # version = "1.0.3"
  project_id = var.project
  location   = var.cluster_location
  cluster    = var.cluster_name

  name               = var.runner_node_pool_name
  kubernetes_version = var.kubernetes_version
  zones              = var.node_zones

  auto_upgrade       = var.auto_upgrade
  initial_node_count = var.initial_node_count
  min_node_count     = var.min_node_count
  max_node_count     = var.max_node_count

  image_type   = var.node_image_type
  machine_type = var.machine_type

  labels = var.node_labels
  taints = var.node_taints

  disk_size_gb = var.disk_size_gb
  disk_type    = var.disk_type

  is_preemptible = var.node_is_preemptible

  service_account = google_service_account.runner_nodes.email
  oauth_scopes    = var.oauth_scopes
}



#----------------------------------------------------------
# create gcs bucket for distribute caching with the runners
#-----------------------------------------------------------

module "cache" {
  source      = "../cache"
  count       = local.count
  bucket_name = var.bucket_name
  # cache_location          = var.cache_location
  cache_location          = var.cache_location != null ? var.cache_location : var.region
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
  count              = local.count
  service_account_id = module.cache.0.cache_service_account_name
}


resource "kubernetes_namespace" "runner_namespace" {
  metadata {
    name = var.namespace
  }

  depends_on = [
    module.gke_node_pool
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
  # if cache local is used then no need to create cache module or kubernetes secret.

  release_name  = var.release_name
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

  cache = {
    type   = var.cache_type
    path   = var.cache_path
    shared = var.cache_shared
    gcs = {
      CredentialsFile = local.cred_file
      BucketName      = "${var.bucket_name}"
    }
    s3    = {}
    azure = {}
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