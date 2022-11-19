provider "google" {
  project = "trabalho-01-iaac"
  region  = "us-central1"
  zone    = "us-central1-c"
  credentials = file("../../trabalho-01-iaac-credentials.json")
}
resource "google_compute_network" "default" {
  name = "my-network"
}

resource "google_compute_subnetwork" "default" {
  name          = "my-subnet"
  ip_cidr_range = "10.0.0.0/16"
  region        = "us-central1"
  network       = google_compute_network.default.id
}

resource "google_compute_address" "internal_with_subnet_and_address" {
  name         = "my-internal-address"
  subnetwork   = google_compute_subnetwork.default.id
  address_type = "INTERNAL"
  address      = "10.0.42.42"
  region       = "us-central1"
}

resource "google_compute_firewall" "default" {
  name = "firewall-allow-internal"
  network = google_compute_network.default.name
  allow {
    protocol = "tcp"
    ports    = ["80"]
  }
  target_tags = ["http"]
  source_tags = ["http"]
}
resource "google_dns_record_set" "frontend" {
  name = google_dns_managed_zone.prod.dns_name
  type = "A"
  ttl  = 300

  managed_zone = google_dns_managed_zone.prod.name

  rrdatas = [google_compute_instance.vm_instance.network_interface[0].access_config[0].nat_ip]
}

resource "google_compute_address" "static" {
  name = "ipv4-address"
}

resource "google_compute_instance" "vm_instance" {
  name         = "terraform-instance"
  machine_type = "e2-medium"

  hostname = "rundeck-iaac-trabalho-01.com."
  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
    }
  }

  network_interface {
      network = google_compute_network.default.name
      subnetwork = google_compute_subnetwork.default.name
      access_config {
        nat_ip = google_compute_address.static.address
      }
  }
  
  metadata_startup_script = file("startup-script.sh")

}


resource "google_dns_managed_zone" "prod" {
  name     = "rundeck-iaac-trabalho-01"
  dns_name = "rundeck-iaac-trabalho-01.com."
}

resource "google_storage_bucket" "iaac" {
  name          = "bucket-iaac-trabalho-01.teste.com"
  location      = "us-central1"
}