
resource "yandex_compute_instance" "Kibana" {
  name = "kibana"
  zone = "ru-central1-a"
  resources {
    cores  = 2
    memory = 4
  }
  boot_disk {
    initialize_params {
      image_id = "fd8hhtemghrl8qptlnfu"
      size = 20
    }
  }
  network_interface {
    subnet_id = "${yandex_vpc_subnet.subnet-1.id}"
    nat       = true
  }
  
  metadata = {
    user-data = "${file("./meta.txt")}"
  }
}
output "internal_ip_address_Kibana" {
  value = yandex_compute_instance.Kibana.network_interface.0.ip_address
}
output "external_ip_address_Kibana" {
  value = yandex_compute_instance.Kibana.network_interface.0.nat_ip_address
}