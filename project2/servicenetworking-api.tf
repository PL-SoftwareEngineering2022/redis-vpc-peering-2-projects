resource "google_project_service" "servicenetworking_api" {
  project = var.GCP_PROJECT
  service = "servicenetworking.googleapis.com"
}
