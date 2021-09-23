variable "project" {
  type        = string
  description = "The GCP project to deploy the runner into."
}

variable "region" {
  type        = string
  description = "The GCP region to deploy the runner into."
}

variable "prefix" {
  type        = string
  default     = "ci"
  description = "The prefix to apply to all GCP resource names (e.g. <prefix>-runner, <prefix>-agent-1)."
}

variable "runners_metadata" {
  description = "(Optional) Metadata key/value pairs to make available from within instances created from this template."
  default     = {}
}

variable "network" {
  description = "The target VPC for the docker-machine and runner instances."
  type        = string
  default     = "default"
}

variable "subnetwork" {
  description = "Subnetwork used for hosting the gitlab-runners."
  type        = string
  default     = ""
}

variable "runners_machine_type" {
  description = "Instance type used for the GitLab runner."
  type        = string
  default     = "n1-standard-1"
}

variable "runners_preemptible" {
  description = "If true, runner compute instances will be premptible"
  type        = bool
  default     = true
}

variable "runners_disk_size" {
  description = "The size of the created gitlab runner instances in GB."
  type        = number
  default     = 20
}

variable "runners_disk_type" {
  description = "The Disk type of the gitlab runner instances"
  type        = string
  default     = "pd-standard"
}

variable "runners_tags" {
  description = "Additional Network tags to be attached to the Gitlab Runner."
  type        = list(string)
  default     = []
}

variable "docker_machine_download_url" {
  description = "Full url pointing to a linux x64 distribution of docker machine."
  type        = string
  default     = "https://gitlab-docker-machine-downloads.s3.amazonaws.com/main/docker-machine-Linux-x86_64"
}

variable "docker_machine_machine_type" {
  description = "The Machine Type for the docker-machine instances."
  type        = string
  default     = "f1-micro"
}

variable "docker_machine_preemptible" {
  description = "If true, docker-machine instances will be premptible"
  type        = bool
  default     = true
}

variable "docker_machine_image" {
  description = "A GCP custom image to use for spinning up docker-machines"
  type        = string
  default     = ""
}

variable "docker_machine_disk_type" {
  description = "The disk Type for docker-machine instances."
  type        = string
  default     = "pd-standard"
}

variable "docker_machine_disk_size" {
  description = "The disk size for the docker-machine instances."
  type        = number
  default     = 20
}

variable "docker_machine_tags" {
  description = "Additional Network tags to be attached to the docker-machine instances."
  type        = list(string)
  default     = []
}

variable "docker_machine_use_internal_ip" {
  description = "If true, docker-machine instances will have only internal IPs."
  default     = false
  type        = bool
}

variable "runners_name" {
  description = "Name of the runner, will be used in the runner config.toml."
  type        = string
}

variable "runners_max_replicas" {
  description = "The maximum number of runners to spin up.For docker+machine, this is the max number of instances that will run docker-machine. For docker, this is the maximum number of runner instances. "
  type        = number
  default     = 1
}

variable "runners_min_replicas" {
  description = "The minimum number of runners to spin up. For docker+machine, this is the min number of instances that will run docker-machine. For docker, this is the minimum number of runner instances"
  type        = number
  default     = 1
}

variable "runners_executor" {
  description = "The executor to use. Currently supports `docker+machine` or `docker`."
  type        = string
  default     = "docker+machine"
}

variable "runners_install_docker_credential_gcr" {
  description = "Install docker_credential_gcr inside `startup_script_pre_install` script"
  type        = bool
  default     = true
}

variable "runners_gitlab_url" {
  description = "URL of the GitLab instance to connect to."
  type        = string
  default     = "https://gitlab.com"
}

variable "runners_limit" {
  description = "Limit for the runners, will be used in the runner config.toml."
  type        = number
  default     = 0
}

variable "runners_concurrent" {
  description = "Concurrent value for the runners, will be used in the runner config.toml. Limits how many jobs globally can be run concurrently when running docker-machine."
  type        = number
  default     = 10
}

variable "runners_max_growth_rate" {
  description = "(docker-machine) The maximum number of machines that can be added to the runner in parallel. Default is 0 (no limit)."
  type        = number
  default     = 0
}

variable "runners_idle_time" {
  description = "(docker-machine) Idle time of the runners, will be used in the runner config.toml."
  type        = number
  default     = 600
}

variable "runners_idle_count" {
  description = "(docker-machine) Idle count of the runners, will be used in the runner config.toml."
  type        = number
  default     = 0
}

variable "runners_max_builds" {
  description = "(docker-machine) Max builds for each runner after which it will be removed, will be used in the runner config.toml. By default set to 0, no maxBuilds will be set in the configuration."
  type        = number
  default     = 0
}

variable "runners_image" {
  description = "Image to run builds, will be used in the runner config.toml"
  type        = string
  default     = "docker:19.03"
}

variable "runners_privileged" {
  description = "Runners will run in privileged mode, will be used in the runner config.toml"
  type        = bool
  default     = true
}

variable "runners_disable_cache" {
  description = "Runners will not use local cache, will be used in the runner config.toml"
  type        = bool
  default     = false
}

variable "runners_additional_volumes" {
  description = "Additional volumes that will be used in the runner config.toml, e.g Docker socket"
  type        = list(any)
  default     = []
}

variable "runners_shm_size" {
  description = "shm_size for the runners, will be used in the runner config.toml"
  type        = number
  default     = 0
}

variable "runners_docker_runtime" {
  description = "docker runtime for runners, will be used in the runner config.toml"
  type        = string
  default     = ""
}

variable "runners_helper_image" {
  description = "Overrides the default helper image used to clone repos and upload artifacts, will be used in the runner config.toml"
  type        = string
  default     = ""
}

variable "runners_pull_policy" {
  description = "pull_policy for the runners, will be used in the runner config.toml"
  type        = string
  default     = "always"
}

variable "runners_enable_monitoring" {
  description = "Installs Stackdriver monitoring Agent on runner Instances to collect metrics."
  type        = bool
  default     = true
}

variable "runners_machine_autoscaling" {
  description = "(docker-machine) Set autoscaling parameters based on periods, see https://docs.gitlab.com/runner/configuration/advanced-configuration.html#the-runnersmachine-section"
  type = list(object({
    periods    = list(string)
    idle_count = number
    idle_time  = number
    timezone   = string
  }))
  default = []
}

variable "runners_root_size" {
  description = "Runner instance root size in GB."
  type        = number
  default     = 16
}

variable "runners_environment_vars" {
  description = "Environment variables during build execution, e.g. KEY=Value, see runner-public example. Will be used in the runner config.toml"
  type        = list(string)
  default     = []
}

variable "runners_pre_build_script" {
  description = "Script to execute in the pipeline just before the build, will be used in the runner config.toml"
  type        = string
  default     = "\"\""
}

variable "runners_post_build_script" {
  description = "Commands to be executed on the Runner just after executing the build, but before executing after_script. "
  type        = string
  default     = "\"\""
}

variable "runners_pre_clone_script" {
  description = "Commands to be executed on the Runner before cloning the Git repository. this can be used to adjust the Git client configuration first, for example. "
  type        = string
  default     = "\"\""
}

variable "runners_request_concurrency" {
  description = "Limit number of concurrent requests for new jobs from GitLab (default 1)"
  type        = number
  default     = 1
}

variable "runners_output_limit" {
  description = "Sets the maximum build log size in kilobytes, by default set to 4096 (4MB)"
  type        = number
  default     = 4096
}

variable "startup_script_pre_install" {
  description = "Startup script snippet to insert before GitLab runner install"
  type        = string
  default     = ""
}

variable "startup_script_post_install" {
  description = "Startup script snippet to insert after GitLab runner install"
  type        = string
  default     = ""
}

variable "runners_use_internal_ip" {
  description = "Restrict runners to the use of a Internal IP address. NOTE: NAT Gateway must be deployed in your network so that Runners can access resources on the internet"
  type        = bool
  default     = false
}

variable "cache_location" {
  description = "The location where to create the cache bucket in. If not specified, it defaults to the region"
  default     = null
}

variable "cache_bucket_versioning" {
  description = "Boolean used to enable versioning on the cache bucket, false by default."
  type        = bool
  default     = false
}

variable "cache_storage_class" {
  description = "The cache storage class"
  default     = "STANDARD"
}

variable "cache_expiration_days" {
  description = "Number of days before cache objects expires."
  type        = number
  default     = 2
}

variable "cache_shared" {
  description = "Enables cache sharing between runners."
  type        = bool
  default     = true
}

variable "gitlab_runner_version" {
  description = "Version of the GitLab runner. Defaults to latest"
  type        = string
  default     = ""
}

variable "runners_allow_ssh_access" {
  description = "Enables SSH Access to the runner instances."
  type        = bool
  default     = true
}

variable "runners_ssh_allowed_cidr_blocks" {
  description = "List of CIDR blocks to allow SSH Access to the gitlab runner instance."
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "labels" {
  description = "Map of labels that will be added to created resources"
  type        = map(string)
  default     = {}
}

variable "docker_machine_options" {
  description = "List of additional options for the docker machine config. Each element of this list must be a key=value pair. E.g. '[\"google-zone=a\"]'"
  type        = list(string)
  default     = []
}

variable "gitlab_runner_registration_config" {
  description = "Configuration used to register the runner. Available at https://docs.gitlab.com/ee/api/runners.html#register-a-new-runner."
  default = {
    registration_token = ""
    tag_list           = ""
    description        = ""
    locked_to_project  = ""
    run_untagged       = ""
    maximum_timeout    = ""
    access_level       = "not_protected"
  }
  # validation {
  #   condition     = var.gitlab_runner_registration_config["registration_token"] != ""
  #   error_message = "gitlab_runner_registration_config[\"registration_token\"] must be set"
  # }
}


variable "create_cache_bucket" {
  description = "Creates a cache cloud storage bucket if true"
  default     = true
}

variable "runners_volumes_tmpfs" {
  type = list(object({
    volume  = string
    options = string
  }))
  default = []
}

variable "runners_services_volumes_tmpfs" {
  type = list(object({
    volume  = string
    options = string
  }))
  default = []
}

variable "runners_target_autoscale_cpu_utilization" {
  description = "The target CPU utilization that the autoscaler should maintain. If runner CPU utilization gets above this, a new runner is created until runners_max_replicas is reached"
  default     = 0.9
}

variable "runner_additional_service_account_roles" {
  description = "Additional roles to pass to the Runner service account"
  default     = []
  type        = list(string)
}
