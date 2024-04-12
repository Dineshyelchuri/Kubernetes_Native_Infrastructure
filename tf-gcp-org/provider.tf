provider "google" {
  project     = var.first_project
  credentials = file(var.credentials)
  region      = var.region
}
