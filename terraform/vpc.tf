

resource "aws_vpc" "vpc" {
  cidr_block           = var.vpc-cidr
  instance_tenancy     = "default"
  enable_dns_hostnames = true
  tags = {
    Name = "Bitwarden_VPC"
  }
}

# Create Internet Gateway and Attach it to VPC

resource "aws_internet_gateway" "internet-gateway" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name = "Internet_Gateway"
  }
}

# Create Route Table and Add Public Route

resource "aws_route_table" "public-route-table" {
  vpc_id = aws_vpc.vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.internet-gateway.id
  }
  tags = {
    Name = "Public Route Table"
  }
}

# Create Public Subnet 1

resource "aws_subnet" "public-subnet-1" {
  vpc_id                  = aws_vpc.vpc.id
  availability_zone       = var.aws_availability_zone
  cidr_block              = var.Public_Subnet_1
  map_public_ip_on_launch = true
  tags = {
    Name = "BitWarden-Public-Subnet"
  }
}

# Create Private Subnet 1

resource "aws_subnet" "private-subnet-1" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = var.Private_Subnet_1
  map_public_ip_on_launch = false
  tags = {
    Name = "BitWarden-Private-Subnet"
  }
}

# Associate Public Subnet 1 to "Public Route Table"

resource "aws_route_table_association" "public-subnet-1-route-table-association" {
  subnet_id      = aws_subnet.public-subnet-1.id
  route_table_id = aws_route_table.public-route-table.id
}

# Create Security Group to allow SSH and HTTP/HTTPS traffic

resource "aws_security_group" "bitwarden-security-group" {
  name        = "Web Server Security Group"
  description = "Enable SSH/HTTP/HTTPS access on Port 22/80/443"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    description = "Allow SSH Access"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = var.ssh_location
  }

  ingress {
    description = "Allow HTTP Access"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow HTTPS Access"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "Web Server Security Group"
  }
}
