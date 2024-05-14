output "tracetech_traces_rds_subnet_group_name" {
    value = aws_db_subnet_group.tracetech_traces_rds_subnet_group.name
}

output "tracetech_traces_rds_security_group_id" {
    value = aws_security_group.tracetech_traces_rds_security_group.id
}

output "tracetech_traces_lambda_security_group_id" {
    value = aws_security_group.tracetech_traces_lambda_security_group.id
}