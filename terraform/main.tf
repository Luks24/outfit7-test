terraform {
  required_providers {
    google-beta = {
      source  = "hashicorp/google-beta"
      version = "4.25.0"
    }
  }
}

provider "google-beta" {
  credentials = file("../.keys/service-key.json")
  project = var.project_id
  region  = var.region
  zone    = var.zone
}

# Enable IAM API
resource "google_project_service" "iam" {
  provider = google-beta
  service            = "iam.googleapis.com"
  disable_on_destroy = false
}
# Enable Cloud Run API
resource "google_project_service" "cloudrun" {
  provider = google-beta
  service            = "run.googleapis.com"
  disable_on_destroy = false
}
# Enable Cloud Resource Manager API
resource "google_project_service" "resourcemanager" {
  provider = google-beta
  service            = "cloudresourcemanager.googleapis.com"
  disable_on_destroy = false
}
