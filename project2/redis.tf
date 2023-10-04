resource "google_compute_network" "redis_vpc" {
  project                 = var.GCP_PROJECT
  name                    = "redis-vpc"
  auto_create_subnetworks = false
  mtu                     = 1460
}

output "redis_compute_network" {
  value = google_compute_network.redis_vpc.self_link
}

resource "google_compute_subnetwork" "redis_vpc_subnet" {
  name                     = "redis-vpc-subnet"
  ip_cidr_range            = "10.124.0.0/16"
  region                   = "us-central1"
  network                  = google_compute_network.redis_vpc.id
  private_ip_google_access = true
}

resource "google_compute_firewall" "redis_vpc_firewall" {
  project = var.GCP_PROJECT
  name    = "redis-firewall"
  network = google_compute_network.redis_vpc.name

  allow {
    protocol = "icmp"
  }

  allow {
    protocol = "tcp"
    ports    = ["22", "6379"]
  }
  source_ranges = [
    "35.235.240.0/20", # allows iap-tunnel
    "10.0.0.0/8"
  ]
}

resource "google_compute_network_peering" "redis_peering" {
  name         = "redis-peering"
  network      = google_compute_network.redis_vpc.self_link
  peer_network = "https://www.googleapis.com/compute/v1/projects/<PROJECT1>/global/networks/redis-vpc"
}

resource "google_compute_router" "redis_router" {
  name    = "redis-router"
  region  = google_compute_subnetwork.redis_vpc_subnet.region
  network = google_compute_network.redis_vpc.id

  bgp {
    asn = 64514
  }
}

resource "google_compute_router_nat" "redis_nat" {
  name                               = "redis-nat"
  router                             = google_compute_router.redis_router.name
  region                             = google_compute_router.redis_router.region
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"
}

resource "google_compute_global_address" "redis_vpc_ip_range" {
  name          = "redis-vpc-ip-range"
  purpose       = "VPC_PEERING"
  address_type  = "INTERNAL"
  prefix_length = 16
  network       = google_compute_network.redis_vpc.id
}

resource "google_service_networking_connection" "redis_private_service_connection" {
  network                 = google_compute_network.redis_vpc.id
  service                 = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [google_compute_global_address.redis_vpc_ip_range.name]
}

resource "google_redis_instance" "redis" {
  name               = "redis-instance"
  tier               = "BASIC"
  memory_size_gb     = 5
  location_id        = "us-central1-a"
  authorized_network = google_compute_network.redis_vpc.id
  region             = "us-central1"
  display_name       = "vpc-peering-redis-instance"
  connect_mode       = "PRIVATE_SERVICE_ACCESS"
  redis_version      = "REDIS_7_0"
  labels = {
    team = "camp"
  }
  depends_on = [google_service_networking_connection.redis_private_service_connection]
}

resource "google_compute_instance" "redis_proxy" {
  name         = "redis-proxy"
  machine_type = "e2-small"
  zone         = "us-central1-a"
  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
    }
  }
  network_interface {
    network    = google_compute_network.redis_vpc.self_link
    subnetwork = google_compute_subnetwork.redis_vpc_subnet.self_link
    stack_type = "IPV4_ONLY"
  }
}

resource "google_compute_instance" "redis_access_vm" {
  name         = "redis-sre-dev-access-vm"
  machine_type = "e2-small"
  zone         = "us-central1-a"
  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
    }
  }
  network_interface {
    network    = google_compute_network.redis_vpc.self_link
    subnetwork = google_compute_subnetwork.redis_vpc_subnet.self_link
    stack_type = "IPV4_ONLY"
  }
}
