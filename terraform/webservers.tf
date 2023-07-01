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
 zone = "ru-central1-a,ru-central1-b"
}
resource "yandex_compute_instance" "vm-1" {
  name = "webserver-1"
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
  name = "webserver-2"
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
resource "yandex_alb_target_group" "webservers" {
  name           = "webservers"

  target {
    subnet_id    = "e9bijlmij63b0k7sbbtd"
    ip_address   = "192.168.10.7"
  }

  target {
    subnet_id    = "e2l412nkhbah6n2usa44"
    ip_address   = "192.168.15.17"
  }
}
resource "yandex_alb_backend_group" "webservers-backend-group" {
  name                     = "webservers-backend-group"
  session_affinity {
   connection {
     source_ip = true
    }
  }
http_backend {
   name                   = "webservers-backend"
    weight                 = 1
    port                   = 80
    target_group_ids       = ["ds74lkgaosgb4ec24t2a"]
    load_balancing_config {
     panic_threshold      = 90
    }    
    healthcheck {
      timeout              = "10s"
      interval             = "2s"
      healthy_threshold    = 10
      unhealthy_threshold  = 15 
      http_healthcheck {
        path               = "/"
      }
    }
  }
}
resource "yandex_alb_http_router" "router" {
  name          = "web-router"
  labels        = {
    tf-label    = "tf-label-value"
    empty-label = ""
  }
}

resource "yandex_alb_virtual_host" "my-virtual-host" {
  name                    = "my-virtual-host"
  http_router_id          = yandex_alb_http_router.router.id
  route {
    name                  = "web-router"
    http_route {
      http_route_action {
        backend_group_id  = "ds750u9h33f6flrgvp6f"
        timeout           = "60s"
      }
    }
  }
}    