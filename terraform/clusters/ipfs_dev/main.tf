provider "google" {
  project = var.project_id
}

provider "google-beta" {
  project = var.project_id
}

data "google_project" "project" {
  project_id = var.project_id
}

module "k8s-royal-brook" {
  source = "../../module/gke/"
  project_id   = var.project_id

  cluster_name = "green-recipe"
  cluster_zone = "us-central1-a"
}
