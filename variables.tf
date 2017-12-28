variable "region" {
  default = "us-east-1"
}

variable "ami" {
  type = "map"
  default = {
    "us-east-1" = "ami-db48ada1"
    "us-east-2" = "ami-d61133b3"
  }
}
