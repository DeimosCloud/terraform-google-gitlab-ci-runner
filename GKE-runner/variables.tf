
variable "project" {
  description = "project in which to create iam binding for the cluster node service account"
  type        = string
}

variable "region" {
  description = "where the resources should be deployed"
  type        = string
}

variable "cluster_name" {
  description = "name of the cluster to deploy the kubernetes gitlab runner in"
  type        = string
}

variable "cluster_location" {
  description = "the location where the cluster is deployed"
  type        = string
}

variable "runner_node_pool_zones" {
  type        = list(string)
  description = "The zones to host the cluster in (optional if regional cluster / required if zonal)"
  default     = null
}

variable "runner_node_pool_image_type" {
  type        = string
  description = "(optional) The type of image to be used"
  default     = "COS"
}

variable "runner_node_pool_disk_size_gb" {
  default     = 30
  description = "(Optional) Size of the disk attached to each node, specified in GB. The smallest allowed disk size is 10GB"
}

variable "runner_node_pool_disk_type" {
  default     = "pd-standard"
  description = "(Optional) Type of the disk attached to each node (e.g. 'pd-standard', 'pd-balanced' or 'pd-ssd')."
  type        = string
}

variable "prefix" {
  description = "string to be prepended to the nodes service account id and the service account for the cache"
  type        = string
  default     = "gitlab-runner"
}

variable "additional_node_service_account_roles" {
  description = "additional roles to grant the service account"
  type        = list(any)
  default     = []
}

variable "runner_node_pool_name" {
  description = "name of the runner node pool"
  type        = string
  default     = null
}

variable "initial_node_count" {
  description = "initial number of nodes that the node pool creates"
  type        = number
  default     = 0
}

variable "runner_node_pool_min_node_count" {
  description = "the minimum number of nodes that can be present in the node pool (autoscaling controls)"
  type        = number
  default     = 0
}

variable "runner_node_pool_max_node_count" {
  description = "the maximum number of nodes that can be present in the node pool (autoscaling controls)"
  type        = number
  default     = 3
}

variable "runner_node_pool_machine_type" {
  description = "type of compute machine used for the nodes in the runner node pool"
  type        = string
  default     = "n1-standard-2"
}

variable "runner_node_pool_node_labels" {
  description = "labels for nodes in the runner node pool"
  type        = map(any)
  default = {
    "role" = "gitlab-runner"
  }
}

variable "runner_node_pool_node_taints" {
  description = "taints to be applied to the nodes in the runner node pool"
  type        = list(map(string))
  default = [{
    effect = "NO_SCHEDULE"
    key    = "role"
    value  = "gitlab-ci"
  }]
}

# variable "node_is_preemptible" {
#   default     = false
#   type        = bool
#   description = "A boolean that represents whether or not the underlying node VMs are preemptible"
# }

variable "runner_node_pool_oauth_scopes" {
  description = "(Optional) Scopes that are used by NAP when creating node pools."
  default     = ["https://www.googleapis.com/auth/cloud-platform"]
  type        = list(string)
}

variable "cache_location" {
  description = "location of the cache bucket"
  type        = string
  # default     = null
}

variable "cache_storage_class" {
  description = "The cache storage class"
  type        = string
  default     = "STANDARD"
}
variable "cache_labels" {
  description = "The cache storage class"
  type        = map(string)
  default = {
    "role" = "gitlab-runner-cache"
  }
}

variable "cache_expiration_days" {
  description = "Number of days before cache objects expires."
  type        = number
  default     = 2
}

variable "cache_bucket_versioning" {
  description = "Boolean used to enable versioning on the cache bucket, false by default."
  type        = bool
  default     = false
}

variable "runner_release_name" {
  description = "helm release name"
  type        = string
  default     = "gitlab-runner"
}

variable "cache_path" {
  description = "path to append to the bucket url"
  type        = string
  default     = "runner"
}

variable "cache_type" {
  description = "type of cache to use for runners"
  type        = string
  default     = "gcs"
}

variable "cache_shared" {
  description = "whether cache can be shared between runners"
  type        = bool
  default     = true
}

variable "runner_create_service_account" {
  description = "whether a service account should be created for the runner. if this is set to false then the var.serviceAccountname is used"
  type        = bool
  default     = true
}

variable "runner_service_account_clusterwide_access" {
  description = "whether the service account should be granted cluster wide access or access is restricted to the specified namespace"
  type        = bool
  default     = false
}

# variable "cache_bucket_name" {
#   description = "name of the gcs bucket to create, to be used as cache"
#   type        = string
#   default     = null
# }

variable "runner_registration_token" {
  description = "runner registration token"
  type        = string
}

variable "runner_image" {
  description = "the docker image to use for the runner"
  type        = string
  default     = "gitlab/gitlab-runner:alpine-bleeding"
}

variable "runner_tags" {
  description = "comma separated list of tags to be applied to the runner"
  type        = string
  default     = null
}

variable "unregister_runners" {
  description = "whether runners should be unregistered when pool is deprovisioned"
  type        = bool
  default     = true
}

variable "namespace" {
  description = "kubernetes namespace in which to create the runner"
  type        = string
  default     = "runner"
}

variable "gitlab_url" {
  description = "the gitlab instance to connect to"
  type        = string
  default     = "https://gitlab.com/"
}

variable "concurrent" {
  description = "the number of jobs that can be run concurrently"
  type        = number
  default     = 10
}

variable "runner_locked" {
  description = "whether the runner is locked to a particular project or group"
  type        = bool
  default     = true
}

variable "manager_node_tolerations" {
  description = "tolerations to apply to the manager pod"
  default = [
    {
      key      = "role"
      operator = "Exists"
      effect   = "NoSchedule"
    }
  ]
}

variable "runner_name" {
  description = "name of the runner"
  type        = string
}

variable "build_job_node_selectors" {
  description = "A map of node selectors to apply to the pods"
  type        = map(any)
  default = {
    role = "gitlab-runner"
  }
}

variable "build_job_node_tolerations" {
  description = "A map of node tolerations to apply to the pods as defined https://docs.gitlab.com/runner/executors/kubernetes.html#other-configtoml-settings"
  default = {
    "role=gitlab-ci" = "NoSchedule"
  }
}

variable "manager_pod_annotations" {
  description = "A map of annotations to be added to each build pod created by the Runner. The value of these can include environment variables for expansion. Pod annotations can be overwritten in each build. "
  default     = {}

}

variable "manager_pod_labels" {
  description = "A map of labels to be added to each build pod created by the runner. The value of these can include environment variables for expansion. "
  default     = {}
}

variable "additional_secrets" {
  description = "additional secrets to mount into the manager pods"
  type        = list(map(string))
  default     = []
}

variable "replicas" {
  description = "the number of manager pod to create"
  type        = number
  default     = 1
}

variable "enable_metrics_service" {
  description = "create service resource to allow scraping metrics via prometheus-operator serviceMonitor"
  type        = bool
  default     = false
}

variable "enable_prometheus_exporter" {
  description = "enable prometheus metric exporter"
  type        = bool
  default     = false
}

variable "enable_target_auto_detection" {
  description = "Configure a prometheus-operator serviceMonitor to allow autodetection of the scraping target. requires var.enable_metrics_service to be set to true"
  type        = bool
  default     = false
}

variable "values_file" {
  description = "path to yaml file containing additional values for the runner"
  type        = string
  default     = null
}

variable "chart_version" {
  description = "version of the gitlab runner chart to use"
  type        = string
  default     = null
}

variable "image_pull_secrets" {
  description = "A array of secrets that are used to authenticate Docker image pulling."
  type        = list(string)
  default     = []
}

variable "build_job_secret_volumes" {
  description = "Secret volume configuration instructs Kubernetes to use a secret that is defined in Kubernetes cluster and mount it inside the runner pods as defined https://docs.gitlab.com/runner/executors/kubernetes.html#secret-volumes"
  type = object({
    name       = string
    mount_path = string
    read_only  = string
    items      = map(string)
  })

  default = {
    name       = null
    mount_path = null
    read_only  = null
    items      = {}
  }
}

variable "build_job_mount_docker_socket" {
  default     = true
  description = "whether to enable docker build commands in CI jobs run on the runner. without running container in privileged mode"
  type        = bool
}

variable "docker_fs_group" {
  description = "The fsGroup to use for docker. This is added to security context when mount_docker_socket is enabled"
  type        = number
  default     = 412
}

variable "build_job_run_container_as_user" {
  description = "SecurityContext: runAsUser for all running job pods"
  default     = null
  type        = string
}

variable "run_untagged_jobs" {
  description = "Specify if jobs without tags should be run. https://docs.gitlab.com/ce/ci/runners/#runner-is-allowed-to-run-untagged-jobs"
  default     = true
}

variable "runner_token" {
  description = "token of already registered runer. to use this var.runner_registration_token must be set to null"
  type        = string
  default     = null
}
variable "runner_protected" {
  description = ""
  type        = bool
  default     = true
}

