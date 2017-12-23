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

variable "security_group_puppet" {
  type = "map"
  default = {
    "us-east-1" = "security-group-ue1-puppet"
    "us-east-2" = "security-group-ue2-puppet"
  }
}
