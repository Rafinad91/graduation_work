
resource "yandex_compute_instance" "Prometheus" {
  name = "prometheus"
  zone = "ru-central1-a"
  allow_stopping_for_update = true
  resources {
    cores  = 2
    memory = 4
  }
  boot_disk {
    initialize_params {
      image_id = "fd87bs5724r0ngu3jlb6"
      size = 20
    }
  }
  network_interface {
    subnet_id = "${yandex_vpc_subnet.subnet-1.id}"
    nat = false
  }
  
  metadata = {
    user-data = "${file("./meta.txt")}"
  }
}
output "internal_ip_address_Prometheus" {
  value = yandex_compute_instance.Prometheus.network_interface.0.ip_address
}