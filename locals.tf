locals {
  default_labels = {
    "managed-by" = "terraform"
  }
  bucket_name = "${var.prefix}-gitlab-runner-cache-${random_id.this.hex}"

  // Convert list to a string separated and prepend by a comma
  docker_machine_options_string = format(
    ",%s",
    join(",", formatlist("%q", var.docker_machine_options)),
  )

  runners_machine_autoscaling = templatefile("${path.module}/templates/runners-machine-autoscaling.tpl", {
    runners_machine_autoscaling = var.runners_machine_autoscaling
    }
  )

  runners_labels = merge({
    "role" = "gitlab-runner"
  }, local.default_labels, var.labels)

  agent_machine_labels = join(",", [for key, value in merge({ "managed-by" = "gitlab-runner", "runner-executor" : "docker-machine" }, var.labels) : "${key}:${value}"])

  runners_max_builds_string = var.runners_max_builds == 0 ? "" : format("MaxBuilds = %d", var.runners_max_builds)

  runners_additional_volumes = <<-EOT
  %{~for volume in var.runners_additional_volumes~}, "${volume}"%{endfor~}
  EOT

  template_startup_script = templatefile("${path.module}/templates/startup-script.sh.tpl",
    {
      docker_machine_download_url           = var.docker_machine_download_url
      gitlab_runner_version                 = var.gitlab_runner_version == "" ? "gitlab-runner" : "gitlab-runner-${var.gitlab_runner_version}"
      pre_install                           = var.startup_script_pre_install
      prefix                                = var.prefix
      post_install                          = var.startup_script_post_install
      gcp_project                           = var.project
      gcp_region                            = var.region
      gcp_zone                              = random_shuffle.zones.result[0]
      gitlab_runner_registration_token      = var.gitlab_runner_registration_config["registration_token"]
      gitlab_runner_tag_list                = lookup(var.gitlab_runner_registration_config, "tag_list", "")
      gitlab_runner_locked_to_project       = lookup(var.gitlab_runner_registration_config, "locked_to_project", "")
      gitlab_runner_run_untagged            = lookup(var.gitlab_runner_registration_config, "run_untagged", "")
      giltab_runner_description             = lookup(var.gitlab_runner_registration_config, "description", replace("${var.prefix}-${var.runners_executor}", "+", "-"))
      gitlab_runner_maximum_timeout         = lookup(var.gitlab_runner_registration_config, "maximum_timeout", "")
      gitlab_runner_access_level            = lookup(var.gitlab_runner_registration_config, "access_level", "not_protected")
      runners_config                        = local.template_runner_config
      runners_executor                      = var.runners_executor
      runners_install_docker_credential_gcr = var.runners_install_docker_credential_gcr
      runners_gitlab_url                    = var.runners_gitlab_url
      runners_service_account               = google_service_account.agent.email
      runners_service_account_json          = base64decode(google_service_account_key.agent.private_key)
      runners_tags                          = join(",", distinct(concat(["gitlab"], var.docker_machine_tags)))
      runners_enable_monitoring             = var.runners_enable_monitoring

  })

  template_shutdown_script = templatefile("${path.module}/templates/shutdown-script.sh.tpl", {
    gcp_project        = var.project
    gcp_region         = var.region
    runners_gitlab_url = var.runners_gitlab_url
  })

  template_runner_config = templatefile("${path.module}/templates/runner-config.toml.tpl",
    {
      gitlab_url                     = var.runners_gitlab_url
      runners_project                = var.project
      runners_network                = var.network
      runners_subnetwork             = var.subnetwork
      runners_gcp_project            = var.project
      runners_gcp_region             = var.region
      runners_gcp_zone               = random_shuffle.zones.result[0]
      runners_machine_type           = var.runners_machine_type
      runners_disk_type              = var.runners_disk_type
      runners_disk_size              = var.runners_disk_size
      runners_tags                   = join(",", distinct(concat(["gitlab"], var.runners_tags)))
      runners_labels                 = local.agent_machine_labels
      runners_use_internal_ip        = var.runners_use_internal_ip
      docker_machine_options         = length(var.docker_machine_options) == 0 ? "" : local.docker_machine_options_string
      runners_service_account        = google_service_account.agent.email
      runners_additional_volumes     = local.runners_additional_volumes
      runners_name                   = var.runners_name
      runners_executor               = var.runners_executor
      runners_limit                  = var.runners_limit
      runners_concurrent             = var.runners_concurrent
      runners_image                  = var.runners_image
      runners_privileged             = var.runners_privileged
      runners_disable_cache          = var.runners_disable_cache
      runners_docker_runtime         = var.runners_docker_runtime
      runners_helper_image           = var.runners_helper_image
      runners_shm_size               = var.runners_shm_size
      runners_pull_policy            = var.runners_pull_policy
      runners_idle_count             = var.runners_idle_count
      runners_idle_time              = var.runners_idle_time
      runners_max_builds             = local.runners_max_builds_string
      runners_machine_autoscaling    = local.runners_machine_autoscaling
      runners_environment_vars       = jsonencode(var.runners_environment_vars)
      runners_pre_build_script       = var.runners_pre_build_script
      runners_post_build_script      = var.runners_post_build_script
      runners_pre_clone_script       = var.runners_pre_clone_script
      runners_request_concurrency    = var.runners_request_concurrency
      runners_output_limit           = var.runners_output_limit
      runners_volumes_tmpfs          = join(",", [for v in var.runners_volumes_tmpfs : format("\"%s\" = \"%s\"", v.volume, v.options)])
      runners_services_volumes_tmpfs = join(",", [for v in var.runners_services_volumes_tmpfs : format("\"%s\" = \"%s\"", v.volume, v.options)])
      bucket_name                    = local.bucket_name
      shared_cache                   = var.cache_shared
    }
  )
}
