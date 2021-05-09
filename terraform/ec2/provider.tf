provider "aws" {
  region  = var.aws_region
  version = "~> 3.39"
}

data "aws_caller_identity" "current" {}

terraform {
  backend "s3" {
    key = "runway/ec2"
  }
}

data "terraform_remote_state" "vpc" {
  backend = "s3"
  config = {
    bucket = "challenge-task-terraform-state-us-east-1"
    key    = "env:/${var.environment}/runway/vpc"
    region = "us-east-1"
  }
}
