
resource "yandex_compute_instance" "Grafana" {
  name = "grafana"
  zone = "ru-central1-a"
  resources {
    cores  = 2
    memory = 4
  }
  boot_disk {
    initialize_params {
      image_id = var.image_id_8
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
output "internal_ip_address_Grafana" {
  value = yandex_compute_instance.Grafana.network_interface.0.ip_address
}

resource "yandex_vpc_security_group" "grafana_sg" {
  name = "grafana-sg"
  description = "Security group for Grafana"
  network_id  = "${yandex_vpc_network.network-1.id}"
  ingress {
    from_port = 3000
    to_port = 3000
    protocol = "tcp"
    description = "Grafana"
    security_group_id = "${yandex_vpc_security_group.ssh_access_sg.id}"
  }
} 