# Service account for the Gitlab CI runner.  It doesn't run builds but it spawns other instances that do.
resource "google_service_account" "runner" {
  project      = var.project
  account_id   = "${var.prefix}-gitlab-runner"
  display_name = "GitLab CI Runner"
}

locals {
  runner_iam_roles = distinct(concat([
    "roles/compute.instanceAdmin.v1",
    "roles/compute.networkAdmin",
    "roles/logging.logWriter",
    "roles/compute.securityAdmin",
    "roles/monitoring.metricWriter"
  ], var.runner_additional_service_account_roles))
}

resource "google_project_iam_member" "this" {
  for_each = toset(local.runner_iam_roles)
  project  = var.project
  role     = each.value
  member   = "serviceAccount:${google_service_account.runner.email}"
}

# Service account for Gitlab CI build instances that are dynamically spawned by the runner.
resource "google_service_account" "agent" {
  project      = var.project
  account_id   = "${var.prefix}-gitlab-runner-agent"
  display_name = "GitLab CI Worker"
}

resource "google_service_account_key" "agent" {
  service_account_id = google_service_account.agent.name
}

# Allow GitLab CI runner to use the agent service account.
resource "google_service_account_iam_member" "agent_runner" {
  service_account_id = google_service_account.agent.name
  role               = "roles/iam.serviceAccountUser"
  member             = "serviceAccount:${google_service_account.runner.email}"
}

resource "google_monitoring_metric_descriptor" "jobs" {
  count        = var.runners_enable_monitoring ? 1 : 0
  description  = "The number of active running gitlab jobs on the VM"
  display_name = "Gitlab-Runner Jobs"
  project      = var.project
  type         = "custom.googleapis.com/gitlab_runner/jobs"
  metric_kind  = "GAUGE"
  value_type   = "DOUBLE"
  labels {
    key         = "instance"
    value_type  = "STRING"
    description = "The GCP Instance that hosts the runner"
  }
  labels {
    key         = "instance_id"
    value_type  = "STRING"
    description = "unique numerical ID assigned to the VM"
  }
  labels {
    key         = "zone"
    value_type  = "STRING"
    description = "name of the zone the instance is in."
  }
}

resource "google_compute_instance_template" "this" {
  name_prefix = "${var.prefix}-gitlab-runner-"
  description = "This template is used to create Gitlab Runner instances."

  tags = distinct(concat([local.firewall_tag], var.runners_executor == "docker+machine" ? var.docker_machine_tags : var.runners_tags))

  labels = local.runners_labels

  instance_description = "Gitlab Runner Instance"
  machine_type         = var.runners_executor == "docker+machine" ? var.docker_machine_machine_type : var.runners_machine_type

  scheduling {
    preemptible = var.runners_executor == "docker+machine" ? var.docker_machine_preemptible : var.runners_preemptible
  }

  // Create a new boot disk from an image
  disk {
    source_image = "centos-cloud/centos-7"
    auto_delete  = true
    boot         = true
    disk_size_gb = var.runners_executor == "docker+machine" ? var.docker_machine_disk_size : var.runners_disk_size
    disk_type    = var.runners_executor == "docker+machine" ? var.docker_machine_disk_type : var.runners_disk_type
    labels       = local.runners_labels
  }


  network_interface {
    network    = var.network
    subnetwork = var.subnetwork

    dynamic "access_config" {
      for_each = alltrue([var.runners_executor == "docker", !var.runners_use_internal_ip]) ? ["internal-ip"] : []
      content {}
    }

    dynamic "access_config" {
      for_each = alltrue([var.runners_executor == "docker+machine", !var.docker_machine_use_internal_ip]) ? ["internal-ip"] : []
      content {}
    }
  }

  metadata = merge(var.runners_metadata, {
    shutdown-script = local.template_shutdown_script
  })
  metadata_startup_script = local.template_startup_script

  service_account {
    email  = google_service_account.runner.email
    scopes = ["cloud-platform"]
  }

  lifecycle {
    create_before_destroy = true
  }
}


resource "google_compute_region_instance_group_manager" "this" {
  # name = "${var.prefix}-gitlab-runner"
  name = substr("${var.prefix}-gitlab-runner-mig-${md5(google_compute_instance_template.this.name)}", 0, 50)


  region             = var.region
  base_instance_name = "${var.prefix}-gitlab-runner"
  wait_for_instances = true

  version {
    instance_template = google_compute_instance_template.this.id
  }
  lifecycle {
    create_before_destroy = true
  }
}

resource "google_compute_region_autoscaler" "this" {
  name    = substr("${var.prefix}-gitlab-runner-${md5(google_compute_instance_template.this.name)}", 0, 50)
  project = var.project
  region  = var.region

  target = google_compute_region_instance_group_manager.this.id

  autoscaling_policy {
    max_replicas = var.runners_max_replicas
    min_replicas = var.runners_min_replicas

    dynamic "metric" {
      for_each = var.runners_enable_monitoring ? [google_monitoring_metric_descriptor.jobs[0].type] : []
      content {
        name = metric.value
        # Scale up when the number of jobs running on the VM is almost the value of the concurrent
        target = var.runners_concurrent - 2
        type   = "GAUGE"
      }
    }
  }

}
