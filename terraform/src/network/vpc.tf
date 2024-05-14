## VPCS
resource "aws_vpc" "elucid_vpc" {
  cidr_block           = var.aws_vpc.cidr_block
  enable_dns_support   = var.aws_vpc.enable_dns_support
  enable_dns_hostnames = var.aws_vpc.enable_dns_hostnames

  tags = {
    Name    = "${var.env}_${var.project_name}_vpc"
  }
}

## SUBNETS
### PUBLIC SUBNETS
resource "aws_subnet" "elucid_public_subnet_1" {
  cidr_block        = var.aws_subnet.public_cidr_blocks[0]
  vpc_id            = aws_vpc.elucid_vpc.id
  availability_zone = var.aws_subnet.availability_zones[0]

  tags = {
    Name    = "${var.env}_${var.project_name}_public_subnet_1"
  }
}

resource "aws_subnet" "elucid_public_subnet_2" {
  cidr_block        = var.aws_subnet.public_cidr_blocks[1]
  vpc_id            = aws_vpc.elucid_vpc.id
  availability_zone = var.aws_subnet.availability_zones[1]

  tags = {
    Name    = "${var.env}_${var.project_name}_public_subnet_2"
  }
}

### PRIVATE SUBNETS
resource "aws_subnet" "elucid_private_subnet_1" {
  cidr_block        = var.aws_subnet.private_cidr_blocks[0]
  vpc_id            = aws_vpc.elucid_vpc.id
  availability_zone = var.aws_subnet.availability_zones[0]

  tags = {
    Name    = "${var.env}_${var.project_name}_private_subnet_1"
  }
}

resource "aws_subnet" "elucid_private_subnet_2" {
  cidr_block        = var.aws_subnet.private_cidr_blocks[1]
  vpc_id            = aws_vpc.elucid_vpc.id
  availability_zone = var.aws_subnet.availability_zones[1]

  tags = {
    Name    = "${var.env}_${var.project_name}_private_subnet_2"
  }
}

## ROUTE TABLES
### PUBLIC ROUTE TABLE
resource "aws_route_table" "elucid_public_route_table" {
  vpc_id = aws_vpc.elucid_vpc.id

  tags = {
    Name    = "${var.env}_${var.project_name}_public_route_table"
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
    Name    = "${var.env}_${var.project_name}_private_route_table"
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
    Name    = "${var.env}_${var.project_name}_internet_gateway"
  }
}

resource "aws_route" "elucid_internet_gateway_route" {
  route_table_id         = aws_route_table.elucid_public_route_table.id
  gateway_id             = aws_internet_gateway.elucid_internet_gateway.id
  destination_cidr_block = var.aws_route.destination_cidr_block 
}

## NAT GATEWAY
# resource "aws_eip" "elucid_eip" { # Elastic IP
#   # vpc                       = var.aws_eip.vpc # Deprecated
#   associate_with_private_ip = var.aws_eip.associate_with_private_ip
#   depends_on                = [aws_internet_gateway.elucid_internet_gateway]

#   tags = {
#     Name    = "${var.env}_${var.project_name}_eip"
#   }
# }

resource "aws_nat_gateway" "elucid_nat_gateway" {
  # allocation_id = aws_eip.elucid_eip.id
  subnet_id     = aws_subnet.elucid_public_subnet_1.id

  tags = {
    Name    = "${var.env}_${var.project_name}_nat_gateway"
  }
}

resource "aws_route" "eluciud_route" {
  route_table_id         = aws_route_table.elucid_private_route_table.id
  nat_gateway_id         = aws_nat_gateway.elucid_nat_gateway.id
  destination_cidr_block = var.aws_route.destination_cidr_block
}