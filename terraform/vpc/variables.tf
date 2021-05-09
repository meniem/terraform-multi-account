
variable "aws_region" {
  description = "AWS region."
}

variable "environment" {
  description = "Environment."
}

variable "tags" {
  description = "tags to propogate to all supported resources"
}

variable "vpc_cidr" {
  description = "CIDR associated with the VPC to be created"
}

variable "az_count" {
  description = "the number of AZs to deploy infrastructure to"
}

