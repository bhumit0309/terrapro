terraform {

  backend "s3" {
    bucket = "tf-project-65536"
    key    = "terraform.tfstate"
    region = "ca-central-1"
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.8.0"
    }
  }
}

provider "aws" {
  region = "ca-central-1"
}