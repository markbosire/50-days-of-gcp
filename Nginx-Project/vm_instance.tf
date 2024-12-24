resource "google_compute_instance" "nginx_static_website" {
  name         = "nginx-static-website"
  machine_type = "e2-micro"
  zone         = "us-central1-a"

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
    }
  }

  tags = ["http-server", "https-server"]

  metadata_startup_script = file("startup.sh")

  network_interface {
    network = "default"
    access_config {
      # This will assign an external IP to the VM
    }
  }
}
