terraform {
  backend "gcs" {
    bucket = "bucket-tfstate-c47703a1a4064a78"
    prefix = "terraform/state"
  }
}