terraform {
  required_providers {
    google-beta = {
      source  = "hashicorp/google-beta"
      version = "4.25.0"
    }
  }
}

provider "google-beta" {
  credentials = file("../.keys/service_key.json")
  project = var.project_id
  region  = var.region
  zone    = var.zone
}

locals {
  locations = ["europe-west4", "asia-south1", "us-west2"]
}

# Deploy image to Cloud Run
resource "google_cloud_run_service" "service" {
  provider = google-beta
  for_each = toset(local.locations)
  name     = "service-${each.key}"
  location = each.key
  template {
    spec {
        containers {
            image = "europe-west3-docker.pkg.dev/outfit7-362408/docker-test-repository/flask-app:latest"
        }
    }
  }
}