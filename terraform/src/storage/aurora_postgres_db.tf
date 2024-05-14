resource "aws_rds_cluster" "tracetech_traces_rds_cluster" {
  cluster_identifier      = "${var.env}-tracetech-traces-rds-cluster"
  database_name           = "${var.env}_traces_db"

  engine                  = var.aws_rds_cluster__engine
  engine_version          = var.aws_rds_cluster__engine_version

  master_username         = var.aws_rds_cluster__master_username
  master_password         = var.aws_rds_cluster__master_password

  # Enable automated backups
  skip_final_snapshot       = var.aws_rds_cluster__skip_final_snapshot
  final_snapshot_identifier = var.aws_rds_cluster__final_snapshot_identifier
  backup_retention_period   = var.aws_rds_cluster__backup_retention_period
  preferred_backup_window   = var.aws_rds_cluster__preferred_backup_window
  preferred_maintenance_window = var.aws_rds_cluster__preferred_maintenance_window

  vpc_security_group_ids    = [var.tracetech_traces_rds_security_group_id]
  db_subnet_group_name      = var.aws_rds_cluster__db_subnet_group_name

  tags = {
    Name    = "${var.env}-tracetech-traces-rds-cluster"
  }
}

resource "aws_rds_cluster_instance" "tracetech_traces_rds_cluster_instances" {
  count                = var.aws_rds_cluster_instance__count

  identifier           = "${var.env}-traces-db-${count.index + 1}"
  instance_class       = var.aws_rds_cluster_instance__instance_class
  db_subnet_group_name = var.aws_rds_cluster__db_subnet_group_name

  cluster_identifier   = aws_rds_cluster.tracetech_traces_rds_cluster.id
  engine               = aws_rds_cluster.tracetech_traces_rds_cluster.engine
  engine_version       = aws_rds_cluster.tracetech_traces_rds_cluster.engine_version

  tags = {
    Name    = "${var.env}-traces-db-${count.index + 1}"
  }
}