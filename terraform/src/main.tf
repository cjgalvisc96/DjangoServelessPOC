module "compute" {
  source                                      = "./compute"

  env                                         = var.env
  tf_module_path                              = var.tf_module_path
  project_name                                = var.project_name
}