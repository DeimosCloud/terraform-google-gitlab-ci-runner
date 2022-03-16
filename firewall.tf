resource "google_compute_firewall" "ssh" {
  count       = var.runners_allow_ssh_access ? 1 : 0
  name        = "${var.prefix}-gitlab-runner-allow-ssh"
  description = "Allow SSH to Runner instances"
  network     = data.google_compute_network.this.name

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = var.runners_ssh_allowed_cidr_blocks
  target_tags   = [local.firewall_tag]
}

resource "google_compute_firewall" "docker_machine" {
  name        = "docker-machines"
  description = "Allow docker-machine traffic within on port 2376"
  network     = data.google_compute_network.this.name

  allow {
    protocol = "tcp"
    ports    = ["2376"]
  }

  source_tags = concat([local.firewall_tag], var.docker_machine_tags)
  target_tags = concat(["docker-machine", local.firewall_tag], var.runners_tags)
}

resource "google_compute_firewall" "docker_machine_ssh" {
  name        = "${var.prefix}-gitlab-runner-docker-machine-allow-ssh"
  description = "Allow ssh to docker-machine from runner "
  network     = data.google_compute_network.this.name

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_tags = concat([local.firewall_tag], var.docker_machine_tags)
  target_tags = concat(["docker-machine", local.firewall_tag], var.runners_tags)
}

resource "google_compute_firewall" "internet" {
  name        = "${var.prefix}-gitlab-runner-allow-internet"
  description = "Allow connection to internet"
  network     = data.google_compute_network.this.name

  direction = "EGRESS"
  allow {
    protocol = "tcp"
  }

  target_tags = [local.firewall_tag]
}
