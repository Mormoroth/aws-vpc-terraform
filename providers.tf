terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
  backend "s3" {
    bucket = "mormoroth-tf-state"
    key    = "terraform/state"
    region = "us-west-2"
  }
}