# Terraform Kubernetes Gitlab-Runner On GKE Module

Setup Gitlab Runner on a GKE cluster using terraform. The runner is installed via the [Deimos kubernetes gitlab runner module](https://registry.terraform.io/modules/DeimosCloud/gitlab-runner/kubernetes/latest)

Ensure Kubernetes Provider and Helm Provider are configured properly https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/guides/getting-started#provider-setup

## Usage
```hcl
module "runner" {
    source            = "DeimosCloud/gitlab-ci-runner/google//modules/gke-runner"
    project           = var.project_id
    region            = var.region
    cluster_name      = var.cluster_name
    cluster_location  = var.cluster_location
    
    runner_registration_token = var.runner_registration_token
    runner_tags               = var.runner_tags
}
```

## Custom Values
To pass in custom values use `var.values_file` which specifies a path containing a valid yaml values file to pass to the Chart



<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | ~> 1.1 |
| <a name="requirement_google"></a> [google](#requirement\_google) | ~> 4.19 |
| <a name="requirement_kubernetes"></a> [kubernetes](#requirement\_kubernetes) |  ~> 2.11.0 |
| <a name="requirement_random"></a> [random](#requirement\_random) | >= 2.1.2 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_google"></a> [google](#provider\_google) | 4.19.0 |
| <a name="provider_kubernetes"></a> [kubernetes](#provider\_kubernetes) | 2.11.0 |
| <a name="provider_random"></a> [random](#provider\_random) | 3.1.3 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_cache"></a> [cache](#module\_cache) | ../cache | n/a |
| <a name="module_kubernetes_gitlab_runner"></a> [kubernetes\_gitlab\_runner](#module\_kubernetes\_gitlab\_runner) | DeimosCloud/gitlab-runner/kubernetes | ~>1.3.0 |

## Resources

| Name | Type |
|------|------|
| [google_container_node_pool.gitlab_runner_pool](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/container_node_pool) | resource |
| [google_project_iam_member.this](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/project_iam_member) | resource |
| [google_service_account.cache_admin](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/service_account) | resource |
| [google_service_account.runner_nodes](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/service_account) | resource |
| [google_service_account_key.cache_admin](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/service_account_key) | resource |
| [kubernetes_namespace.runner_namespace](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/namespace) | resource |
| [kubernetes_secret.cache_secret](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/secret) | resource |
| [random_id.random_suffix](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/id) | resource |
| [google_client_config.default](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/client_config) | data source |
| [google_container_cluster.this_cluster](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/container_cluster) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_additional_node_service_account_roles"></a> [additional\_node\_service\_account\_roles](#input\_additional\_node\_service\_account\_roles) | additional roles to grant the service account | `list(any)` | `[]` | no |
| <a name="input_additional_secrets"></a> [additional\_secrets](#input\_additional\_secrets) | additional secrets to mount into the manager pods | `list(map(string))` | `[]` | no |
| <a name="input_build_job_mount_docker_socket"></a> [build\_job\_mount\_docker\_socket](#input\_build\_job\_mount\_docker\_socket) | whether to enable docker build commands in CI jobs run on the runner. without running container in privileged mode | `bool` | `true` | no |
| <a name="input_build_job_node_selectors"></a> [build\_job\_node\_selectors](#input\_build\_job\_node\_selectors) | A map of node selectors to apply to the pods | `map(any)` | <pre>{<br>  "role": "gitlab-runner"<br>}</pre> | no |
| <a name="input_build_job_node_tolerations"></a> [build\_job\_node\_tolerations](#input\_build\_job\_node\_tolerations) | A map of node tolerations to apply to the pods as defined https://docs.gitlab.com/runner/executors/kubernetes.html#other-configtoml-settings | `map` | <pre>{<br>  "role=gitlab-runner": "NoSchedule"<br>}</pre> | no |
| <a name="input_build_job_run_container_as_user"></a> [build\_job\_run\_container\_as\_user](#input\_build\_job\_run\_container\_as\_user) | SecurityContext: runAsUser for all running job pods | `string` | `null` | no |
| <a name="input_build_job_secret_volumes"></a> [build\_job\_secret\_volumes](#input\_build\_job\_secret\_volumes) | Secret volume configuration instructs Kubernetes to use a secret that is defined in Kubernetes cluster and mount it inside the runner pods as defined https://docs.gitlab.com/runner/executors/kubernetes.html#secret-volumes | <pre>object({<br>    name       = string<br>    mount_path = string<br>    read_only  = string<br>    items      = map(string)<br>  })</pre> | <pre>{<br>  "items": {},<br>  "mount_path": null,<br>  "name": null,<br>  "read_only": null<br>}</pre> | no |
| <a name="input_cache_bucket_versioning"></a> [cache\_bucket\_versioning](#input\_cache\_bucket\_versioning) | Boolean used to enable versioning on the cache bucket, false by default. | `bool` | `false` | no |
| <a name="input_cache_create_service_account"></a> [cache\_create\_service\_account](#input\_cache\_create\_service\_account) | whether to create service account for cache | `bool` | `true` | no |
| <a name="input_cache_expiration_days"></a> [cache\_expiration\_days](#input\_cache\_expiration\_days) | Number of days before cache objects expires. | `number` | `2` | no |
| <a name="input_cache_labels"></a> [cache\_labels](#input\_cache\_labels) | The cache storage class | `map(string)` | <pre>{<br>  "role": "gitlab-runner-cache"<br>}</pre> | no |
| <a name="input_cache_location"></a> [cache\_location](#input\_cache\_location) | location of the cache bucket | `string` | `null` | no |
| <a name="input_cache_path"></a> [cache\_path](#input\_cache\_path) | path to append to the bucket url | `string` | `""` | no |
| <a name="input_cache_service_account"></a> [cache\_service\_account](#input\_cache\_service\_account) | service account that should be granted access to the cache bucket. this is used if var.cache\_create\_service\_account is set to null | `map(string)` | <pre>{<br>  "email": "",<br>  "name": ""<br>}</pre> | no |
| <a name="input_cache_shared"></a> [cache\_shared](#input\_cache\_shared) | whether cache can be shared between runners | `bool` | `true` | no |
| <a name="input_cache_storage_class"></a> [cache\_storage\_class](#input\_cache\_storage\_class) | The cache storage class | `string` | `"STANDARD"` | no |
| <a name="input_cache_type"></a> [cache\_type](#input\_cache\_type) | type of cache to use for runners | `string` | `"gcs"` | no |
| <a name="input_chart_version"></a> [chart\_version](#input\_chart\_version) | version of the gitlab runner chart to use | `string` | `null` | no |
| <a name="input_cluster_location"></a> [cluster\_location](#input\_cluster\_location) | the location where the cluster is deployed | `string` | n/a | yes |
| <a name="input_cluster_name"></a> [cluster\_name](#input\_cluster\_name) | name of the cluster to deploy the kubernetes gitlab runner in | `string` | n/a | yes |
| <a name="input_concurrent"></a> [concurrent](#input\_concurrent) | the number of jobs that can be run concurrently | `number` | `10` | no |
| <a name="input_docker_fs_group"></a> [docker\_fs\_group](#input\_docker\_fs\_group) | The fsGroup to use for docker. This is added to security context when mount\_docker\_socket is enabled | `number` | `412` | no |
| <a name="input_enable_metrics_service"></a> [enable\_metrics\_service](#input\_enable\_metrics\_service) | create service resource to allow scraping metrics via prometheus-operator serviceMonitor | `bool` | `false` | no |
| <a name="input_enable_prometheus_exporter"></a> [enable\_prometheus\_exporter](#input\_enable\_prometheus\_exporter) | enable prometheus metric exporter | `bool` | `false` | no |
| <a name="input_enable_target_auto_detection"></a> [enable\_target\_auto\_detection](#input\_enable\_target\_auto\_detection) | Configure a prometheus-operator serviceMonitor to allow autodetection of the scraping target. requires var.enable\_metrics\_service to be set to true | `bool` | `false` | no |
| <a name="input_gitlab_url"></a> [gitlab\_url](#input\_gitlab\_url) | the gitlab instance to connect to | `string` | `"https://gitlab.com/"` | no |
| <a name="input_image_pull_secrets"></a> [image\_pull\_secrets](#input\_image\_pull\_secrets) | A array of secrets that are used to authenticate Docker image pulling. | `list(string)` | `[]` | no |
| <a name="input_initial_node_count"></a> [initial\_node\_count](#input\_initial\_node\_count) | initial number of nodes that the node pool creates | `number` | `0` | no |
| <a name="input_manager_node_tolerations"></a> [manager\_node\_tolerations](#input\_manager\_node\_tolerations) | tolerations to apply to the manager pod | `list` | <pre>[<br>  {<br>    "effect": "NoSchedule",<br>    "key": "role",<br>    "operator": "Exists"<br>  }<br>]</pre> | no |
| <a name="input_manager_pod_annotations"></a> [manager\_pod\_annotations](#input\_manager\_pod\_annotations) | A map of annotations to be added to each build pod created by the Runner. The value of these can include environment variables for expansion. Pod annotations can be overwritten in each build. | `map` | `{}` | no |
| <a name="input_manager_pod_labels"></a> [manager\_pod\_labels](#input\_manager\_pod\_labels) | A map of labels to be added to each build pod created by the runner. The value of these can include environment variables for expansion. | `map` | `{}` | no |
| <a name="input_prefix"></a> [prefix](#input\_prefix) | string to be prepended to the nodes service account id and the service account for the cache | `string` | `"gitlab-runner"` | no |
| <a name="input_project"></a> [project](#input\_project) | project in which to create iam binding for the cluster node service account | `string` | n/a | yes |
| <a name="input_region"></a> [region](#input\_region) | where the resources should be deployed | `string` | n/a | yes |
| <a name="input_replicas"></a> [replicas](#input\_replicas) | the number of manager pod to create | `number` | `1` | no |
| <a name="input_run_untagged_jobs"></a> [run\_untagged\_jobs](#input\_run\_untagged\_jobs) | Specify if jobs without tags should be run. https://docs.gitlab.com/ce/ci/runners/#runner-is-allowed-to-run-untagged-jobs | `bool` | `true` | no |
| <a name="input_runner_create_service_account"></a> [runner\_create\_service\_account](#input\_runner\_create\_service\_account) | whether a service account should be created for the runner. if this is set to false then the var.serviceAccountname is used | `bool` | `true` | no |
| <a name="input_runner_image"></a> [runner\_image](#input\_runner\_image) | the docker image to use for the runner | `string` | `"gitlab/gitlab-runner:alpine-bleeding"` | no |
| <a name="input_runner_locked"></a> [runner\_locked](#input\_runner\_locked) | whether the runner is locked to a particular project or group | `bool` | `true` | no |
| <a name="input_runner_name"></a> [runner\_name](#input\_runner\_name) | name of the runner | `string` | n/a | yes |
| <a name="input_runner_namespace"></a> [runner\_namespace](#input\_runner\_namespace) | kubernetes namespace in which to create the runner | `string` | `"runner"` | no |
| <a name="input_runner_node_pool_disk_size_gb"></a> [runner\_node\_pool\_disk\_size\_gb](#input\_runner\_node\_pool\_disk\_size\_gb) | (Optional) Size of the disk attached to each node, specified in GB. The smallest allowed disk size is 10GB | `number` | `30` | no |
| <a name="input_runner_node_pool_disk_type"></a> [runner\_node\_pool\_disk\_type](#input\_runner\_node\_pool\_disk\_type) | (Optional) Type of the disk attached to each node (e.g. 'pd-standard', 'pd-balanced' or 'pd-ssd'). | `string` | `"pd-standard"` | no |
| <a name="input_runner_node_pool_image_type"></a> [runner\_node\_pool\_image\_type](#input\_runner\_node\_pool\_image\_type) | (optional) The type of image to be used | `string` | `"COS"` | no |
| <a name="input_runner_node_pool_machine_type"></a> [runner\_node\_pool\_machine\_type](#input\_runner\_node\_pool\_machine\_type) | type of compute machine used for the nodes in the runner node pool | `string` | `"n1-standard-2"` | no |
| <a name="input_runner_node_pool_max_node_count"></a> [runner\_node\_pool\_max\_node\_count](#input\_runner\_node\_pool\_max\_node\_count) | the maximum number of nodes that can be present in the node pool (autoscaling controls) | `number` | `3` | no |
| <a name="input_runner_node_pool_min_node_count"></a> [runner\_node\_pool\_min\_node\_count](#input\_runner\_node\_pool\_min\_node\_count) | the minimum number of nodes that can be present in the node pool (autoscaling controls) | `number` | `0` | no |
| <a name="input_runner_node_pool_name"></a> [runner\_node\_pool\_name](#input\_runner\_node\_pool\_name) | name of the runner node pool | `string` | `null` | no |
| <a name="input_runner_node_pool_node_labels"></a> [runner\_node\_pool\_node\_labels](#input\_runner\_node\_pool\_node\_labels) | labels for nodes in the runner node pool | `map(any)` | <pre>{<br>  "role": "gitlab-runner"<br>}</pre> | no |
| <a name="input_runner_node_pool_node_taints"></a> [runner\_node\_pool\_node\_taints](#input\_runner\_node\_pool\_node\_taints) | taints to be applied to the nodes in the runner node pool | `list(map(string))` | <pre>[<br>  {<br>    "effect": "NO_SCHEDULE",<br>    "key": "role",<br>    "value": "gitlab-runner"<br>  }<br>]</pre> | no |
| <a name="input_runner_node_pool_oauth_scopes"></a> [runner\_node\_pool\_oauth\_scopes](#input\_runner\_node\_pool\_oauth\_scopes) | (Optional) Scopes that are used by NAP when creating node pools. | `list(string)` | <pre>[<br>  "https://www.googleapis.com/auth/cloud-platform"<br>]</pre> | no |
| <a name="input_runner_node_pool_zones"></a> [runner\_node\_pool\_zones](#input\_runner\_node\_pool\_zones) | The zones to host the cluster in (optional if regional cluster / required if zonal) | `list(string)` | `null` | no |
| <a name="input_runner_protected"></a> [runner\_protected](#input\_runner\_protected) | n/a | `bool` | `true` | no |
| <a name="input_runner_registration_token"></a> [runner\_registration\_token](#input\_runner\_registration\_token) | runner registration token | `string` | n/a | yes |
| <a name="input_runner_release_name"></a> [runner\_release\_name](#input\_runner\_release\_name) | helm release name | `string` | `"gitlab-runner"` | no |
| <a name="input_runner_service_account_clusterwide_access"></a> [runner\_service\_account\_clusterwide\_access](#input\_runner\_service\_account\_clusterwide\_access) | whether the service account should be granted cluster wide access or access is restricted to the specified namespace | `bool` | `false` | no |
| <a name="input_runner_tags"></a> [runner\_tags](#input\_runner\_tags) | comma separated list of tags to be applied to the runner | `string` | `null` | no |
| <a name="input_runner_token"></a> [runner\_token](#input\_runner\_token) | token of already registered runer. to use this var.runner\_registration\_token must be set to null | `string` | `null` | no |
| <a name="input_unregister_runners"></a> [unregister\_runners](#input\_unregister\_runners) | whether runners should be unregistered when pool is deprovisioned | `bool` | `true` | no |
| <a name="input_values_file"></a> [values\_file](#input\_values\_file) | path to yaml file containing additional values for the runner | `string` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_cache_bucket_name"></a> [cache\_bucket\_name](#output\_cache\_bucket\_name) | name of the gcs bucket used a s runner cache |
| <a name="output_namespace"></a> [namespace](#output\_namespace) | namespace in which the runners were created |
| <a name="output_node_pool_name"></a> [node\_pool\_name](#output\_node\_pool\_name) | name of the node pool where the runner pods are created |
<!-- END_TF_DOCS -->
