terraform {
  backend "s3" {
    bucket = "mtscloudcop-tf-state"
    key    = "puppet/terraform.tfstate"
    region = "us-east-1"
  }
}

data "terraform_remote_state" "network" {
  backend = "s3"
  config {
    bucket = "mtscloudcop-tf-state"
    key    = "puppet/terraform.tfstate"
    region = "us-east-1"
  }
}

module "puppet" {
  source = "./puppet"
}
