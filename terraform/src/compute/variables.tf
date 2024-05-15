variable "tf_root_path" {}
variable "resource_prefix" {}

variable "elucid_backend_repository" {}
variable "elucid_backend_log_group" {}
variable "elucid_ecs_backend_web" {}
variable "elucid_security_group_ecs_backend" {}
variable "elucid_ecs_service_backend_web" {}

variable "elucid_vpc_id" {}
variable "elucid_security_group_id" {}
variable "elucid_private_subnet_1_id" {}
variable "elucid_private_subnet_2_id" {}
variable "elucid_lb_target_group_arn" {}