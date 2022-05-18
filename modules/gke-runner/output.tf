# output "runner_name" {
#   value       = module.kubernetes_gitlab_runner.runner_name
#   description = "name of the gitlab runner"
# }

output "node_pool_name" {
  value       = google_container_node_pool.gitlab_runner_pool.name
  description = "name of the node pool where the runner pods are created"
}

output "cache_bucket_name" {
  value       = module.cache.cache_bucket_name
  description = "name of the gcs bucket used a s runner cache"
}

output "namespace" {
  value       = module.kubernetes_gitlab_runner.namespace
  description = "namespace in which the runners were created"
}