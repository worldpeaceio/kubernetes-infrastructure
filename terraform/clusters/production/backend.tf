terraform {
  backend "gcs" {
    bucket  = "worldpeaceio-kubernetes-infrastructure-tf-state"
    prefix  = "production"
  }
}
