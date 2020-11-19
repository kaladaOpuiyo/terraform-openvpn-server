locals {
  local_ip_address = format("%s/32", chomp(data.http.local_ip_address.body))
}

data "http" "local_ip_address" {
  url = "http://ipv4.icanhazip.com"
}


resource "aws_security_group" "openvpn" {

  name = format("%s", var.resource_name)

  vpc_id = var.vpc_id

  description = var.resource_description

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [local.local_ip_address]
  }

  ingress {
    from_port   = 943
    to_port     = 943
    protocol    = "tcp"
    cidr_blocks = [local.local_ip_address]
  }

  ingress {
    from_port   = var.udp_port
    to_port     = var.udp_port
    protocol    = "udp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }


  tags = {
    Name = format("%s", var.resource_name)
  }

}
