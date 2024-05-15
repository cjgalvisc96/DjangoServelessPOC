locals {
  # Only works with folders naming with "3" letters(ex: "loc", "dev", "pro")
  env                 = substr(path_relative_to_include(), -3, -1)
  tf_root_path        = get_parent_terragrunt_dir()
  project_name        = "elucid"
}

inputs = {
  tf_root_path        = local.tf_root_path
  resource_prefix     = "${local.env}-${local.project_name}"
}

generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF
    # This file is managed by `terragrunt.hcl` file from the root folder, Any changes here will be lost.
    provider "aws" {
      access_key                  = "test"
      secret_key                  = "test"
      profile                     = "localstack"
      region                      = "us-east-1"
      # HACK: To avoid load_balancer_error: 'client_keep_alive .seconds not valid'(Localstack)
      version                     = "= 5.45"
      s3_use_path_style           = true
      skip_credentials_validation = true
      skip_metadata_api_check     = true
      skip_requesting_account_id  = true

      endpoints {
        apigateway      = "http://localhost:4566"
        apigatewayv2    = "http://localhost:4566"
        cloudformation  = "http://localhost:4566"
        cloudwatch      = "http://localhost:4566"
        cognitoidp      = "http://localhost:4566"
        cognitoidentity = "http://localhost:4566"
        dynamodb        = "http://localhost:4566"
        ec2             = "http://localhost:4566"
        ecr             = "http://localhost:4566"
        ecs             = "http://localhost:4566"
        es              = "http://localhost:4566"
        elasticache     = "http://localhost:4566"
        firehose        = "http://localhost:4566"
        iam             = "http://localhost:4566"
        kinesis         = "http://localhost:4566"
        lambda          = "http://localhost:4566"
        rds             = "http://localhost:4566"
        redshift        = "http://localhost:4566"
        route53         = "http://localhost:4566"
        s3             = "http://s3.localhost.localstack.cloud:4566"
        secretsmanager  = "http://localhost:4566"
        ses             = "http://localhost:4566"
        sns             = "http://localhost:4566"
        sqs             = "http://localhost:4566"
        ssm             = "http://localhost:4566"
        stepfunctions   = "http://localhost:4566"
        sts             = "http://localhost:4566"
        # elb             = "http://localhost:4566"
        elbv2           = "http://localhost:4566"
      }
    }
  EOF
}

generate "variables" {
    path = "variables.tf"
    if_exists = "overwrite_terragrunt"

    contents = <<EOF
      variable "tf_root_path" {
        type = string
      }

      variable "resource_prefix" {
        type = string
      }

      # Module: Network
      variable "elucid_vpc" {
        type = object({
          cidr_block = string
          enable_dns_support = bool
          enable_dns_hostnames = bool
        })
      }

      variable "elucid_public_subnet_1" {
        type = object({
          cidr_block = string
          availability_zones = string
        })
      }

      variable "elucid_public_subnet_2" {
        type = object({
          cidr_block = string
          availability_zones = string
        })
      }

      variable "elucid_private_subnet_1" {
        type = object({
          cidr_block = string
          availability_zones = string
        })
      }

      variable "elucid_private_subnet_2" {
        type = object({
          cidr_block = string
          availability_zones = string
        })
      }

      variable "elucid_internet_gateway_route" {
        type = object({
          destination_cidr_block = string
        })
      }

      variable "elucid_nat_gateway_route" {
        type = object({
          destination_cidr_block = string
        })
      }

      variable "elucid_eip" {
        type = object({
          vpc = bool
          associate_with_private_ip = string
        })
      }

      variable "elucid_security_group" {
        type = object({
          ingress_1 = object({
            from_port = number
            to_port = number
            protocol = string
            cidr_blocks = list(string)
          })
          ingress_2 = object({
            from_port = number
            to_port = number
            protocol = string
            cidr_blocks = list(string)
          })
          egress_1 = object({
            from_port = number
            to_port = number
            protocol = string
            cidr_blocks = list(string)
          })
        })
      }

      variable "elucid_lb_target_group" {
        type = object({
          port = number
          protocol = string
          target_type = string
          health_check = object({
            path = string
            port = string
            healthy_threshold = number
            unhealthy_threshold = number
            timeout = number
            interval = number
            matcher = string
          })
        })
      }

      variable "elucid_lb" {
        type = object({
          load_balancer_type = string
          internal = bool
        })
      }

      variable "elucid_lb_listener" {
        type = object({
          port = string
          protocol = string
          default_action = object({
            type = string
          })
        })
      }

      # Module: Compute
      variable "elucid_backend_repository" {
        type = object({
          image_tag_mutability = string
        })
      }

      variable "elucid_backend_log_group" {
        type = object({
          retention_in_days = number
        })
      }

      variable "elucid_ecs_backend_web" {
        type = object({
          network_mode = string
          requires_compatibilities = list(string)
          cpu = string
          memory = string
          family = string
          container_definitions = object({
            region = string
            name = string
            command = list(string)
          })
        })
      }

      variable "elucid_security_group_ecs_backend" {
        type = object({
          ingress = object({
            from_port = number
            to_port = number
            protocol = string
          })
          egress = object({
            from_port = number
            to_port = number
            protocol = string
            cidr_blocks = list(string)
          })
        })
      }

      variable "elucid_ecs_service_backend_web" {
        type = object({
          desired_count = number
          deployment_minimum_healthy_percent = number
          deployment_maximum_percent = number
          launch_type = string
          scheduling_strategy = string
          load_balancer = object({
            container_name = string
            container_port = number
          })
          network_configuration = object({
            assign_public_ip = bool
          })
        })
      }
    EOF
}