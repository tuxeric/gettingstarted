provider "aws" {
  region = "eu-central-1"
}

resource "aws_instance" "example" {
  ami = "ami-bf2ba8d0"
  instance_type = "t2.micro"
  subnet_id = "subnet-c3e905be"

  tags {
    Name = "pub-1b"
  }
}
