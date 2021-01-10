resource "aws_eip" "eip" {
  vpc = true
}

resource "aws_nat_gateway" "nat_gateway" {
  allocation_id = aws_eip.eip.id
  subnet_id     = aws_default_subnet.default_az_d.id
}

resource "aws_db_subnet_group" "private_db_subnet_group" {
  name = "private"
  subnet_ids = [
    aws_default_subnet.default_az_a.id,
    aws_default_subnet.default_az_b.id,
    aws_default_subnet.default_az_c.id
  ]
}

resource "aws_vpc_endpoint" "secrets_manager_vpc_endpoint" {
  vpc_id = aws_default_vpc.default_vpc.id
  subnet_ids = [
    aws_default_subnet.default_az_a.id,
    aws_default_subnet.default_az_b.id,
    aws_default_subnet.default_az_c.id
  ]
  service_name      = "com.amazonaws.${data.aws_region.current.name}.secretsmanager"
  vpc_endpoint_type = "Interface"

  security_group_ids = [
    aws_default_security_group.default_sg.id,
  ]

  private_dns_enabled = true
}

###################################################
# Warning: Route values below convert three of
#   the default public (IGW) subnets into
#   private ones. Proceed cautiously when changing.
###################################################

resource "aws_route_table" "nat_gateway_route_table" {
  vpc_id = aws_default_vpc.default_vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gateway.id
  }
}

resource "aws_route_table_association" "route_association_a" {
  subnet_id      = aws_default_subnet.default_az_a.id
  route_table_id = aws_route_table.nat_gateway_route_table.id
}

resource "aws_route_table_association" "route_association_b" {
  subnet_id      = aws_default_subnet.default_az_b.id
  route_table_id = aws_route_table.nat_gateway_route_table.id
}

resource "aws_route_table_association" "route_association_c" {
  subnet_id      = aws_default_subnet.default_az_c.id
  route_table_id = aws_route_table.nat_gateway_route_table.id
}
