concurrent = ${runners_concurrent}
check_interval = 0

[[runners]]
  name = "${runners_name}"
  url = "${gitlab_url}"
  token = "__TOKEN_BE_REPLACED__"
  executor = "${runners_executor}"
  environment = ${runners_environment_vars}
  pre_build_script = ${runners_pre_build_script}
  post_build_script = ${runners_post_build_script}
  pre_clone_script = ${runners_pre_clone_script}
  request_concurrency = ${runners_request_concurrency}
  output_limit = ${runners_output_limit}
  limit = ${runners_limit}
  [runners.docker]
    tls_verify = false
    image = "${runners_image}"
    privileged = ${runners_privileged}
    disable_cache = ${runners_disable_cache}
    volumes = ["/cache" ${runners_additional_volumes}]
    shm_size = ${runners_shm_size}
    pull_policy = "${runners_pull_policy}"
    runtime = "${runners_docker_runtime}"
    helper_image = "${runners_helper_image}"
  [runners.docker.tmpfs]
    ${runners_volumes_tmpfs}
  [runners.docker.services_tmpfs]
    ${runners_services_volumes_tmpfs}
  [runners.cache]
    Type = "gcs"
    Shared = ${shared_cache}
    [runners.cache.gcs]
      CredentialsFile = "/etc/gitlab-runner/service-account.json"
      BucketName = "${bucket_name}"
  [runners.machine]
    IdleCount = ${runners_idle_count}
    IdleTime = ${runners_idle_time}
    ${runners_max_builds}
    MachineDriver = "google"
    MachineName = "runner-%s"
    MachineOptions = [
      "google-project=${runners_gcp_project}" ,
      "google-machine-type=${runners_machine_type}" ,
      "google-network=${runners_network}" ,
      %{~ if runners_subnetwork != "" ~}
      "google-subnetwork=${runners_subnetwork}" ,
      %{~ endif ~}
      "google-zone=${runners_gcp_zone}" ,
      "google-service-account=${runners_service_account}" ,
      "google-scopes=https://www.googleapis.com/auth/cloud-platform" ,
      "google-disk-type=${runners_disk_type}" ,
      "google-disk-size=${runners_disk_size}" ,
      "google-tags=${runners_tags}",
      %{~ if runners_use_internal_ip ~}
      "google-use-internal-ip",
      %{~ endif ~}
      ${docker_machine_options}
    ]

${runners_machine_autoscaling}
