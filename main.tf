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