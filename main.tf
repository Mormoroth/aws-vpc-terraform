provider "aws" {
  region = var.region
}

resource "aws_vpc" "kubernetes_cluster_vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  tags = {
    "Name" = "Kubernetes-VPC"
  }
}

resource "aws_subnet" "Public-Subnet-1" {
  vpc_id                  = aws_vpc.kubernetes_cluster_vpc.id
  cidr_block              = var.public_subnet_1_cidr
  availability_zone       = "${var.region}a"
  map_public_ip_on_launch = true

  tags = {
    "Name" = "Public-Subnet-1"
  }
}

resource "aws_subnet" "Public-Subnet-2" {
  vpc_id                  = aws_vpc.kubernetes_cluster_vpc.id
  cidr_block              = var.public_subnet_2_cidr
  availability_zone       = "${var.region}b"
  map_public_ip_on_launch = true

  tags = {
    "Name" = "Public-Subnet-2"
  }
}

resource "aws_subnet" "Private-Subnet-1" {
  vpc_id            = aws_vpc.kubernetes_cluster_vpc.id
  cidr_block        = var.private_subnet_1_cidr
  availability_zone = "${var.region}a"

  tags = {
    "Name" = "Private-Subnet-1"
  }
}

resource "aws_subnet" "Private-Subnet-2" {
  vpc_id            = aws_vpc.kubernetes_cluster_vpc.id
  cidr_block        = var.private_subnet_2_cidr
  availability_zone = "${var.region}b"

  tags = {
    "Name" = "Private-Subnet-2"
  }
}