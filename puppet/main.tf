provider "aws" {
  version = "~> 1.6"
  region  = "${var.region}"
}

# vpcs
module "vpc" {
  source = "terraform-aws-modules/vpc/aws"
  name = "puppet"
  cidr = "172.16.0.0/16"
  azs             = ["${var.region}a", "${var.region}b", "${var.region}c"]
  public_subnets  = ["172.16.1.0/24"]
}

# security groups
resource "aws_security_group" "security_group_outbound" {
  name        = "security-group-outbound"
  description = "Allow outbound traffic"

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  vpc_id = "${module.vpc.vpc_id}"
}

resource "aws_security_group" "security_group_ssh" {
  name        = "security-group-ssh"
  description = "Allow inbound ssh"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  }

  vpc_id = "${module.vpc.vpc_id}"
}

resource "aws_security_group" "security_group_webhook" {
  name        = "security-group-webhook"
  description = "Allow inbound webhooks to the puppet master "

  ingress {
    from_port   = 8000
    to_port     = 8000
    protocol    = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  }

  vpc_id = "${module.vpc.vpc_id}"
}

resource "aws_security_group" "security_group_https" {
  name        = "security-group-https"
  description = "Allow inbound https"

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  }

  vpc_id = "${module.vpc.vpc_id}"
}

# ec2 instances
resource "aws_instance" "puppet_master" {
  ami             = "${lookup(var.ami, var.region)}"
  instance_type   = "t2.medium"
  key_name        = "acreek"
  subnet_id       = "${element(module.vpc.public_subnets, 0)}"
  vpc_security_group_ids = ["${aws_security_group.security_group_ssh.id}", "${aws_security_group.security_group_webhook.id}", "${aws_security_group.security_group_outbound.id}"]
  tags {
    Name = "puppet-master"
  }
}

resource "aws_instance" "jenkins_master" {
  ami             = "${lookup(var.ami, var.region)}"
  instance_type   = "t2.medium"
  key_name        = "acreek"
  subnet_id       = "${element(module.vpc.public_subnets, 0)}"
  vpc_security_group_ids = ["${aws_security_group.security_group_ssh.id}", "${aws_security_group.security_group_https.id}", "${aws_security_group.security_group_outbound.id}"]
  tags {
    Name = "jenkins-master"
  }
}

resource "aws_instance" "jenkins_slave" {
  ami             = "${lookup(var.ami, var.region)}"
  instance_type   = "t2.small"
  key_name        = "acreek"
  subnet_id       = "${element(module.vpc.public_subnets, 0)}"
  vpc_security_group_ids = ["${aws_security_group.security_group_ssh.id}", "${aws_security_group.security_group_outbound.id}"]
  tags {
    Name = "jenkins-slave"
  }
}

# elastic ips
resource "aws_eip" "puppet_master" {
  instance = "${aws_instance.puppet_master.id}"
  vpc = true
}

resource "aws_eip" "jenkins_master" {
  instance = "${aws_instance.jenkins_master.id}"
  vpc = true
}

resource "aws_eip" "jenkins_slave" {
  instance = "${aws_instance.jenkins_slave.id}"
  vpc = true
}
