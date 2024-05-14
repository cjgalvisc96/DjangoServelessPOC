variable "env" {}
variable "tracetech_subnet_id" {}
variable "tracetech_traces_rds_security_group_id" {}

variable "aws_rds_cluster__engine" {}
variable "aws_rds_cluster__engine_version" {}
variable "aws_rds_cluster__master_username" {}
variable "aws_rds_cluster__master_password" {}
variable "aws_rds_cluster__skip_final_snapshot" {}
variable "aws_rds_cluster__final_snapshot_identifier" {}
variable "aws_rds_cluster__backup_retention_period" {}
variable "aws_rds_cluster__preferred_backup_window" {}
variable "aws_rds_cluster__preferred_maintenance_window" {}

variable "aws_rds_cluster__db_subnet_group_name" {}
variable "aws_rds_cluster_instance__count" {}
variable "aws_rds_cluster_instance__instance_class" {}