output "elucid_vpc_id" {
  value = aws_vpc.elucid_vpc.id
}

output "elucid_security_group_id" {
  value = aws_security_group.elucid_security_group.id
}

output "elucid_private_subnet_1_id" {
  value = aws_subnet.elucid_private_subnet_1.id
}

output "elucid_private_subnet_2_id" {
  value = aws_subnet.elucid_private_subnet_2.id
}

output "elucid_lb_target_group_arn" {
  value = aws_lb_target_group.elucid_lb_target_group.arn
}

output "elucid_lb__dns_name" {
  value = aws_lb.elucid_lb.dns_name
}
