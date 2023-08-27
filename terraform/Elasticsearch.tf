
resource "yandex_compute_instance" "Elasticsearch" {
  name = "elastic"
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
    nat = false
  }
  
  metadata = {
    user-data = "${file("./meta.txt")}"
  }
}
output "internal_ip_address_Elasticsearch" {
  value = yandex_compute_instance.Elasticsearch.network_interface.0.ip_address
}
resource "yandex_vpc_security_group" "Elasticsearch_sg" {
  name = "Elasticsearch-sg"
  description = "Security group for Elasticsearch"
  network_id  = "${yandex_vpc_network.network-1.id}"
  ingress {
    from_port = 9200
    to_port = 9200
    protocol = "tcp"
    description = "Elasticsearch"
    security_group_id = "${yandex_vpc_security_group.ssh_access_sg.id}"
  }
}
resource "yandex_vpc_security_group" "logstash_sg" {
  name = "logstash-sg"
  description = "Security group for logstash"
  network_id  = "${yandex_vpc_network.network-1.id}"
  ingress {
    from_port = 5044
    to_port = 5044
    protocol = "tcp"
    description = "logstash"
    security_group_id = "${yandex_vpc_security_group.ssh_access_sg.id}"
  }
}