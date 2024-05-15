## CLOUDWATCH
resource "aws_cloudwatch_log_group" "elucid_backend_log_group" {
  name              = "${var.resource_prefix}-backend-log-group" 
  retention_in_days = var.elucid_backend_log_group.retention_in_days
}

resource "aws_cloudwatch_log_stream" "elucid_backend_web_log_stream" {
  name           = "${var.resource_prefix}-backend-web-log-stream"
  log_group_name = aws_cloudwatch_log_group.elucid_backend_log_group.name
}

## IAM ROLES AND POLICIES
resource "aws_iam_role" "elucid_iam_role_backend_task" {
  name = "${var.resource_prefix}-iam-role-backend-task"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        },
        Effect = "Allow",
        Sid    = ""
      }
    ]
  })
}

resource "aws_iam_role" "elucid_iam_role_ecs_task_execution" {
  name = "${var.resource_prefix}-iam-role-ecs-task-execution"

  assume_role_policy = jsonencode(
    {
      Version = "2012-10-17",
      Statement = [
        {
          Action = "sts:AssumeRole",
          Principal = {
            Service = "ecs-tasks.amazonaws.com"
          },
          Effect = "Allow",
          Sid    = ""
        }
      ]
    }
  )
}

resource "aws_iam_role_policy_attachment" "elucid-ecs-task-execution-role-policy-attachment" {
  role       = aws_iam_role.elucid_iam_role_ecs_task_execution.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

## SECUTIRY GROUP
resource "aws_security_group" "elucid_security_group_ecs_backend" {
  name        = "${var.resource_prefix}-security-group-ecs-backend"
  vpc_id      = var.elucid_vpc_id

  ingress {
    from_port       = var.elucid_security_group_ecs_backend.ingress.from_port
    to_port         = var.elucid_security_group_ecs_backend.ingress.to_port
    protocol        = var.elucid_security_group_ecs_backend.ingress.protocol
    security_groups = [var.elucid_security_group_id]
  }

  egress {
    from_port   = var.elucid_security_group_ecs_backend.egress.from_port
    to_port     = var.elucid_security_group_ecs_backend.egress.to_port
    protocol    = var.elucid_security_group_ecs_backend.egress.protocol
    cidr_blocks = var.elucid_security_group_ecs_backend.egress.cidr_blocks
  }
}

## ECS
resource "aws_ecs_cluster" "elucid_ecs_cluster" {
  name      = "${var.resource_prefix}-ecs-cluster"

  tags = {
    Name    = "${var.resource_prefix}-ecs-cluster"
  }
}

resource "aws_ecs_task_definition" "elucid_ecs_backend_web" {
  network_mode             = var.elucid_ecs_backend_web.network_mode
  requires_compatibilities = var.elucid_ecs_backend_web.requires_compatibilities
  cpu                      = var.elucid_ecs_backend_web.cpu
  memory                   = var.elucid_ecs_backend_web.memory

  family = var.elucid_ecs_backend_web.family
  container_definitions = templatefile(
    "${var.tf_root_path}/templates/backend_container.json.tpl",
    {
      region     = var.elucid_ecs_backend_web.container_definitions.region
      name       = var.elucid_ecs_backend_web.container_definitions.name
      image      = aws_ecr_repository.elucid_backend_repository.repository_url
      command    = var.elucid_ecs_backend_web.container_definitions.command
      log_group  = aws_cloudwatch_log_group.elucid_backend_log_group.name
      log_stream = aws_cloudwatch_log_stream.elucid_backend_web_log_stream.name
    },
  )
  execution_role_arn = aws_iam_role.elucid_iam_role_ecs_task_execution.arn
  task_role_arn      = aws_iam_role.elucid_iam_role_backend_task.arn
}

resource "aws_ecs_service" "elucid_ecs_service_backend_web" {
  name                               = "${var.resource_prefix}-backend-web"
  cluster                            = aws_ecs_cluster.elucid_ecs_cluster.id
  task_definition                    = aws_ecs_task_definition.elucid_ecs_backend_web.arn
  desired_count                      = var.elucid_ecs_service_backend_web.desired_count
  deployment_minimum_healthy_percent = var.elucid_ecs_service_backend_web.deployment_minimum_healthy_percent
  deployment_maximum_percent         = var.elucid_ecs_service_backend_web.deployment_maximum_percent
  launch_type                        = var.elucid_ecs_service_backend_web.launch_type
  scheduling_strategy                = var.elucid_ecs_service_backend_web.scheduling_strategy

  load_balancer {
    target_group_arn = var.elucid_lb_target_group_arn
    container_name   = var.elucid_ecs_service_backend_web.load_balancer.container_name
    container_port   = var.elucid_ecs_service_backend_web.load_balancer.container_port
  }

  network_configuration {
    security_groups  = [aws_security_group.elucid_security_group_ecs_backend.id]
    subnets          = [var.elucid_private_subnet_1_id, var.elucid_private_subnet_2_id]
    assign_public_ip = var.elucid_ecs_service_backend_web.network_configuration.assign_public_ip
  }
}
