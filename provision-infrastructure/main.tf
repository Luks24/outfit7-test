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
            image = "europe-west3-docker.pkg.dev/outfit7-362408/docker-test-repository/flask-app:${var.git_id}"
        }
    }
  }
}

resource "google_compute_global_address" "ip" {
  provider = google-beta
  name = "service-ip"
}

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

resource "google_compute_url_map" "url_map" {
  provider = google-beta
  name            = "url-map"
  default_service = google_compute_backend_service.backend.id
}

resource "google_compute_target_http_proxy" "http_proxy" {
  provider = google-beta
  name    = "http-proxy"
  url_map = google_compute_url_map.url_map.id
}

resource "google_compute_global_forwarding_rule" "frontend" {
  provider = google-beta
  name       = "frontend"
  target     = google_compute_target_http_proxy.http_proxy.id
  port_range = "80"
  ip_address = google_compute_global_address.ip.address
}

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

output "static_ip" {
  value = google_compute_global_address.ip.address
}