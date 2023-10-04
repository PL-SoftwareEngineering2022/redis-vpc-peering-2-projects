 binding {
    members = [
      "serviceAccount:service-<PROJECT_NUMBER>@service-networking.iam.gserviceaccount.com"
    ]
    role = "roles/servicenetworking.serviceAgent"
  }

  binding {
    members = ["serviceAccount:<PROJECT_NUMBER>-compute@developer.gserviceaccount.com", ]
    role    = "roles/iap.tunnelResourceAccessor"
  }
