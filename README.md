# GCP GitLab Runner

A Terraform module for configuring a GCP-based GitLab CI Runner.

This runner is configured to use the docker+machine executor which allows the infrastructure to be scaled up and down as demand requires.  The minimum cost (during zero activity) is the cost of an f1-micro instance.

The long-running runner instance runs under a `gitlab-ci-runner` service account.  This account will be granted all required permissions to spawn agent instances on demand.

The agent instances run under a `gitlab-ci-agent` service account.  This account will need to be granted any privileges required to perform build and deploy activities.

# Usage

See examples for more detail on how to configure this module.

## Doc generation

Code formatting and documentation for variables and outputs is generated using [pre-commit-terraform hooks](https://github.com/antonbabenko/pre-commit-terraform) which uses [terraform-docs](https://github.com/segmentio/terraform-docs).


And install `terraform-docs` with
```bash
go get github.com/segmentio/terraform-docs
```
or
```bash
brew install terraform-docs.
```

## Contributing

Report issues/questions/feature requests on in the issues section.

Full contributing guidelines are covered [here](CONTRIBUTING.md).

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| terraform | >= 0.12 |

## Providers

| Name | Version |
|------|---------|
| google | n/a |
| random | n/a |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| allow\_ssh | If true, ssh Port is allowed on instances in the firewall | `bool` | `true` | no |
| cache\_bucket\_set\_random\_suffix | Append the cache bucket name with a random string suffix | `bool` | `false` | no |
| cache\_bucket\_versioning | Boolean used to enable versioning on the cache bucket, false by default. | `bool` | `false` | no |
| cache\_expiration\_days | Number of days before cache objects expires. | `number` | `2` | no |
| cache\_location | The location where to create the cache bucket in. If not specified, it defaults to the region | `any` | `null` | no |
| cache\_shared | Enables cache sharing between runners, false by default. | `bool` | `false` | no |
| cache\_storage\_class | The cache storage class | `string` | `"STANDARD"` | no |
| create\_cache\_bucket | Creates a cache cloud storage bucket if true | `bool` | `true` | no |
| docker\_machine\_disk\_size | The disk size of the instances created by docker-machine. | `number` | `20` | no |
| docker\_machine\_disk\_type | The disk Type for the instances created by docker-machine. | `string` | `"pd-standard"` | no |
| docker\_machine\_download\_url | Full url pointing to a linux x64 distribution of docker machine. | `string` | `"https://gitlab-docker-machine-downloads.s3.amazonaws.com/main/docker-machine-Linux-x86_64"` | no |
| docker\_machine\_machine\_type | The Machine Type for the instances created by docker-machine. | `string` | `"n2-standard-2"` | no |
| docker\_machine\_options | List of additional options for the docker machine config. Each element of this list must be a key=value pair. E.g. '["google-zone=a"]' | `list(string)` | `[]` | no |
| docker\_machine\_tags | Additional Network tags to be attached to the instances created by docker-machine. | `list(string)` | `[]` | no |
| docker\_machine\_use\_internal\_ip | If true, all instances created by docker-machine will have only internal IPs. | `bool` | `true` | no |
| enable\_gitlab\_runner\_ssh\_access | Enables SSH Access to the gitlab runner instance. | `bool` | `false` | no |
| enable\_ping | Allow ICMP Ping to the compute instances. | `bool` | `false` | no |
| gitlab\_runner\_registration\_config | Configuration used to register the runner. Available at https://docs.gitlab.com/ee/api/runners.html#register-a-new-runner. | `map` | <pre>{<br>  "access_level": "not_protected",<br>  "description": "",<br>  "locked_to_project": "",<br>  "maximum_timeout": "",<br>  "registration_token": "",<br>  "run_untagged": "",<br>  "tag_list": ""<br>}</pre> | no |
| gitlab\_runner\_ssh\_cidr\_blocks | List of CIDR blocks to allow SSH Access to the gitlab runner instance. | `list(string)` | `[]` | no |
| gitlab\_runner\_version | Version of the GitLab runner. Defaults to latest | `string` | `""` | no |
| labels | Map of labels that will be added to created resources | `map(string)` | `{}` | no |
| machine\_type | Instance type used for the GitLab runner. | `string` | `"f1-micro"` | no |
| network | The target VPC for the docker-machine and runner instances. | `string` | `"default"` | no |
| prefix | The prefix to apply to all GCP resource names (e.g. <prefix>-runner, <prefix>-agent-1). | `string` | `"ci"` | no |
| project | The GCP project to deploy the runner into. | `string` | n/a | yes |
| region | The GCP region to deploy the runner into. | `string` | n/a | yes |
| runners\_additional\_volumes | Additional volumes that will be used in the runner config.toml, e.g Docker socket | `list(any)` | `[]` | no |
| runners\_concurrent | Concurrent value for the runners, will be used in the runner config.toml. | `number` | `10` | no |
| runners\_disable\_cache | Runners will not use local cache, will be used in the runner config.toml | `bool` | `false` | no |
| runners\_disk\_size | The size of the created gitlab runner instances in GB. | `number` | `20` | no |
| runners\_disk\_type | The Disk type of the gitlab runner instances | `string` | `"pd-standard"` | no |
| runners\_docker\_runtime | docker runtime for runners, will be used in the runner config.toml | `string` | `""` | no |
| runners\_ebs\_optimized | Enable runners to be EBS-optimized. | `bool` | `true` | no |
| runners\_environment\_vars | Environment variables during build execution, e.g. KEY=Value, see runner-public example. Will be used in the runner config.toml | `list(string)` | `[]` | no |
| runners\_executor | The executor to use. Currently supports `docker+machine` or `docker`. | `string` | `"docker+machine"` | no |
| runners\_gitlab\_url | URL of the GitLab instance to connect to. | `string` | `"https://gitlab.com"` | no |
| runners\_helper\_image | Overrides the default helper image used to clone repos and upload artifacts, will be used in the runner config.toml | `string` | `""` | no |
| runners\_idle\_count | Idle count of the runners, will be used in the runner config.toml. | `number` | `0` | no |
| runners\_idle\_time | Idle time of the runners, will be used in the runner config.toml. | `number` | `600` | no |
| runners\_image | Image to run builds, will be used in the runner config.toml | `string` | `"docker:18.03.1-ce"` | no |
| runners\_install\_docker\_credential\_gcr | Install docker\_credential\_gcr inside `startup_script_pre_install` script | `bool` | `false` | no |
| runners\_limit | Limit for the runners, will be used in the runner config.toml. | `number` | `0` | no |
| runners\_machine\_autoscaling | Set autoscaling parameters based on periods, see https://docs.gitlab.com/runner/configuration/advanced-configuration.html#the-runnersmachine-section | <pre>list(object({<br>    periods    = list(string)<br>    idle_count = number<br>    idle_time  = number<br>    timezone   = string<br>  }))</pre> | `[]` | no |
| runners\_max\_builds | Max builds for each runner after which it will be removed, will be used in the runner config.toml. By default set to 0, no maxBuilds will be set in the configuration. | `number` | `0` | no |
| runners\_max\_replicas | The maximum number of runners to spin up. Note that this is not the agent used in the docker+machine setup. Runners can use docker or docker+machine setup | `number` | `1` | no |
| runners\_metadata | (Optional) Metadata key/value pairs to make available from within instances created from this template. | `map` | `{}` | no |
| runners\_min\_replicas | The minimum number of runners to spin up. Note that this is not the agent used in the docker+machine setup. Runners can use docker or docker+machine setup | `number` | `1` | no |
| runners\_monitoring | Enable detailed cloudwatch monitoring for spot instances. | `bool` | `false` | no |
| runners\_name | Name of the runner, will be used in the runner config.toml. | `string` | n/a | yes |
| runners\_off\_peak\_idle\_count | Deprecated, please use `runners_machine_autoscaling`. Off peak idle count of the runners, will be used in the runner config.toml. | `number` | `-1` | no |
| runners\_off\_peak\_idle\_time | Deprecated, please use `runners_machine_autoscaling`. Off peak idle time of the runners, will be used in the runner config.toml. | `number` | `-1` | no |
| runners\_off\_peak\_periods | Deprecated, please use `runners_machine_autoscaling`. Off peak periods of the runners, will be used in the runner config.toml. | `string` | `null` | no |
| runners\_off\_peak\_timezone | Deprecated, please use `runners_machine_autoscaling`. Off peak idle time zone of the runners, will be used in the runner config.toml. | `string` | `null` | no |
| runners\_output\_limit | Sets the maximum build log size in kilobytes, by default set to 4096 (4MB) | `number` | `4096` | no |
| runners\_post\_build\_script | Commands to be executed on the Runner just after executing the build, but before executing after\_script. | `string` | `"\"\""` | no |
| runners\_pre\_build\_script | Script to execute in the pipeline just before the build, will be used in the runner config.toml | `string` | `"\"\""` | no |
| runners\_pre\_clone\_script | Commands to be executed on the Runner before cloning the Git repository. this can be used to adjust the Git client configuration first, for example. | `string` | `"\"\""` | no |
| runners\_preemptible | If true, runner compute instances will be premptible | `bool` | `false` | no |
| runners\_privileged | Runners will run in privileged mode, will be used in the runner config.toml | `bool` | `true` | no |
| runners\_pull\_policy | pull\_policy for the runners, will be used in the runner config.toml | `string` | `"always"` | no |
| runners\_request\_concurrency | Limit number of concurrent requests for new jobs from GitLab (default 1) | `number` | `1` | no |
| runners\_root\_size | Runner instance root size in GB. | `number` | `16` | no |
| runners\_services\_volumes\_tmpfs | n/a | <pre>list(object({<br>    volume  = string<br>    options = string<br>  }))</pre> | `[]` | no |
| runners\_shm\_size | shm\_size for the runners, will be used in the runner config.toml | `number` | `0` | no |
| runners\_tags | Additional Network tags to be attached to the Gitlab Runner. | `list(string)` | `[]` | no |
| runners\_use\_private\_address | Restrict runners to the use of a private IP address | `bool` | `true` | no |
| runners\_volumes\_tmpfs | n/a | <pre>list(object({<br>    volume  = string<br>    options = string<br>  }))</pre> | `[]` | no |
| startup\_script\_post\_install | Startup script snippet to insert after GitLab runner install | `string` | `""` | no |
| startup\_script\_pre\_install | Startup script snippet to insert before GitLab runner install | `string` | `""` | no |
| subnetwork | Subnetwork used for hosting the gitlab-runners. | `string` | `""` | no |

## Outputs

No output.

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
