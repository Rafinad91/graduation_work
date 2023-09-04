
resource "yandex_compute_instance" "Bastion" {
  name = "bastion"
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
    nat = true
  }
  
  metadata = {
    user-data = "${file("./meta.txt")}"
  }
}
output "internal_ip_address_Bastion" {
  value = yandex_compute_instance.Bastion.network_interface.0.ip_address
}
output "external_ip_address_Bastion" {
  value = yandex_compute_instance.Bastion.network_interface.0.nat_ip_address
}
resource "yandex_vpc_security_group" "bastion_sg" {
  name = "bastion-sg"
  description = "Security group for bastion"
  network_id  = "${yandex_vpc_network.network-1.id}"
  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    description = "bastion"
    security_group_id = "${yandex_vpc_security_group.ssh_access_sg.id}"
  }
} 