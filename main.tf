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


resource "aws_route_table" "Public-Route-Table" {
  vpc_id = aws_vpc.kubernetes_cluster_vpc.id

  tags = {
    "Name" = "Public-Route-Table"
  }
}

resource "aws_route_table" "Private-Route-Table" {
  vpc_id = aws_vpc.kubernetes_cluster_vpc.id

  tags = {
    "Name" = "Private-Route-Table"
  }

}

resource "aws_route_table_association" "Public_Subnet_1_Association" {
  route_table_id = aws_route_table.Public-Route-Table.id
  subnet_id      = aws_subnet.Public-Subnet-1.id
}

resource "aws_route_table_association" "Public_Subnet_2_Association" {
  route_table_id = aws_route_table.Public-Route-Table.id
  subnet_id      = aws_subnet.Public-Subnet-2.id
}


resource "aws_route_table_association" "Private_Subnet_1_Association" {
  route_table_id = aws_route_table.Private-Route-Table.id
  subnet_id      = aws_subnet.Private-Subnet-1.id
}

resource "aws_route_table_association" "Private_Subnet_2_Association" {
  route_table_id = aws_route_table.Private-Route-Table.id
  subnet_id      = aws_subnet.Private-Subnet-2.id
}

resource "aws_internet_gateway" "vpc_igw" {
  vpc_id = aws_vpc.kubernetes_cluster_vpc.id

  tags = {
    "Name" = "VPC-IGW"
  }
}

resource "aws_route" "vpc_igw_route" {
  route_table_id         = aws_route_table.Public-Route-Table.id
  gateway_id             = aws_internet_gateway.vpc_igw.id
  destination_cidr_block = "0.0.0.0/0"
}

data "aws_ami" "amazon-linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm*"]
  }
}

resource "aws_key_pair" "ssh_key" {
  key_name   = "morteza"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC6FD3ip8rSv4GqUBeGjcx5mGAWlL0h/bcWb335Mzyyb0pfhGlaNgh9ALBmD3cJWGde4jtQ90QUE2lH5vThNv+BwV7pXiibTCaZxhELQdDaED4XROTyC+++WspHL2US24OW1et2n0cZvQue1QGKnN9M2BQpA+aSCiZCx/Qb9vJTlblY2g/FHv2lmVkDxdC5K3tmeiBOq7iwH5qtAupqGU5ohQ85XSVh7biRfb9CaoKnrmlsjvglZV/EmN1ZtjoplnEiBf6w0SqEyLKOMjCStmw4aURq1F7ziD9nxHB6pPvrM5TGI3QjNN83243gRQNvYbiQW4NLKxjlAZgbdrzJP+P5 mormoroth"

}

resource "aws_security_group" "ec2-sg" {
  name   = "EC2-SG"
  vpc_id = aws_vpc.kubernetes_cluster_vpc.id

  ingress = [{
    cidr_blocks      = ["0.0.0.0/0"]
    description      = "SG-IN"
    from_port        = 0
    ipv6_cidr_blocks = []
    prefix_list_ids  = []
    protocol         = -1
    security_groups  = []
    self             = false
    to_port          = 0
  }]

  egress = [{
    cidr_blocks      = ["0.0.0.0/0"]
    description      = "SG-OUT"
    from_port        = 0
    ipv6_cidr_blocks = []
    prefix_list_ids  = []
    protocol         = -1
    self             = false
    security_groups  = []
    to_port          = 0
  }]

}

resource "aws_instance" "public-ec2-instance" {
  ami             = data.aws_ami.amazon-linux.id
  instance_type   = var.ec2_instance_type
  key_name        = aws_key_pair.ssh_key.key_name
  subnet_id       = aws_subnet.Public-Subnet-1.id
  security_groups = [aws_security_group.ec2-sg.id]
}

resource "aws_instance" "private-ec2-instance" {
  ami             = data.aws_ami.amazon-linux.id
  instance_type   = var.ec2_instance_type
  key_name        = aws_key_pair.ssh_key.key_name
  subnet_id       = aws_subnet.Private-Subnet-1.id
  security_groups = [aws_security_group.ec2-sg.id]
}
