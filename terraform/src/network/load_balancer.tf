## SECURITY GROUP (Allow traffic from 80 and 443 ports only)
resource "aws_security_group" "elucid_secutiry_group" {
  name        = "${var.env}_${var.project_name}_security_group"
  description = "Controls access to the ALB"
  vpc_id      = aws_vpc.elucid_vpc.id

  ingress {
    from_port   = var.aws_security_group.ingress_1.from_port
    to_port     = var.aws_security_group.ingress_1.to_port
    protocol    = var.aws_security_group.ingress_1.protocol
    cidr_blocks = var.aws_security_group.ingress_1.cidr_blocks 
  }

  ingress {
    from_port   = var.aws_security_group.ingress_2.from_port
    to_port     = var.aws_security_group.ingress_2.to_port
    protocol    = var.aws_security_group.ingress_2.protocol 
    cidr_blocks = var.aws_security_group.ingress_2.cidr_blocks 
  }

  egress {
    from_port   = var.aws_security_group.egress_1.from_port
    to_port     = var.aws_security_group.egress_1.to_port
    protocol    = var.aws_security_group.egress_1.protocol 
    cidr_blocks = var.aws_security_group.egress_1.cidr_blocks 
  }

  tags = {
    Name    = "${var.env}_${var.project_name}_security_group"
  }
}


## LOAD BALANCER TARGET GROUP
resource "aws_lb_target_group" "elucid_lb_target_group" {
  name        = "${var.env}-${var.project_name}-lb-target-group"
  port        = var.aws_lb_target_group.port
  protocol    = var.aws_lb_target_group.protocol
  vpc_id      = aws_vpc.elucid_vpc.id
  target_type = var.aws_lb_target_group.target_type

  health_check {
    path                = var.aws_lb_target_group.health_check.path
    port                = var.aws_lb_target_group.health_check.port
    healthy_threshold   = var.aws_lb_target_group.health_check.healthy_threshold
    unhealthy_threshold = var.aws_lb_target_group.health_check.unhealthy_threshold
    timeout             = var.aws_lb_target_group.health_check.timeout
    interval            = var.aws_lb_target_group.health_check.interval
    matcher             = var.aws_lb_target_group.health_check.matcher
  }

  tags = {
    Name    = "${var.env}-${var.project_name}-lb-target-group"
  }
}

## LOAD BALANCER
resource "aws_lb" "elucid_load_balancer" {
  name               = "${var.env}-${var.project_name}-lb"
  load_balancer_type = var.aws_lb.load_balancer_type
  internal           = var.aws_lb.internal
  security_groups    = [aws_security_group.elucid_secutiry_group.id]
  subnets            = [aws_subnet.elucid_public_subnet_1.id, aws_subnet.elucid_public_subnet_2.id]
  # client_keep_alive  = 3600

  tags = {
    Name    = "${var.env}-${var.project_name}-lb"
  }
}

## LOAD BALANCER LISTENER(Target listener for http:80)
resource "aws_lb_listener" "elucid_aws_lb_listener" {
  load_balancer_arn = aws_lb.elucid_load_balancer.id
  port              = var.aws_lb_listener.port
  protocol          = var.aws_lb_listener.protocol
  depends_on        = [aws_lb_target_group.elucid_lb_target_group]

  default_action {
    type             = var.aws_lb_listener.default_action.type
    target_group_arn = aws_lb_target_group.elucid_lb_target_group.arn
  }

  tags = {
    Name    = "${var.env}_${var.project_name}_load_balancer_listener"
  }
}
