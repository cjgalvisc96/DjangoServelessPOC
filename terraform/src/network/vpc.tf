resource "aws_subnet" "tracetech_traces_rds_subnet" {
  vpc_id            = var.tracetech_vpc_id
  cidr_block        = var.aws_subnet_rds__cidr_block 
  availability_zone = var.aws_subnet_rds__availability_zone

  tags = {
    Name    = "${var.env}_tracetech_traces_rds_subnet"
  }
}

resource "aws_db_subnet_group" "tracetech_traces_rds_subnet_group" {
  name       = "${var.env}_tracetech_traces_rds_subnet_group"
  subnet_ids = [var.tracetech_subnet_id, aws_subnet.tracetech_traces_rds_subnet.id]

  tags = {
    Name = "${var.env}_tracetech_traces_rds_subnet_group"
  }
}

resource "aws_security_group" "tracetech_traces_lambda_security_group" {
  name        = "${var.env}_tracetech_traces_lambda_security_group"
  vpc_id      = var.tracetech_vpc_id

  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name    = "${var.env}_tracetech_traces_lambda_security_group"
  }
}

resource "aws_security_group" "tracetech_traces_rds_security_group" {
  name        = "${var.env}_tracetech_traces_rds_security_group"
  vpc_id      = var.tracetech_vpc_id
  
  ingress {
    protocol        = "tcp"
    from_port       = 5432
    to_port         = 5432
    security_groups = [aws_security_group.tracetech_traces_lambda_security_group.id]
  }

  tags = {
    Name    = "${var.env}_tracetech_traces_rds_security_group"
  }
}