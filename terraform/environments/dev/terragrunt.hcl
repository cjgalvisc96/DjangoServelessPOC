include {
    path = find_in_parent_folders()
}

terraform {
    source = "../..//src"
}


inputs = {
    # Module: Network
    aws_vpc = {
        cidr_block           = "10.0.0.0/16"
        enable_dns_support   = true
        enable_dns_hostnames = true
    }

    aws_subnet = {
        public_cidr_blocks   = ["10.0.1.0/24", "10.0.2.0/24"]
        private_cidr_blocks  = ["10.0.3.0/24", "10.0.4.0/24"]
        availability_zones   = ["us-east-1a", "us-east-1b"]
    }

    aws_route = {
        destination_cidr_block = "0.0.0.0/0"
    }

    aws_eip = {
        vpc                       = true
        associate_with_private_ip = "10.0.0.5"
    }

    aws_security_group = {
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

    aws_lb_target_group = {
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

    aws_lb = {
        load_balancer_type = "application"
        internal           = false
    }

    aws_lb_listener = {
        port     = "80"
        protocol = "HTTP"
        default_action = {
            type             = "forward"
        }
    }

    # Module: Compute
    aws_ecr_repository = {
        image_tag_mutability = "MUTABLE"
    }
}