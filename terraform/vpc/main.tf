
terraform {
  backend "s3" {
    key = "runway/vpc"
  }
}

data "aws_availability_zones" "available_az" {}

locals {
  vpc_name = "${var.environment}-vpc-${var.aws_region}"
}

# Create a new VPC - the main CIDR range is 10.0.0.0/16
resource "aws_vpc" "vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = merge(var.tags, tomap({ "Name" = local.vpc_name }))

  lifecycle {
    ignore_changes = [tags]
  }
}


############### Internet Gateway
# Create an internet gateway to be attached to public Route tables
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id
  tags   = merge(var.tags, tomap({ "Name" = local.vpc_name }))
}

############### Subnets
# Create three public subnets - give them the follwoing ranges: 10.0.0.0/20, 10.0.16.0/20 & 10.0.32.0/20
resource "aws_subnet" "public_subnets" {
  count             = var.az_count
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = cidrsubnet(var.vpc_cidr, 4, count.index + 0)
  availability_zone = data.aws_availability_zones.available_az.names[count.index]

  tags = merge(var.tags, tomap({ "Name" = "${local.vpc_name}-public-subnet-${count.index + 1}" }))

  lifecycle {
    ignore_changes = [tags]
  }
}

# Create three private subnets - give them the follwoing ranges: 10.0.48.0/20, 10.0.64.0/20 & 10.0.80.0/20
resource "aws_subnet" "private_subnets" {
  count             = var.az_count
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = cidrsubnet(var.vpc_cidr, 4, count.index + 3)
  availability_zone = data.aws_availability_zones.available_az.names[count.index]

  tags = merge(var.tags, tomap({ "Name" = "${local.vpc_name}-private-subnet-${count.index + 1}" }))

  lifecycle {
    ignore_changes = [tags]
  }
}

############### Route tables
# Create the public routes, route tables, igw and associate it with the public subnets
resource "aws_route_table" "public_route" {
  vpc_id = aws_vpc.vpc.id
  count  = var.az_count
  tags   = merge(var.tags, tomap({ "Name" = "${local.vpc_name}-public-rt-${count.index + 1}" }))
}

resource "aws_route" "public_igw" {
  count                  = var.az_count
  route_table_id         = element(aws_route_table.public_route.*.id, count.index)
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
}

resource "aws_route_table_association" "public_route_assoc" {
  count          = var.az_count
  subnet_id      = element(aws_subnet.public_subnets.*.id, count.index)
  route_table_id = element(aws_route_table.public_route.*.id, count.index)
}

# Create the private routes, route tables and associate it with the private subnets
resource "aws_route_table" "private_route" {
  count  = var.az_count
  vpc_id = aws_vpc.vpc.id
  tags   = merge(var.tags, tomap({ "Name" = "${local.vpc_name}-private-rt-${count.index + 1}" }))
}

resource "aws_route_table_association" "private_route_assoc" {
  count          = var.az_count
  subnet_id      = element(aws_subnet.private_subnets.*.id, count.index)
  route_table_id = element(aws_route_table.private_route.*.id, count.index)
}

