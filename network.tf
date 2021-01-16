locals {
  az_count = length(
    slice(
      data.aws_availability_zones.available.names,
      0,
      min(
        var.max_az_count,
        length(data.aws_availability_zones.available.names)
      )
    )
  )
}

##################################################################################
# VPC and Subnets
##################################################################################

resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/20"
  enable_dns_hostnames = true
}

resource "aws_subnet" "public_subnets" {
  count                   = local.az_count
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.${count.index}.0/24"
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = true
}

resource "aws_subnet" "private_subnets" {
  count                   = local.az_count
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.${count.index + var.max_az_count - 1}.0/24"
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = false
}

##################################################################################
# Gateways
##################################################################################

resource "aws_internet_gateway" "main_gateway" {
  vpc_id = aws_vpc.main.id
}

resource "aws_eip" "eip" {
  vpc = true
}

resource "aws_nat_gateway" "nat_gateway" {
  allocation_id = aws_eip.eip.id
  subnet_id     = aws_subnet.public_subnets[0].id
  depends_on    = [aws_internet_gateway.main_gateway]
}

##################################################################################
# Routes
##################################################################################

resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main_gateway.id
  }
}

resource "aws_route_table_association" "public_route_association" {
  count          = local.az_count
  subnet_id      = element(aws_subnet.public_subnets.*.id, count.index)
  route_table_id = aws_route_table.public_route_table.id
}

resource "aws_route_table" "private_route_table" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gateway.id
  }
}

resource "aws_route_table_association" "private_route_association" {
  count          = local.az_count
  subnet_id      = element(aws_subnet.private_subnets.*.id, count.index)
  route_table_id = aws_route_table.private_route_table.id
}

##################################################################################
# Security Groups
##################################################################################

resource "aws_security_group" "main_sg" {
  vpc_id = aws_vpc.main.id

  ingress {
    protocol  = -1
    self      = true
    from_port = 0
    to_port   = 0
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

##################################################################################
# Miscellaneous
##################################################################################

resource "aws_db_subnet_group" "private_db_subnet_group" {
  name = "private"
  # Max RDS AZ count of 3
  subnet_ids = slice(aws_subnet.private_subnets.*.id, 0, 3)
}

resource "aws_vpc_endpoint" "secrets_manager_vpc_endpoint" {
  vpc_id              = aws_vpc.main.id
  subnet_ids          = aws_subnet.private_subnets.*.id
  service_name        = "com.amazonaws.${data.aws_region.current.name}.secretsmanager"
  vpc_endpoint_type   = "Interface"
  private_dns_enabled = true

  security_group_ids = [
    aws_security_group.main_sg.id,
  ]
}

resource "aws_acm_certificate" "acm_cert" {
  domain_name               = "gomfd.com"
  subject_alternative_names = ["*.gomfd.com"]
  validation_method         = "DNS"

  lifecycle {
    create_before_destroy = true
  }
}
