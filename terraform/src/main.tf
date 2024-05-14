data "aws_vpc" "tracetech_vpc" {
  filter {
    name   = "tag:Name"
    values = ["${var.env}_tracetech_vpc"]
  }
}

data "aws_subnet" "tracetech_subnet" {
  filter {
    name   = "tag:Name"
    values = ["${var.env}_tracetech_subnet"]
  }
}

data "aws_lambda_layer_version" "tracetech_shared_lambda_layer" {
  layer_name = "${var.env}_tracetech_shared_lambda_layer_version"
}

module "network" {
  source                                     = "./network"
  env                                        = var.env

  aws_subnet_rds__cidr_block                 = var.aws_subnet_rds__cidr_block
  aws_subnet_rds__availability_zone          = var.aws_subnet_rds__availability_zone

  tracetech_vpc_id                           = data.aws_vpc.tracetech_vpc.id
  tracetech_subnet_id                        = data.aws_subnet.tracetech_subnet.id
}

module "storage" {
  source                                     = "./storage"
  env                                        = var.env
  aws_rds_cluster__engine                    = var.aws_rds_cluster__engine
  aws_rds_cluster__engine_version            = var.aws_rds_cluster__engine_version
  aws_rds_cluster__master_username           = var.aws_rds_cluster__master_username
  aws_rds_cluster__master_password           = var.aws_rds_cluster__master_password
  aws_rds_cluster__skip_final_snapshot       = var.aws_rds_cluster__skip_final_snapshot
  aws_rds_cluster__final_snapshot_identifier = var.aws_rds_cluster__final_snapshot_identifier
  aws_rds_cluster__backup_retention_period   = var.aws_rds_cluster__backup_retention_period
  aws_rds_cluster__preferred_backup_window   = var.aws_rds_cluster__preferred_backup_window
  aws_rds_cluster__preferred_maintenance_window = var.aws_rds_cluster__preferred_maintenance_window
  aws_rds_cluster__db_subnet_group_name      = module.network.tracetech_traces_rds_subnet_group_name

  aws_rds_cluster_instance__count            = var.aws_rds_cluster_instance__count
  aws_rds_cluster_instance__instance_class   = var.aws_rds_cluster_instance__instance_class

  tracetech_subnet_id                        = data.aws_subnet.tracetech_subnet.id
  tracetech_traces_rds_security_group_id      = module.network.tracetech_traces_rds_security_group_id
}

module "compute" {
  source                                      = "./compute"
  depends_on                                  = [module.storage]
  
  tracetech_subnet_id                         = data.aws_subnet.tracetech_subnet.id
  tracetech_shared_lambda_layer_arn           = data.aws_lambda_layer_version.tracetech_shared_lambda_layer.arn
  tracetech_traces_lambda_security_group_id    = module.network.tracetech_traces_lambda_security_group_id
  tracetech_traces_rds_security_group_id       = module.network.tracetech_traces_rds_security_group_id

  env                                         = var.env
  tf_module_path                              = var.tf_module_path
  aws_cloudwatch_log_group__retention_in_days = var.aws_cloudwatch_log_group__retention_in_days 
  aws_lambda_layer__compatible_runtimes       = var.aws_lambda_layer__compatible_runtimes
  aws_lambda_function__runtime                = var.aws_lambda_function__runtime
  aws_lambda_function__timeout                = var.aws_lambda_function__timeout
  aws_lambda_function__memory_size            = var.aws_lambda_function__memory_size
}