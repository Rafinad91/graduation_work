terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
    }
  }
  required_version = ">= 0.13"
}

provider "yandex" {
 token     = "y0_AgAAAAAIWngpAATuwQAAAADXTaDG_EmuX1XETJm7ppI558oMCqcnqOA"
 cloud_id  = "b1grkh9bt8a7nq2uptup"
 folder_id = "b1gt86b9aq1ci5kanapu"
 zone = "ru-central1-a"
}
resource "yandex_compute_instance" "vm-1" {
  name = "webserver_1"
  zone = "ru-central1-a"
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
    nat       = true
  }
  
  metadata = {
    user-data = "${file("./meta.txt")}"
  }
}
  resource "yandex_compute_instance" "vm-2" {
  name = "webserver_2"
  zone = "ru-central1-b"
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
    subnet_id = "${yandex_vpc_subnet.subnet-2.id}"
    nat       = true
  }
  
  metadata = {
    user-data = "${file("./meta.txt")}"
  }
}
resource "yandex_vpc_network" "network-1" {
  name = "network1"
}

resource "yandex_vpc_subnet" "subnet-1" {
  name           = "subnet1"
   zone           = "ru-central1-a"
   network_id     = "${yandex_vpc_network.network-1.id}"
   v4_cidr_blocks = ["192.168.10.0/24"]
}
resource "yandex_vpc_subnet" "subnet-2" {
  name           = "subnet2"
   zone           = "ru-central1-b"
   network_id     = "${yandex_vpc_network.network-1.id}"
   v4_cidr_blocks = ["192.168.15.0/24"]
}
output "internal_ip_address_vm_1" {
  value = yandex_compute_instance.vm-1.network_interface.0.ip_address
}
output "external_ip_address_vm_1" {
  value = yandex_compute_instance.vm-1.network_interface.0.nat_ip_address
}
output "internal_ip_address_vm_2" {
  value = yandex_compute_instance.vm-2.network_interface.0.ip_address
}
output "external_ip_address_vm_2" {
  value = yandex_compute_instance.vm-2.network_interface.0.nat_ip_address
}

