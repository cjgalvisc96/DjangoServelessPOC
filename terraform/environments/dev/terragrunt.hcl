include {
    path = find_in_parent_folders()
}

terraform {
    source = "../..//src"
}


inputs = {
    # Module: Network
    elucid_vpc = {
        cidr_block           = "10.0.0.0/16"
        enable_dns_support   = true
        enable_dns_hostnames = true
    }

    elucid_public_subnet_1 = {
        cidr_block         = "10.0.1.0/24"
        availability_zones = "us-east-1a"
    }

    elucid_public_subnet_2 = {
        cidr_block         = "10.0.2.0/24"
        availability_zones = "us-east-1b"
    }

    elucid_private_subnet_1 = {
        cidr_block         = "10.0.3.0/24"
        availability_zones = "us-east-1a"
    }

    elucid_private_subnet_2 = {
        cidr_block         = "10.0.4.0/24"
        availability_zones = "us-east-1b"
    }

    elucid_internet_gateway_route = {
        destination_cidr_block = "0.0.0.0/0"
    }

    elucid_nat_gateway_route = {
        destination_cidr_block = "0.0.0.0/0"
    }

    elucid_eip = {
        vpc                       = true
        associate_with_private_ip = "10.0.0.5"
    }

    elucid_security_group = {
        ingress_1 = {
            from_port   = 80
            to_port     = 80
            protocol    = "tcp"
            cidr_blocks = ["0.0.0.0/0"]
        }

        ingress_2 = {
            from_port   = 443
            to_port     = 443
            protocol    = "tcp"
            cidr_blocks = ["0.0.0.0/0"]
        }

        egress_1 = {
            from_port   = 0
            to_port     = 0
            protocol    = "-1"
            cidr_blocks = ["0.0.0.0/0"]
        }
    }

    elucid_lb_target_group = {
        port        = 80
        protocol    = "HTTP"
        target_type = "ip"  
        health_check = {
            path                = "/"
            port                = "traffic-port"
            healthy_threshold   = 5
            unhealthy_threshold = 2
            timeout             = 2
            interval            = 5
            matcher             = "200"
        }
    }

    elucid_lb = {
        load_balancer_type = "application"
        internal           = false
    }

    elucid_lb_listener = {
        port     = "80"
        protocol = "HTTP"
        default_action = {
            type             = "forward"
        }
    }

    # Module: Compute
    elucid_backend_repository = {
        image_tag_mutability = "MUTABLE"
    }

    elucid_backend_log_group = {
        retention_in_days = 30
    }

    elucid_ecs_backend_web = {
        network_mode = "awsvpc" 
        requires_compatibilities = ["FARGATE"]
        cpu = 256
        memory = 512
        family = "backend-web"
        container_definitions = {
            region     = "us-east-1"
            name       = "dev-backend-web"
            command    = ["gunicorn", "-w", "3", "-b", ":8000", "django_serverless_poc.wsgi:application"]
        }
    }

    elucid_security_group_ecs_backend = {
        ingress = {
            from_port       = 0
            to_port         = 0
            protocol        = "-1"
        }

        egress = {
            from_port   = 0
            to_port     = 0
            protocol    = "-1"
            cidr_blocks = ["0.0.0.0/0"]
        }
    }

    elucid_ecs_service_backend_web = {
        desired_count                      = 1
        deployment_minimum_healthy_percent = 50
        deployment_maximum_percent         = 200
        launch_type                        = "FARGATE"
        scheduling_strategy                = "REPLICA"

        load_balancer = {
            container_name = "dev-backend-web"
            container_port = 8000
        }

        network_configuration = {
            assign_public_ip = false
        }
    }
}