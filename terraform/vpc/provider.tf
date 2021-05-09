provider "aws" {
  region  = var.aws_region
  version = "~> 3.39"
}

data "aws_caller_identity" "current" {}
