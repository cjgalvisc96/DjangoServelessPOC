## VPCS
resource "aws_vpc" "elucid_vpc" {
  cidr_block           = var.elucid_vpc.cidr_block
  enable_dns_support   = var.elucid_vpc.enable_dns_support
  enable_dns_hostnames = var.elucid_vpc.enable_dns_hostnames

  tags = {
    Name    = "${var.resource_prefix}-vpc"
  }
}

## SUBNETS
### PUBLIC SUBNETS
resource "aws_subnet" "elucid_public_subnet_1" {
  cidr_block        = var.elucid_public_subnet_1.cidr_block
  vpc_id            = aws_vpc.elucid_vpc.id
  availability_zone = var.elucid_public_subnet_1.availability_zones

  tags = {
    Name    = "${var.resource_prefix}-public-subnet-1"
  }
}

resource "aws_subnet" "elucid_public_subnet_2" {
  cidr_block        = var.elucid_public_subnet_2.cidr_block
  vpc_id            = aws_vpc.elucid_vpc.id
  availability_zone = var.elucid_public_subnet_2.availability_zones

  tags = {
    Name    = "${var.resource_prefix}-public-subnet-2"
  }
}

### PRIVATE SUBNETS
resource "aws_subnet" "elucid_private_subnet_1" {
  cidr_block        = var.elucid_private_subnet_1.cidr_block
  vpc_id            = aws_vpc.elucid_vpc.id
  availability_zone = var.elucid_private_subnet_1.availability_zones

  tags = {
    Name    = "${var.resource_prefix}-private-subnet-1"
  }
}

resource "aws_subnet" "elucid_private_subnet_2" {
  cidr_block        = var.elucid_private_subnet_2.cidr_block
  vpc_id            = aws_vpc.elucid_vpc.id
  availability_zone = var.elucid_private_subnet_2.availability_zones

  tags = {
    Name    = "${var.resource_prefix}-private-subnet-2"
  }
}

## ROUTE TABLES
### PUBLIC ROUTE TABLE
resource "aws_route_table" "elucid_public_route_table" {
  vpc_id = aws_vpc.elucid_vpc.id

  tags = {
    Name    = "${var.resource_prefix}-public-route-table"
  }
}

resource "aws_route_table_association" "elucid_public_route_table_subnet_1" {
  route_table_id = aws_route_table.elucid_public_route_table.id
  subnet_id      = aws_subnet.elucid_public_subnet_1.id
}

resource "aws_route_table_association" "elucid_public_route_table_subnet_2" {
  route_table_id = aws_route_table.elucid_public_route_table.id
  subnet_id      = aws_subnet.elucid_public_subnet_2.id
}
### PRIVATE ROUTE TABLE
resource "aws_route_table" "elucid_private_route_table" {
  vpc_id = aws_vpc.elucid_vpc.id

  tags = {
    Name    = "${var.resource_prefix}-private-route-table"
  }
}

resource "aws_route_table_association" "elucid_private_route_table_subnet_1" {
  route_table_id = aws_route_table.elucid_private_route_table.id
  subnet_id      = aws_subnet.elucid_private_subnet_1.id
}

resource "aws_route_table_association" "elucid_private_route_table_subnet_2" {
  route_table_id = aws_route_table.elucid_private_route_table.id
  subnet_id      = aws_subnet.elucid_private_subnet_2.id
}

## INTERNET GATEWAY(for the public subnet)
resource "aws_internet_gateway" "elucid_internet_gateway" {
  vpc_id = aws_vpc.elucid_vpc.id

  tags = {
    Name    = "${var.resource_prefix}-internet-gateway"
  }
}

resource "aws_route" "elucid_internet_gateway_route" {
  route_table_id         = aws_route_table.elucid_public_route_table.id
  gateway_id             = aws_internet_gateway.elucid_internet_gateway.id
  destination_cidr_block = var.elucid_internet_gateway_route.destination_cidr_block 
}

# TODO: Include for aws deploy(this isn't current supported by Localstack)
## NAT GATEWAY
# resource "aws_eip" "elucid_eip" { # Elastic IP
#   # vpc                       = var.elucid_eip.vpc # Deprecated
#   associate_with_private_ip = var.elucid_eip.associate_with_private_ip
#   depends_on                = [aws_internet_gateway.elucid_internet_gateway]

#   tags = {
#     Name    = "${var.resource_prefix}-eip"
#   }
# }

resource "aws_nat_gateway" "elucid_nat_gateway" {
  # allocation_id = aws_eip.elucid_eip.id
  subnet_id     = aws_subnet.elucid_public_subnet_1.id

  tags = {
    Name    = "${var.resource_prefix}-nat-gateway"
  }
}

resource "aws_route" "elucid_nat_gateway_route" {
  route_table_id         = aws_route_table.elucid_private_route_table.id
  nat_gateway_id         = aws_nat_gateway.elucid_nat_gateway.id
  destination_cidr_block = var.elucid_nat_gateway_route.destination_cidr_block 
}