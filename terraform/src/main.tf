module "network" {
  source                                      = "./network"

  resource_prefix                             = var.resource_prefix

  elucid_vpc                                  = var.elucid_vpc
  elucid_public_subnet_1                      = var.elucid_public_subnet_1
  elucid_public_subnet_2                      = var.elucid_public_subnet_2
  elucid_private_subnet_1                     = var.elucid_private_subnet_1
  elucid_private_subnet_2                     = var.elucid_private_subnet_2
  elucid_internet_gateway_route               = var.elucid_internet_gateway_route
  elucid_nat_gateway_route                    = var.elucid_nat_gateway_route
  elucid_eip                                  = var.elucid_eip
  elucid_security_group                       = var.elucid_security_group
  elucid_lb_target_group                      = var.elucid_lb_target_group
  elucid_lb                                   = var.elucid_lb
  elucid_lb_listener                          = var.elucid_lb_listener
}

module "compute" {
  source                                      = "./compute"

  tf_root_path                                = var.tf_root_path
  resource_prefix                             = var.resource_prefix

  elucid_backend_repository                   = var.elucid_backend_repository
  elucid_backend_log_group                    = var.elucid_backend_log_group
  elucid_ecs_backend_web                      = var.elucid_ecs_backend_web
  elucid_security_group_ecs_backend           = var.elucid_security_group_ecs_backend
  elucid_ecs_service_backend_web              = var.elucid_ecs_service_backend_web

  elucid_vpc_id                               = module.network.elucid_vpc_id
  elucid_security_group_id                    = module.network.elucid_security_group_id
  elucid_private_subnet_1_id                  = module.network.elucid_private_subnet_1_id
  elucid_private_subnet_2_id                  = module.network.elucid_private_subnet_2_id
  elucid_lb_target_group_arn                  = module.network.elucid_lb_target_group_arn
}