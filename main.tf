provider "aws" {
  version = "~> 1.6"
  region  = "${var.region}"
}

resource "aws_instance" "example" {
  ami           = "${lookup(var.ami, var.region)}"
  instance_type = "t2.micro"
}

resource "aws_eip" "ip" {
  instance = "${aws_instance.example.id}"
}
