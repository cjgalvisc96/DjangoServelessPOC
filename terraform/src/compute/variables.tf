variable "env" {}
variable "tf_module_path" {}


variable "tracetech_subnet_id" {}
variable "tracetech_traces_lambda_security_group_id" {}
variable "tracetech_traces_rds_security_group_id" {}
variable "tracetech_shared_lambda_layer_arn" {}

variable "aws_cloudwatch_log_group__retention_in_days" {}
variable "aws_lambda_layer__compatible_runtimes" {}
variable "aws_lambda_function__runtime" {}
variable "aws_lambda_function__timeout" {}
variable "aws_lambda_function__memory_size" {}
