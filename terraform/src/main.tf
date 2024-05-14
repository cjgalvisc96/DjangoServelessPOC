module "network" {
  source                                      = "./network"

  env                                         = var.env
  tf_module_path                              = var.tf_module_path
  project_name                                = var.project_name

  aws_subnet__availability_zones              = var.aws_subnet__availability_zones
}

module "compute" {
  source                                      = "./compute"

  env                                         = var.env
  tf_module_path                              = var.tf_module_path
  project_name                                = var.project_name
}