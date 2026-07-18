terraform {
  required_version = ">= 1.6.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

# 1. Isolated Private Cloud Network
resource "aws_vpc" "production_network" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  tags = {
    Name = "Production-VPC"
  }
}

# 2. Public Facing Edge Gateway
resource "aws_internet_gateway" "gateway" {
  vpc_id = aws_vpc.production_network.id
  tags = {
    Name = "Main-Gateway"
  }
}

# 3. Public Network Layer (Ingress Traffic Proxy Zone)
resource "aws_subnet" "public_zone" {
  vpc_id                  = aws_vpc.production_network.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "${var.aws_region}a"
  map_public_ip_on_launch = true
  tags = {
    Name = "Public-Subnet"
  }
}

# 4. Private Network Layer (Isolated Application Engine Zone)
resource "aws_subnet" "private_zone" {
  vpc_id            = aws_vpc.production_network.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "${var.aws_region}a"
  tags = {
    Name = "Private-Subnet"
  }
}

# 5. Routing Engine Mapping
resource "aws_route_table" "public_routing" {
  vpc_id = aws_vpc.production_network.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gateway.id
  }
  tags = {
    Name = "Public-Routing-Table"
  }
}

resource "aws_route_table_association" "public_association" {
  subnet_id      = aws_subnet.public_zone.id
  route_table_id = aws_route_table.public_routing.id
}

# 6. Edge Firewall Constraints (Proxy Instance Rules)
resource "aws_security_group" "proxy_security" {
  name        = "proxy-security-group"
  description = "Filters edge traffic entering the infrastructure"
  vpc_id      = aws_vpc.production_network.id

  ingress {
    description = "Allow global web browsing"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow admin administrative control"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.administrator_ip]
  }

  egress {
    description = "Allow unrestricted outbound calls for package tracking"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Proxy-Security-Group"
  }
}

# 7. Core Application Isolation Firewall Constraints (App Instance Rules)
resource "aws_security_group" "internal_app_security" {
  name        = "app-security-group"
  description = "Restricts incoming packets exclusively to upstream edge nodes"
  vpc_id      = aws_vpc.production_network.id

  ingress {
    description     = "Allow packets strictly routed through public proxy group"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.proxy_security.id]
  }

  egress {
    description = "Allow internal outbound updates"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "App-Security-Group"
  }
}
 
# 8. Public Ingress Edge Proxy Node
resource "aws_instance" "proxy_node" {
  ami                    = "ami-007020fd9c84e18c77" # Official Ubuntu 24.04 LTS in ap-south-1 (Mumbai)
  instance_type          = "t3.micro"
  subnet_id              = aws_subnet.public_zone.id
  vpc_security_group_ids = [aws_security_group.proxy_security.id]

  # Correctly reads the shell script from the parent scripts directory relative to this module
  user_data              = file("${path.module}/../scripts/secure-host.sh")
}

# 9. Private Application Runtime Node
resource "aws_instance" "app_node" {
  ami                    = "ami-007020fd9c84e18c7"
  instance_type          = "t3.micro"
  subnet_id              = aws_subnet.private_zone.id
  vpc_security_group_ids = [aws_security_group.internal_app_security.id]

  user_data = file("${path.module}/../scripts/secure-host.sh")

  tags = {
    Name = "Private-App-Worker"
  }
}