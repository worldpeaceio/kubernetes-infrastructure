resource "google_container_cluster" "wandering-frog" {
  name     = "wandering-frog"
  location = "us-central1"

  # We can't create a cluster with no node pool defined, but we want to only use
  # separately managed node pools. So we create the smallest possible default
  # node pool and immediately delete it.
  remove_default_node_pool = true
  initial_node_count       = 1

  release_channel {
    channel = "RAPID"
  }

  maintenance_policy {
    daily_maintenance_window {
      start_time = "10:00" # UTC
    }
  }

  workload_identity_config {
    identity_namespace = "${data.google_project.project.project_id}.svc.id.goog"
  }
}

resource "google_container_node_pool" "wandering-frog-nodes" {
  name       = "wandering-frog-node-pool"
  location   = "us-central1"
  cluster    = google_container_cluster.wandering-frog.name
  node_count = 1

  management {
    auto_repair  = true
    auto_upgrade = true
  }

  upgrade_settings {
    max_surge = 1
    max_unavailable = 0
  }

  node_config {
    machine_type = "e2-micro"
    disk_size_gb = 10
    image_type   = "cos"
    preemptible  = true

    shielded_instance_config {
      enable_secure_boot = true
      enable_integrity_monitoring = true
    }

    metadata = {
      disable-legacy-endpoints = "true"
    }
  }
}
