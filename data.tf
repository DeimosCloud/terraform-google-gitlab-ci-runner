data "google_compute_zones" "available" {
  project = var.project
  region  = var.region
}

resource "random_shuffle" "zones" {
  input        = data.google_compute_zones.available.names
  result_count = 1
}

resource "random_id" "this" {
  byte_length = 8
}

data "google_compute_network" "this" {
  name = var.network
}
