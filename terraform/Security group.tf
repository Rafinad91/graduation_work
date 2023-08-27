
resource "yandex_vpc_security_group" "ssh_access_sg" {
  name = "ssh-access-sg"
  description = "Security group for SSH access"
  network_id  = "${yandex_vpc_network.network-1.id}"

  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    description = "SSH"
    v4_cidr_blocks =  ["0.0.0.0/0"]
  }
}