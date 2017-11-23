provider "aws" {
  region = "eu-central-1"
}

variable "server_port" {
  description = "The port for the http server"
  default = "8080"
}

resource "aws_instance" "example" {
  ami = "ami-bf2ba8d0"
  instance_type = "t2.micro"
  key_name = "engcraciun-FR"
  subnet_id = "subnet-c3e905be"
  vpc_security_group_ids = ["${aws_security_group.instance.id}" , "sg-1f22a375"]
  user_data = <<-EOF
		#!/bin/bash
		sleep 30
		/usr/bin/yum -y install busybox
		echo "Hello world" > index.html
		nohup busybox httpd -f -p "${var.server_port}" &
		EOF

  tags {
    Name = "pub-1b"
  }
}


resource "aws_security_group" "instance" {
  name = "terraform-example-instance"
  vpc_id = "vpc-48e5fa20"

  ingress {
    from_port = "${var.server_port}"
    to_port = "${var.server_port}"
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

output "public_ip" {
  value = "${aws_instance.example.public_ip}"
}
