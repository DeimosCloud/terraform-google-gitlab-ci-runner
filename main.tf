# Service account for the Gitlab CI runner.  It doesn't run builds but it spawns other instances that do.
resource "google_service_account" "runner" {
  project      = var.project
  account_id   = "${var.prefix}-gitlab-runner"
  display_name = "GitLab CI Runner"
}

resource "google_project_iam_member" "instanceadmin_runner" {
  project = var.project
  role    = "roles/compute.instanceAdmin.v1"
  member  = "serviceAccount:${google_service_account.runner.email}"
}

resource "google_project_iam_member" "networkadmin_runner" {
  project = var.project
  role    = "roles/compute.networkAdmin"
  member  = "serviceAccount:${google_service_account.runner.email}"
}

resource "google_project_iam_member" "securityadmin_runner" {
  project = var.project
  role    = "roles/compute.securityAdmin"
  member  = "serviceAccount:${google_service_account.runner.email}"
}

resource "google_project_iam_member" "logwriter_runner" {
  project = var.project
  role    = "roles/logging.logWriter"
  member  = "serviceAccount:${google_service_account.runner.email}"
}

# Service account for Gitlab CI build instances that are dynamically spawned by the runner.
resource "google_service_account" "agent" {
  project      = var.project
  account_id   = "${var.prefix}-agent"
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

resource "google_compute_instance_template" "this" {
  name_prefix = "${var.prefix}-gitlab-runner-"
  description = "This template is used to create Gitlab Runner instances."

  tags = distinct(concat(["gitlab"], var.runners_tags))

  labels = local.runners_labels

  instance_description = "Gitlab Runner Instance"
  machine_type         = var.machine_type

  scheduling {
    preemptible = var.runners_preemptible
  }

  // Create a new boot disk from an image
  disk {
    source_image = "centos-cloud/centos-7"
    auto_delete  = true
    boot         = true
    disk_size_gb = var.runners_disk_size
    disk_type    = var.runners_disk_type
    labels       = local.runners_labels
  }


  network_interface {
    network    = var.network
    subnetwork = var.subnetwork
    access_config {}
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

    cpu_utilization {
      target            = 0.8
      predictive_method = "OPTIMIZE_AVAILABILITY"
    }
  }

}
