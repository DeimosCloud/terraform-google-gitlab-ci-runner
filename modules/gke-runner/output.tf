output "runner_name" {
  value       = var.runner_name
  description = "name of the gitlab runner"
}

output "node_pool_name" {
  value       = var.create_node_pool ? google_container_node_pool.this.0.name : var.runner_node_pool_name
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
