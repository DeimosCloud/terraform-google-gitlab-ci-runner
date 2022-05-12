# Terraform Google Cloud Storage Bucket For gitlab Runner Module

Setup a GCS bucket as cache for gitlab-ci

## Usage
```
module "cache" {
  source                  = "DeimosCloud/gitlab-ci-runner/google/modules/cache"
  count                   = local.count
  cache_bucket_name       = var.cache_bucket_name
  cache_location          = var.cache_location
  labels                  = var.cache_labels
  cache_storage_class     = var.cache_storage_class
  cache_bucket_versioning = var.cache_bucket_versioning
  cache_expiration_days   = var.cache_expiration_days
  prefix                  = var.prefix
}

```



<!-- BEGIN_TF_DOCS -->
## Requirements

No requirements.

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
| [google_service_account.cache_admin](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/service_account) | resource |
| [google_storage_bucket.cache](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/storage_bucket) | resource |
| [google_storage_bucket_iam_member.cache-member](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/storage_bucket_iam_member) | resource |
| [random_id.suffix](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/id) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_bucket_expiration_days"></a> [bucket\_expiration\_days](#input\_bucket\_expiration\_days) | Number of days before cache objects expires. | `number` | `2` | no |
| <a name="input_bucket_labels"></a> [bucket\_labels](#input\_bucket\_labels) | labels to apply to the storage bucket | `map(string)` | `{}` | no |
| <a name="input_bucket_location"></a> [bucket\_location](#input\_bucket\_location) | The location where to create the cache bucket in. | `string` | n/a | yes |
| <a name="input_bucket_name"></a> [bucket\_name](#input\_bucket\_name) | Name of the gcs storage bucket to be created. | `string` | `null` | no |
| <a name="input_bucket_storage_class"></a> [bucket\_storage\_class](#input\_bucket\_storage\_class) | The cache storage class | `string` | `"STANDARD"` | no |
| <a name="input_bucket_versioning"></a> [bucket\_versioning](#input\_bucket\_versioning) | Boolean used to enable versioning on the cache bucket, false by default. | `bool` | `false` | no |
| <a name="input_prefix"></a> [prefix](#input\_prefix) | string to prepend to the cache service account id | `string` | `"gitlab-runner"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_cache_bucket_name"></a> [cache\_bucket\_name](#output\_cache\_bucket\_name) | the FQDN of the cache bucket |
| <a name="output_cache_service_account_email"></a> [cache\_service\_account\_email](#output\_cache\_service\_account\_email) | the service account email of the service account created to access the cache bucket |
| <a name="output_cache_service_account_name"></a> [cache\_service\_account\_name](#output\_cache\_service\_account\_name) | the service account name of the service account created to access the cache bucket |
<!-- END_TF_DOCS -->