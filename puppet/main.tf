provider "aws" {
  version = "~> 1.6"
  region  = "${var.region}"
}

# vpcs
module "vpc" {
  source               = "terraform-aws-modules/vpc/aws"
  name                 = "puppet"
  cidr                 = "172.16.0.0/16"
  azs                  = ["${var.region}a"]
  public_subnets       = ["172.16.1.0/24"]
  enable_dns_support   = true
  enable_dns_hostnames = true
  enable_nat_gateway   = true
}

resource "aws_vpc_dhcp_options" "puppet" {
  domain_name         = "local"
  domain_name_servers = ["AmazonProvidedDNS"]

  tags {
    Name = "puppet"
  }
}

resource "aws_vpc_dhcp_options_association" "domain_name" {
  vpc_id          = "${module.vpc.vpc_id}"
  dhcp_options_id = "${aws_vpc_dhcp_options.puppet.id}"
}

resource "aws_route53_zone" "local" {
  name   = "local"
  vpc_id = "${module.vpc.vpc_id}"
}

resource "aws_route53_record" "puppet_01" {
  zone_id = "${aws_route53_zone.local.zone_id}"
  name    = "puppet-01"
  type    = "A"
  ttl     = "30"

  records = [
    "${aws_eip.puppet_01.public_ip}",
  ]
}

# security groups
resource "aws_security_group" "outbound" {
  name        = "outbound"
  description = "Allow outbound traffic"
  vpc_id      = "${module.vpc.vpc_id}"

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    Name = "outbound"
  }
}

resource "aws_security_group" "ssh" {
  name        = "ssh"
  description = "Allow inbound ssh"
  vpc_id      = "${module.vpc.vpc_id}"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    Name = "ssh"
  }
}

resource "aws_security_group" "webhook" {
  name        = "webhook"
  description = "Allow inbound webhooks to the puppet master "
  vpc_id      = "${module.vpc.vpc_id}"

  ingress {
    from_port   = 8000
    to_port     = 8000
    protocol    = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    Name = "webhook"
  }
}

resource "aws_security_group" "https" {
  name        = "https"
  description = "Allow inbound https"
  vpc_id      = "${module.vpc.vpc_id}"

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    Name = "https"
  }
}

resource "aws_security_group" "puppet" {
  name        = "puppet"
  description = "Allow inbound puppet traffic"
  vpc_id      = "${module.vpc.vpc_id}"

  ingress {
    from_port       = 8140
    to_port         = 8140
    protocol        = "TCP"
    security_groups = ["${aws_security_group.ssh.id}"]
  }

  tags {
    Name = "puppet"
  }
}

# ec2 instances
resource "aws_instance" "puppet_01" {
  ami                    = "${lookup(var.ami, var.region)}"
  instance_type          = "t2.medium"
  key_name               = "acreek"
  monitoring             = true
  subnet_id              = "${element(module.vpc.public_subnets, 0)}"
  vpc_security_group_ids = ["${aws_security_group.ssh.id}", "${aws_security_group.puppet.id}", "${aws_security_group.webhook.id}", "${aws_security_group.https.id}", "${aws_security_group.outbound.id}"]

  root_block_device {
    volume_type           = "gp2"
    volume_size           = 50
    delete_on_termination = true
  }

  tags {
    Name = "puppet-01"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo hostnamectl set-hostname --static ${aws_instance.puppet_01.tags.Name}.local",
    ]

    connection {
      type = "ssh"
      user = "centos"
    }
  }
}

resource "aws_instance" "jenkins_01" {
  ami                    = "${lookup(var.ami, var.region)}"
  instance_type          = "t2.medium"
  key_name               = "acreek"
  monitoring             = true
  subnet_id              = "${element(module.vpc.public_subnets, 0)}"
  vpc_security_group_ids = ["${aws_security_group.ssh.id}", "${aws_security_group.https.id}", "${aws_security_group.outbound.id}"]

  root_block_device {
    volume_type           = "gp2"
    volume_size           = 50
    delete_on_termination = true
  }

  tags {
    Name = "jenkins-01"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo hostnamectl set-hostname --static ${aws_instance.jenkins_01.tags.Name}.local",
    ]

    connection {
      type = "ssh"
      user = "centos"
    }
  }
}

resource "aws_instance" "jenkins_slave_01" {
  ami           = "${lookup(var.ami, var.region)}"
  instance_type = "t2.small"
  key_name      = "acreek"

  monitoring             = true
  subnet_id              = "${element(module.vpc.public_subnets, 0)}"
  vpc_security_group_ids = ["${aws_security_group.ssh.id}", "${aws_security_group.outbound.id}"]

  root_block_device {
    volume_type           = "gp2"
    volume_size           = 50
    delete_on_termination = true
  }

  tags {
    Name = "jenkins-slave-01"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo hostnamectl set-hostname --static ${aws_instance.jenkins_slave_01.tags.Name}.local",
    ]

    connection {
      type = "ssh"
      user = "centos"
    }
  }
}

# elastic ips
resource "aws_eip" "puppet_01" {
  instance = "${aws_instance.puppet_01.id}"
  vpc      = true
}

resource "aws_eip" "jenkins_01" {
  instance = "${aws_instance.jenkins_01.id}"
  vpc      = true
}
