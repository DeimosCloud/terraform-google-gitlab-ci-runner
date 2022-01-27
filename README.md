# GCP GitLab Runner

This [Terraform](https://www.terraform.io/) modules creates a [GitLab CI runner](https://docs.gitlab.com/runner/). 

The runners created by the module use preemptible instances by default for running the builds using the `docker+machine` executor.

- Shared cache in GCS with life cycle management to clear objects after x days.
- Runner agents registered automatically.

The runner supports 2 main scenarios:

### GitLab CI docker-machine runner 

In this scenario the runner agent is running on a GCP Compute Instance and runners are created by [docker machine](https://docs.gitlab.com/runner/configuration/autoscale.html) using preemptible instances. Runners will scale automatically based on the configuration. The module creates a GCS cache by default, which is shared across runners (preemptible instances). 

### GitLab CI docker runner

In this scenario _not_ docker machine is used but docker to schedule the builds. Builds will run on the same compute instance as the agent. 

## Autoscaling
Both docker-machine runner and docker runners autoscale using GCP Custom metrics. The runner publishes running jobs metrics to stackdriver which is then used to scale up/down the number of active runners. `var.runners_min_replicas` and `var.runners_max_replicas` defined variables for the minimum and maximum number of runners respectively. It uses Google Managed Instance Group Autoscaler to scale when the average of running jobs exceeds `var.runners_concurrent - 2`. 

> NOTE: If runners are set to use internal IPs, a Cloud NAT must be deployed for runners to be able to reach internet

### GitLab runner token configuration

The runner is registered on initial deployment. Each new runner registers itself with the same description and tag. To register the runner automatically set the variable `gitlab_runner_registration_config["registration_token"]`. This token value can be found in your GitLab project, group, or global settings. For a generic runner you can find the token in the admin section. By default the runner will be locked to the target project, not run untagged. Below is an example of the configuration map.

```hcl
gitlab_runner_registration_config = {
  registration_token = "Required: <registration token>"
  tag_list           = "Optional: <your tags, comma separated>"
  description        = "Optional: <some description>"
  locked_to_project  = "optional: true"
  run_untagged       = "Optional: false"
  maximum_timeout    = "Optional: 3600"
  access_level       = "Optional: <not_protected OR ref_protected, ref_protected runner will only run on pipelines triggered on protected branches. Defaults to not_protected>"
}
```

### GitLab runner cache

By default the module creates a a cache for the runner in Google Cloud Storage. Old objects are automatically removed via a configurable life cycle policy on the bucket.


## Usage


```hcl
module "runner" {
  source  = "DeimosCloud/gitlab-ci-runner/google"

  network = "default"
  region  = "europe-west1"
  project = local.project_id

  runners_name       = "docker-default"
  runners_gitlab_url = "https://gitlab.com"

  gitlab_runner_registration_config = {
    registration_token = "my-token"
    tag_list           = "docker"
  }

}
```

## Contributing

Report issues/questions/feature requests on in the issues section.

Full contributing guidelines are covered [here](CONTRIBUTING.md).



<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 0.14 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_google"></a> [google](#provider\_google) | n/a |
| <a name="provider_random"></a> [random](#provider\_random) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [google_compute_firewall.docker_machine](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_firewall) | resource |
| [google_compute_firewall.internet](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_firewall) | resource |
| [google_compute_firewall.ssh](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_firewall) | resource |
| [google_compute_instance_template.this](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_instance_template) | resource |
| [google_compute_region_autoscaler.this](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_region_autoscaler) | resource |
| [google_compute_region_instance_group_manager.this](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_region_instance_group_manager) | resource |
| [google_monitoring_metric_descriptor.jobs](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/monitoring_metric_descriptor) | resource |
| [google_project_iam_member.this](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/project_iam_member) | resource |
| [google_service_account.agent](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/service_account) | resource |
| [google_service_account.runner](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/service_account) | resource |
| [google_service_account_iam_member.agent_runner](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/service_account_iam_member) | resource |
| [google_service_account_key.agent](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/service_account_key) | resource |
| [google_storage_bucket.cache](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/storage_bucket) | resource |
| [google_storage_bucket_iam_member.cache-member](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/storage_bucket_iam_member) | resource |
| [random_id.this](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/id) | resource |
| [random_shuffle.zones](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/shuffle) | resource |
| [google_compute_network.this](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/compute_network) | data source |
| [google_compute_zones.available](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/compute_zones) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_cache_bucket_versioning"></a> [cache\_bucket\_versioning](#input\_cache\_bucket\_versioning) | Boolean used to enable versioning on the cache bucket, false by default. | `bool` | `false` | no |
| <a name="input_cache_expiration_days"></a> [cache\_expiration\_days](#input\_cache\_expiration\_days) | Number of days before cache objects expires. | `number` | `2` | no |
| <a name="input_cache_location"></a> [cache\_location](#input\_cache\_location) | The location where to create the cache bucket in. If not specified, it defaults to the region | `any` | `null` | no |
| <a name="input_cache_shared"></a> [cache\_shared](#input\_cache\_shared) | Enables cache sharing between runners. | `bool` | `true` | no |
| <a name="input_cache_storage_class"></a> [cache\_storage\_class](#input\_cache\_storage\_class) | The cache storage class | `string` | `"STANDARD"` | no |
| <a name="input_create_cache_bucket"></a> [create\_cache\_bucket](#input\_create\_cache\_bucket) | Creates a cache cloud storage bucket if true | `bool` | `true` | no |
| <a name="input_docker_machine_disk_size"></a> [docker\_machine\_disk\_size](#input\_docker\_machine\_disk\_size) | The disk size for the docker-machine instances. | `number` | `20` | no |
| <a name="input_docker_machine_disk_type"></a> [docker\_machine\_disk\_type](#input\_docker\_machine\_disk\_type) | The disk Type for docker-machine instances. | `string` | `"pd-standard"` | no |
| <a name="input_docker_machine_download_url"></a> [docker\_machine\_download\_url](#input\_docker\_machine\_download\_url) | Full url pointing to a linux x64 distribution of docker machine. | `string` | `"https://gitlab-docker-machine-downloads.s3.amazonaws.com/main/docker-machine-Linux-x86_64"` | no |
| <a name="input_docker_machine_image"></a> [docker\_machine\_image](#input\_docker\_machine\_image) | A GCP custom image to use for spinning up docker-machines | `string` | `""` | no |
| <a name="input_docker_machine_machine_type"></a> [docker\_machine\_machine\_type](#input\_docker\_machine\_machine\_type) | The Machine Type for the docker-machine instances. | `string` | `"f1-micro"` | no |
| <a name="input_docker_machine_options"></a> [docker\_machine\_options](#input\_docker\_machine\_options) | List of additional options for the docker machine config. Each element of this list must be a key=value pair. E.g. '["google-zone=a"]' | `list(string)` | `[]` | no |
| <a name="input_docker_machine_preemptible"></a> [docker\_machine\_preemptible](#input\_docker\_machine\_preemptible) | If true, docker-machine instances will be premptible | `bool` | `false` | no |
| <a name="input_docker_machine_tags"></a> [docker\_machine\_tags](#input\_docker\_machine\_tags) | Additional Network tags to be attached to the docker-machine instances. | `list(string)` | `[]` | no |
| <a name="input_docker_machine_use_internal_ip"></a> [docker\_machine\_use\_internal\_ip](#input\_docker\_machine\_use\_internal\_ip) | If true, docker-machine instances will have only internal IPs. | `bool` | `false` | no |
| <a name="input_gitlab_runner_registration_config"></a> [gitlab\_runner\_registration\_config](#input\_gitlab\_runner\_registration\_config) | Configuration used to register the runner. Available at https://docs.gitlab.com/ee/api/runners.html#register-a-new-runner. | `map` | <pre>{<br>  "access_level": "not_protected",<br>  "description": "",<br>  "locked_to_project": "",<br>  "maximum_timeout": "",<br>  "registration_token": "",<br>  "run_untagged": "",<br>  "tag_list": ""<br>}</pre> | no |
| <a name="input_gitlab_runner_version"></a> [gitlab\_runner\_version](#input\_gitlab\_runner\_version) | Version of the GitLab runner. Defaults to latest | `string` | `""` | no |
| <a name="input_labels"></a> [labels](#input\_labels) | Map of labels that will be added to created resources | `map(string)` | `{}` | no |
| <a name="input_network"></a> [network](#input\_network) | The target VPC for the docker-machine and runner instances. | `string` | `"default"` | no |
| <a name="input_prefix"></a> [prefix](#input\_prefix) | The prefix to apply to all GCP resource names (e.g. <prefix>-runner, <prefix>-agent-1). | `string` | `"ci"` | no |
| <a name="input_project"></a> [project](#input\_project) | The GCP project to deploy the runner into. | `string` | n/a | yes |
| <a name="input_region"></a> [region](#input\_region) | The GCP region to deploy the runner into. | `string` | n/a | yes |
| <a name="input_runner_additional_service_account_roles"></a> [runner\_additional\_service\_account\_roles](#input\_runner\_additional\_service\_account\_roles) | Additional roles to pass to the Runner service account | `list(string)` | `[]` | no |
| <a name="input_runners_additional_volumes"></a> [runners\_additional\_volumes](#input\_runners\_additional\_volumes) | Additional volumes that will be used in the runner config.toml, e.g Docker socket | `list(any)` | `[]` | no |
| <a name="input_runners_allow_ssh_access"></a> [runners\_allow\_ssh\_access](#input\_runners\_allow\_ssh\_access) | Enables SSH Access to the runner instances. | `bool` | `true` | no |
| <a name="input_runners_concurrent"></a> [runners\_concurrent](#input\_runners\_concurrent) | Concurrent value for the runners, will be used in the runner config.toml. Limits how many jobs globally can be run concurrently when running docker-machine. | `number` | `10` | no |
| <a name="input_runners_disable_cache"></a> [runners\_disable\_cache](#input\_runners\_disable\_cache) | Runners will not use local cache, will be used in the runner config.toml | `bool` | `false` | no |
| <a name="input_runners_disk_size"></a> [runners\_disk\_size](#input\_runners\_disk\_size) | The size of the created gitlab runner instances in GB. | `number` | `20` | no |
| <a name="input_runners_disk_type"></a> [runners\_disk\_type](#input\_runners\_disk\_type) | The Disk type of the gitlab runner instances | `string` | `"pd-standard"` | no |
| <a name="input_runners_docker_runtime"></a> [runners\_docker\_runtime](#input\_runners\_docker\_runtime) | docker runtime for runners, will be used in the runner config.toml | `string` | `""` | no |
| <a name="input_runners_enable_monitoring"></a> [runners\_enable\_monitoring](#input\_runners\_enable\_monitoring) | Installs Stackdriver monitoring Agent on runner Instances to collect metrics. | `bool` | `true` | no |
| <a name="input_runners_environment_vars"></a> [runners\_environment\_vars](#input\_runners\_environment\_vars) | Environment variables during build execution, e.g. KEY=Value, see runner-public example. Will be used in the runner config.toml | `list(string)` | `[]` | no |
| <a name="input_runners_executor"></a> [runners\_executor](#input\_runners\_executor) | The executor to use. Currently supports `docker+machine` or `docker`. | `string` | `"docker+machine"` | no |
| <a name="input_runners_gitlab_url"></a> [runners\_gitlab\_url](#input\_runners\_gitlab\_url) | URL of the GitLab instance to connect to. | `string` | `"https://gitlab.com"` | no |
| <a name="input_runners_helper_image"></a> [runners\_helper\_image](#input\_runners\_helper\_image) | Overrides the default helper image used to clone repos and upload artifacts, will be used in the runner config.toml | `string` | `""` | no |
| <a name="input_runners_idle_count"></a> [runners\_idle\_count](#input\_runners\_idle\_count) | (docker-machine) Idle count of the runners, will be used in the runner config.toml. | `number` | `0` | no |
| <a name="input_runners_idle_time"></a> [runners\_idle\_time](#input\_runners\_idle\_time) | (docker-machine) Idle time of the runners, will be used in the runner config.toml. | `number` | `600` | no |
| <a name="input_runners_image"></a> [runners\_image](#input\_runners\_image) | Image to run builds, will be used in the runner config.toml | `string` | `"docker:19.03"` | no |
| <a name="input_runners_install_docker_credential_gcr"></a> [runners\_install\_docker\_credential\_gcr](#input\_runners\_install\_docker\_credential\_gcr) | Install docker\_credential\_gcr inside `startup_script_pre_install` script | `bool` | `true` | no |
| <a name="input_runners_limit"></a> [runners\_limit](#input\_runners\_limit) | Limit for the runners, will be used in the runner config.toml. | `number` | `0` | no |
| <a name="input_runners_machine_autoscaling"></a> [runners\_machine\_autoscaling](#input\_runners\_machine\_autoscaling) | (docker-machine) Set autoscaling parameters based on periods, see https://docs.gitlab.com/runner/configuration/advanced-configuration.html#the-runnersmachine-section | <pre>list(object({<br>    periods    = list(string)<br>    idle_count = number<br>    idle_time  = number<br>    timezone   = string<br>  }))</pre> | `[]` | no |
| <a name="input_runners_machine_type"></a> [runners\_machine\_type](#input\_runners\_machine\_type) | Instance type used for the GitLab runner. | `string` | `"n1-standard-1"` | no |
| <a name="input_runners_max_builds"></a> [runners\_max\_builds](#input\_runners\_max\_builds) | (docker-machine) Max builds for each runner after which it will be removed, will be used in the runner config.toml. By default set to 0, no maxBuilds will be set in the configuration. | `number` | `0` | no |
| <a name="input_runners_max_growth_rate"></a> [runners\_max\_growth\_rate](#input\_runners\_max\_growth\_rate) | (docker-machine) The maximum number of machines that can be added to the runner in parallel. Default is 0 (no limit). | `number` | `0` | no |
| <a name="input_runners_max_replicas"></a> [runners\_max\_replicas](#input\_runners\_max\_replicas) | The maximum number of runners to spin up.For docker+machine, this is the max number of instances that will run docker-machine. For docker, this is the maximum number of runner instances. | `number` | `1` | no |
| <a name="input_runners_metadata"></a> [runners\_metadata](#input\_runners\_metadata) | (Optional) Metadata key/value pairs to make available from within instances created from this template. | `map` | `{}` | no |
| <a name="input_runners_min_replicas"></a> [runners\_min\_replicas](#input\_runners\_min\_replicas) | The minimum number of runners to spin up. For docker+machine, this is the min number of instances that will run docker-machine. For docker, this is the minimum number of runner instances | `number` | `1` | no |
| <a name="input_runners_name"></a> [runners\_name](#input\_runners\_name) | Name of the runner, will be used in the runner config.toml. | `string` | n/a | yes |
| <a name="input_runners_output_limit"></a> [runners\_output\_limit](#input\_runners\_output\_limit) | Sets the maximum build log size in kilobytes, by default set to 4096 (4MB) | `number` | `4096` | no |
| <a name="input_runners_post_build_script"></a> [runners\_post\_build\_script](#input\_runners\_post\_build\_script) | Commands to be executed on the Runner just after executing the build, but before executing after\_script. | `string` | `"\"\""` | no |
| <a name="input_runners_pre_build_script"></a> [runners\_pre\_build\_script](#input\_runners\_pre\_build\_script) | Script to execute in the pipeline just before the build, will be used in the runner config.toml | `string` | `"\"\""` | no |
| <a name="input_runners_pre_clone_script"></a> [runners\_pre\_clone\_script](#input\_runners\_pre\_clone\_script) | Commands to be executed on the Runner before cloning the Git repository. this can be used to adjust the Git client configuration first, for example. | `string` | `"\"\""` | no |
| <a name="input_runners_preemptible"></a> [runners\_preemptible](#input\_runners\_preemptible) | If true, runner compute instances will be premptible | `bool` | `true` | no |
| <a name="input_runners_privileged"></a> [runners\_privileged](#input\_runners\_privileged) | Runners will run in privileged mode, will be used in the runner config.toml | `bool` | `true` | no |
| <a name="input_runners_pull_policy"></a> [runners\_pull\_policy](#input\_runners\_pull\_policy) | pull\_policy for the runners, will be used in the runner config.toml | `string` | `"always"` | no |
| <a name="input_runners_request_concurrency"></a> [runners\_request\_concurrency](#input\_runners\_request\_concurrency) | Limit number of concurrent requests for new jobs from GitLab (default 1) | `number` | `1` | no |
| <a name="input_runners_root_size"></a> [runners\_root\_size](#input\_runners\_root\_size) | Runner instance root size in GB. | `number` | `16` | no |
| <a name="input_runners_services_volumes_tmpfs"></a> [runners\_services\_volumes\_tmpfs](#input\_runners\_services\_volumes\_tmpfs) | n/a | <pre>list(object({<br>    volume  = string<br>    options = string<br>  }))</pre> | `[]` | no |
| <a name="input_runners_shm_size"></a> [runners\_shm\_size](#input\_runners\_shm\_size) | shm\_size for the runners, will be used in the runner config.toml | `number` | `0` | no |
| <a name="input_runners_ssh_allowed_cidr_blocks"></a> [runners\_ssh\_allowed\_cidr\_blocks](#input\_runners\_ssh\_allowed\_cidr\_blocks) | List of CIDR blocks to allow SSH Access to the gitlab runner instance. | `list(string)` | <pre>[<br>  "0.0.0.0/0"<br>]</pre> | no |
| <a name="input_runners_tags"></a> [runners\_tags](#input\_runners\_tags) | Additional Network tags to be attached to the Gitlab Runner. | `list(string)` | `[]` | no |
| <a name="input_runners_target_autoscale_cpu_utilization"></a> [runners\_target\_autoscale\_cpu\_utilization](#input\_runners\_target\_autoscale\_cpu\_utilization) | The target CPU utilization that the autoscaler should maintain. If runner CPU utilization gets above this, a new runner is created until runners\_max\_replicas is reached | `number` | `0.9` | no |
| <a name="input_runners_use_internal_ip"></a> [runners\_use\_internal\_ip](#input\_runners\_use\_internal\_ip) | Restrict runners to the use of a Internal IP address. NOTE: NAT Gateway must be deployed in your network so that Runners can access resources on the internet | `bool` | `false` | no |
| <a name="input_runners_volumes_tmpfs"></a> [runners\_volumes\_tmpfs](#input\_runners\_volumes\_tmpfs) | n/a | <pre>list(object({<br>    volume  = string<br>    options = string<br>  }))</pre> | `[]` | no |
| <a name="input_startup_script_post_install"></a> [startup\_script\_post\_install](#input\_startup\_script\_post\_install) | Startup script snippet to insert after GitLab runner install | `string` | `""` | no |
| <a name="input_startup_script_pre_install"></a> [startup\_script\_pre\_install](#input\_startup\_script\_pre\_install) | Startup script snippet to insert before GitLab runner install | `string` | `""` | no |
| <a name="input_subnetwork"></a> [subnetwork](#input\_subnetwork) | Subnetwork used for hosting the gitlab-runners. | `string` | `""` | no |

## Outputs

No outputs.
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
