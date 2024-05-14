include {
    path = find_in_parent_folders()
}

terraform {
    source = "../..//src"
}


inputs = {
    # Module: Network
    aws_subnet_rds__cidr_block                  = "10.16.3.0/24"
    aws_subnet_rds__availability_zone           = "us-east-1c"

    # Module: Storage
    aws_rds_cluster__engine                     = "aurora-postgresql"
    aws_rds_cluster__engine_version             = "16.1"
    aws_rds_cluster__master_username            = get_env("TRACES_DB_USERNAME", "")
    aws_rds_cluster__master_password            = get_env("TRACES_DB_PASSWORD", "")
    aws_rds_cluster__skip_final_snapshot        = false
    aws_rds_cluster__final_snapshot_identifier  = "dev-traces-db-snap" # Only alphanumeric characters and hyphens allowed 
    aws_rds_cluster__backup_retention_period    = 5
    aws_rds_cluster__preferred_backup_window    = "03:00-06:00"
    aws_rds_cluster__preferred_maintenance_window = "Sat:08:00-Sat:09:00"  

    aws_rds_cluster_instance__count             = 1
    aws_rds_cluster_instance__instance_class    = "db.t4g.medium"

    # Module: Compute
    aws_cloudwatch_log_group__retention_in_days = 30
    aws_lambda_layer__compatible_runtimes       = ["python3.11"]
    aws_lambda_function__runtime                = "python3.11"
    aws_lambda_function__timeout                = 60 # Seconds
    aws_lambda_function__memory_size            = 1024 # MB
}