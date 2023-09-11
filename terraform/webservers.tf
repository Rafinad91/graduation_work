terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
    }
  }
  required_version = ">= 0.13"
}

provider "yandex" {
 token     = var.yandex_oauth_token
 cloud_id  = "b1grkh9bt8a7nq2uptup"
 folder_id = var.cloud_folder_id
 zone = "ru-central1-a,ru-central1-b"
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
resource "yandex_compute_instance" "vm-1" {
  name = "webserver-1"
  zone = "ru-central1-a"
  allow_stopping_for_update = true
  resources {
    cores  = 2
    memory = 4
  }
  
  boot_disk {
    initialize_params {
      image_id = var.image_id_7
      size = 20
    }
  }
  network_interface {
    subnet_id = var.subnet_id_1
    nat = false
     ip_address = var.ip_address_vm_1
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
      image_id = var.image_id_7
      size = 20
    }
  }

  network_interface {
    subnet_id = var.subnet_id_2
    nat = false
    ip_address = var.ip_address_vm_2
  }
  
  metadata = {
    user-data = "${file("./meta.txt")}"
  }
}
resource "yandex_vpc_network" "network-1" {
  name = "network1"
}

output "internal_ip_address_vm_1" {
  value = yandex_compute_instance.vm-1.network_interface.0.ip_address
}

output "internal_ip_address_vm_2" {
  value = yandex_compute_instance.vm-2.network_interface.0.ip_address
}
resource "yandex_vpc_security_group" "web_sg" {
  name = "web-sg"
  description = "Security group for web"
  network_id  = "${yandex_vpc_network.network-1.id}"

  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    description = "web"
    security_group_id = "${yandex_vpc_security_group.ssh_access_sg.id}"
  }
}
resource "yandex_alb_target_group" "webservers" {
  name           = "webservers"

  target {
    subnet_id    = var.subnet_id_1
    ip_address   = var.ip_address_vm_1
  }

  target {
    subnet_id    = var.subnet_id_2
    ip_address   = var.ip_address_vm_2
  }
}
resource "yandex_alb_backend_group" "webservers-backend-group" {
  name                     = "public-backend-group"
  session_affinity {
   connection {
     source_ip = true
    }
  }
http_backend {
   name                   = "web-backend"
    weight                 = 1
    port                   = 80
    target_group_ids       = [yandex_alb_target_group.webservers.id]
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
  http_router_id          = "${yandex_alb_http_router.router.id}"
  route {
    name                  = "web-router"
    http_route {
      http_route_action {
        backend_group_id  = var.backend_group_id
        timeout           = "60s"
      }
    }
  }
}    
resource "yandex_alb_load_balancer" "load-balancer" {
  name        = "balancer"
  network_id  = "${yandex_vpc_network.network-1.id}"

  allocation_policy {
    location {
      zone_id   = "ru-central1-a"
      subnet_id = var.subnet_id_1  
  }
  location {
      zone_id   = "ru-central1-b"
      subnet_id = var.subnet_id_2  
   }
  }
  listener {
    name = "web-listener"
    endpoint {
      address {
        external_ipv4_address {
          address = "51.250.79.233"
        }
      }
      ports = [80]
    }
    http {
      handler {
        http_router_id = "${yandex_alb_http_router.router.id}"
      }
    }
  }
  
}