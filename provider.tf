terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.22"
    }
  }
}

provider "aws" {
#Authentication method as per best practices needed
  region = "eu-west-1" # Choose the appropriate region
}

