provider "aws" {
  region = "eu-central-1"
}

terraform {
  backend "s3" {
    bucket = "mytfstates"
    key = "stage/services/webserver-cluster/terraform.tfstate"
    region = "eu-central-1"
  }
}

resource "aws_launch_configuration" "example" {
  image_id = "ami-bf2ba8d0"
  instance_type = "t2.micro"
  key_name = "engcraciun-FR"
  security_groups = ["${aws_security_group.instance.id}"]
  associate_public_ip_address = "true"
  user_data = <<-EOF
		#!/bin/bash
		sleep 60
		/usr/bin/yum -y install busybox
		echo "Hello world" > index.html
		nohup busybox httpd -f -p "${var.server_port}" &
		EOF
  lifecycle {
    create_before_destroy = true
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
  lifecycle {
    create_before_destroy = true
  }
}

data "aws_availability_zones" "all" {}

resource "aws_autoscaling_group" "example" {
  launch_configuration = "${aws_launch_configuration.example.id}"
  vpc_zone_identifier = ["subnet-fa6cce91", "subnet-c3e905be"]
  min_size = 2
  max_size = 10
  load_balancers = ["${aws_elb.example.name}"]
  health_check_grace_period = "300"
  health_check_type = "ELB"

  tag {
    key = "Name"
    value = "terraform-asg-example"
    propagate_at_launch = true
  }
}

resource "aws_elb" "example" {
  name = "terraform-asg-example"
#  availability_zones = ["${data.aws_availability_zones.all.names}"]
  subnets = ["subnet-fa6cce91", "subnet-c3e905be"]
  security_groups = ["${aws_security_group.elb.id}"]

  listener {
    lb_port = "80"
    lb_protocol = "HTTP"
    instance_port = "${var.server_port}"
    instance_protocol = "HTTP"
  }

  health_check {
    healthy_threshold = 2
    unhealthy_threshold = 2
    target = "HTTP:${var.server_port}/"
    interval = 30
    timeout = 3
  }
}

resource "aws_security_group" "elb" {
  name = "terraform-example-elb"
  vpc_id = "vpc-48e5fa20"

  ingress {
    from_port = "80"
    to_port = "80"
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port = "0"
    to_port = "0"
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
