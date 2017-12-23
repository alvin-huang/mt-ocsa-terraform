provider "aws" {
  version = "~> 1.6"
  region  = "${var.region}"
}

resource "aws_security_group" "security_group_ssh" {
  name        = "${lookup(var.security_group_ssh, var.region)}"
  description = "Allow inbound ssh"

  ingress {
    from_port   = 0
    to_port     = 22
    protocol    = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "security_group_puppet_webhook" {
  name        = "${lookup(var.security_group_puppet_webhook, var.region)}"
  description = "Allow inbound webhooks to the puppet master "

  ingress {
    from_port   = 0
    to_port     = 8000
    protocol    = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "security_group_https" {
  name        = "${lookup(var.security_group_https, var.region)}"
  description = "Allow inbound https"

  ingress {
    from_port   = 0
    to_port     = 443
    protocol    = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "puppet_master" {
  ami             = "${lookup(var.ami, var.region)}"
  instance_type   = "t2.medium"
  key_name        = "acreek"
  security_groups = ["${lookup(var.security_group_ssh, var.region)}", "${lookup(var.security_group_puppet_webhook, var.region)}"]
}

resource "aws_instance" "puppet_db" {
  ami             = "${lookup(var.ami, var.region)}"
  instance_type   = "t2.medium"
  key_name        = "acreek"
  security_groups = ["${lookup(var.security_group_ssh, var.region)}", "${lookup(var.security_group_https, var.region)}"]
}

resource "aws_eip" "puppet_master" {
  instance = "${aws_instance.puppet_master.id}"
}

resource "aws_eip" "puppet_db" {
  instance = "${aws_instance.puppet_db.id}"
}
