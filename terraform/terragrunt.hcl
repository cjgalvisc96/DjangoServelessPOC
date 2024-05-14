locals {
  # Only works with folders naming with "3" letters(ex: "loc", "dev", "pro")
  env                 = substr(path_relative_to_include(), -3, -1)
  tf_module_path      = get_parent_terragrunt_dir()
}

inputs = {
  env                 = local.env
  tf_module_path      = local.tf_module_path
  project_name        = "elucid"
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
      version                     = "= 5.45"
      s3_use_path_style           = true
      # s3_use_path_style           = false
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
      variable "env" {
        type = string
      }

      variable "tf_module_path" {
        type = string
      }

      variable "project_name" {
        type = string
      }

      # Module: Network
      variable "aws_vpc" {
        type = object({
          cidr_block = string
          enable_dns_support = bool
          enable_dns_hostnames = bool
        })
      }

      variable "aws_subnet" {
        type = object({
          public_cidr_blocks = list(string)
          private_cidr_blocks = list(string)
          availability_zones = list(string)
        })
      }

      variable "aws_route" {
        type = object({
          destination_cidr_block = string
        })
      }

      variable "aws_eip" {
        type = object({
          vpc = bool
          associate_with_private_ip = string
        })
      }

      variable "aws_security_group" {
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

      variable "aws_lb_target_group" {
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

      variable "aws_lb" {
        type = object({
          load_balancer_type = string
          internal = bool
        })
      }

      variable "aws_lb_listener" {
        type = object({
          port = string
          protocol = string
          default_action = object({
            type = string
          })
        })
      }

      # Module: Compute
      variable "aws_ecr_repository" {
        type = object({
          image_tag_mutability = string
        })
      }
    EOF
}