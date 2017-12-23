variable "region" {
  default = "us-east-2"
}

variable "ami" {
  type = "map"
  default = {
    "us-east-1" = "ami-db48ada1"
    "us-east-2" = "ami-d61133b3"
  }
}

variable "security_group_outbound" {
  type = "map"
  default = {
    "us-east-1" = "security-group-ue1-outbound"
    "us-east-2" = "security-group-ue2-outbound"
  }
}

variable "security_group_ssh" {
  type = "map"
  default = {
    "us-east-1" = "security-group-ue1-ssh"
    "us-east-2" = "security-group-ue2-ssh"
  }
}

variable "security_group_webhook" {
  type = "map"
  default = {
    "us-east-1" = "security-group-ue1-webhook"
    "us-east-2" = "security-group-ue2-webhook"
  }
}

variable "security_group_https" {
  type = "map"
  default = {
    "us-east-1" = "security-group-ue1-https"
    "us-east-2" = "security-group-ue2-https"
  }
}
