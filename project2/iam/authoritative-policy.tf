resource "google_project_iam_policy" "project" {
  project     = "project1"
  policy_data = data.google_iam_policy.policy.policy_data
}
data "google_iam_policy" "policy" {
  binding {
    members = [
    "serviceAccount:<PROJECT_NUMBER>-compute@developer.gserviceaccount.com",
    ]
    role = "roles/iap.tunnelResourceAccessor"
  }
  binding {
    members = [
      "serviceAccount:service-<PROJECT_NUMBER>@service-networking.iam.gserviceaccount.com"
    ]
    role = "roles/servicenetworking.serviceAgent"
  }
   binding {
    members = [
      "serviceAccount:<PROJECT_NUMBER>-compute@developer.gserviceaccount.com",
    ]
    role = "roles/editor"
  }
}
