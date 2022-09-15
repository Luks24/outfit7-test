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
# Names of location we want our clour run instances to deploy
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
            image = "europe-west3-docker.pkg.dev/${var.project_id}/docker-test-repository/flask-app:${var.git_id}"
        }
    }
  }
}
# Provision static IP
resource "google_compute_global_address" "ip" {
  provider = google-beta
  name = "service-ip"
}
#create a network endpont group for every region in locations
resource "google_compute_region_network_endpoint_group" "neg" {
  provider = google-beta
  for_each = toset(local.locations)

  name                  = "neg-${each.key}"
  network_endpoint_type = "SERVERLESS"
  region                = each.key

  cloud_run {
    service = google_cloud_run_service.service[each.key].name
  }
}
#Create a backend service to be tied to NEGs
resource "google_compute_backend_service" "backend" {
  provider = google-beta
  name     = "backend"
  protocol = "HTTP"

  dynamic "backend" {
    for_each = toset(local.locations)

    content {
      group = google_compute_region_network_endpoint_group.neg[backend.key].id
    }
  }
}
# Create URL to point ot backend service
resource "google_compute_url_map" "url_map" {
  provider = google-beta
  name            = "url-map"
  default_service = google_compute_backend_service.backend.id
}
#Create proxy
resource "google_compute_target_http_proxy" "http_proxy" {
  provider = google-beta
  name    = "http-proxy"
  url_map = google_compute_url_map.url_map.id
}
#create rule to forward traffic from static IP to backend trough proxy
resource "google_compute_global_forwarding_rule" "frontend" {
  provider = google-beta
  name       = "frontend"
  target     = google_compute_target_http_proxy.http_proxy.id
  port_range = "80"
  ip_address = google_compute_global_address.ip.address
}
# make our services public
data "google_iam_policy" "noauth" {
  provider = google-beta
  binding {
    role    = "roles/run.invoker"
    members = ["allUsers"]
  }
}

resource "google_cloud_run_service_iam_policy" "noauth" {
  provider = google-beta
  for_each = toset(local.locations)

  service     = google_cloud_run_service.service[each.key].name
  location    = google_cloud_run_service.service[each.key].location
  policy_data = data.google_iam_policy.noauth.policy_data
}
# outputs the static IP that GCP assigned
output "static_ip" {
  value = google_compute_global_address.ip.address
}