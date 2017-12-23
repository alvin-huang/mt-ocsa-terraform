provider "aws" {
  version = "~> 1.6"
  region  = "us-east-2"
}

resource "aws_instance" "example" {
  ami           = "ami-2757f631"
  instance_type = "t2.micro"
}
