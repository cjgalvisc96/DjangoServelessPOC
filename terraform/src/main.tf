module "network" {
  source                                      = "./network"

  env                                         = var.env
  tf_module_path                              = var.tf_module_path
  project_name                                = var.project_name

  aws_vpc                                     = var.aws_vpc
  aws_subnet                                  = var.aws_subnet
  aws_route                                   = var.aws_route
  aws_eip                                     = var.aws_eip
  aws_security_group                          = var.aws_security_group
  aws_lb_target_group                         = var.aws_lb_target_group
  aws_lb                                      = var.aws_lb
  aws_lb_listener                             = var.aws_lb_listener
}

module "compute" {
  source                                      = "./compute"

  env                                         = var.env
  tf_module_path                              = var.tf_module_path
  project_name                                = var.project_name

  aws_ecr_repository                          = var.aws_ecr_repository
}