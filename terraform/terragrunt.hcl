locals {
  # Only works with folders naming with "3" letters(ex: "loc", "dev", "pro")
  env                 = substr(path_relative_to_include(), -3, -1)
  tf_module_path      = get_parent_terragrunt_dir()
}

inputs = {
  env                 = local.env
  tf_module_path      = local.tf_module_path
  project_name        = "django_serveless_poc"
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
        elb             = "http://localhost:4566"
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

      variable "aws_subnet__availability_zones" {
        type = list(string)
      }
    EOF
}