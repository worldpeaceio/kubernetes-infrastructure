locals {
  cluster_name = "royal-brook"
  cluster_region = "us-central1"
  cluster_zone = "us-central1-a"
}

data "google_compute_network" "production" {
  name = var.project_id
}

data "google_compute_subnetwork" "royal-brook" {
  name   = local.cluster_name
  region = local.cluster_region
}

resource "google_container_cluster" "royal-brook" {
  name     = local.cluster_name
  location = local.cluster_zone

  network    = data.google_compute_network.production.self_link
  subnetwork = data.google_compute_subnetwork.royal-brook.self_link
  ip_allocation_policy {
    cluster_secondary_range_name = "${local.cluster_name}-pods"
    services_secondary_range_name = "${local.cluster_name}-services"
  }

  private_cluster_config {
    enable_private_endpoint = false
    enable_private_nodes    = true
    master_ipv4_cidr_block  = "172.16.0.0/28"
  }

  master_authorized_networks_config {}

  enable_shielded_nodes = true

  workload_identity_config {
    identity_namespace = "${data.google_project.project.project_id}.svc.id.goog"
  }

  release_channel {
    channel = "RAPID"
  }

  maintenance_policy {
    daily_maintenance_window {
      start_time = "09:00" # GMT
    }
  }

  # We can't create a cluster with no node pool defined, but we want to only use
  # separately managed node pools. So we create the smallest possible default
  # node pool and immediately delete it.
  remove_default_node_pool = true
  initial_node_count       = 1
}

resource "google_container_node_pool" "royal-brook-nodes" {
  name           = "${local.cluster_name}-node-pool"
  location       = local.cluster_zone
  cluster        = local.cluster_name
  node_count     = 1

  management {
    auto_repair  = true
    auto_upgrade = true
  }

  upgrade_settings {
    max_surge       = 2
    max_unavailable = 1
  }

  autoscaling {
    max_node_count = 2
    min_node_count = 0
  }

  node_config {
    machine_type = "e2-small"
    disk_size_gb = 20
    image_type   = "COS"
    preemptible  = true

    shielded_instance_config {
      enable_secure_boot          = true
      enable_integrity_monitoring = true
    }

    oauth_scopes = [
      "https://www.googleapis.com/auth/devstorage.read_only",
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
      "https://www.googleapis.com/auth/servicecontrol",
      "https://www.googleapis.com/auth/service.management.readonly",
      "https://www.googleapis.com/auth/trace.append",
    ]

    metadata = {
      disable-legacy-endpoints = "true"
    }
  }
}

//resource "google_compute_router" "router" {
//  name    = "my-router"
//  region  = google_compute_subnetwork.wandering-frog.region
//  network = google_compute_network.net.id
//}
//
//resource "google_compute_address" "address" {
//  count  = 2
//  name   = "nat-manual-ip-${count.index}"
//  region = google_compute_subnetwork.subnet.region
//}
//
//resource "google_compute_router_nat" "nat_manual" {
//  name   = "my-router-nat"
//  router = google_compute_router.router.name
//  region = google_compute_router.router.region
//
//  nat_ip_allocate_option = "MANUAL_ONLY"
//  nat_ips                = google_compute_address.address.*.self_link
//
//  source_subnetwork_ip_ranges_to_nat = "LIST_OF_SUBNETWORKS"
//  subnetwork {
//    name                    = google_compute_subnetwork.subnet.id
//    source_ip_ranges_to_nat = ["ALL_IP_RANGES"]
//  }
//}
