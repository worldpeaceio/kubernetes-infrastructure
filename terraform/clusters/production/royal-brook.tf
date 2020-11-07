locals {
  cluster_name = "royal-brook"
  cluster_region = "us-central1"
  cluster_zone = "us-central1-a"
}

resource "google_container_cluster" "royal-brook" {
  name     = local.cluster_name
  location = local.cluster_zone
  provider = google-beta // Need for networking mode VPC_NATIVE

  networking_mode = "VPC_NATIVE"
  ip_allocation_policy {}

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
