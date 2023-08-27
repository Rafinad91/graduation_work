
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
    nat = true
  }
  
  metadata = {
    user-data = "${file("./meta.txt")}"
  }
}
output "internal_ip_address_Kibana" {
  value = yandex_compute_instance.Kibana.network_interface.0.ip_address
}

resource "yandex_vpc_security_group" "kibana_sg" {
  name = "kibana-sg"
  description = "Security group for kibana"
  network_id  = "${yandex_vpc_network.network-1.id}"
  ingress {
    from_port = 5601
    to_port = 5601
    protocol = "tcp"
    description = "kibana"
    security_group_id = "${yandex_vpc_security_group.ssh_access_sg.id}"
  }
}