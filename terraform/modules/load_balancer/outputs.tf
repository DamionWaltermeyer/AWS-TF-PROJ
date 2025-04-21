output "alb_dns_name" {
  description = "Dns name of ALB"
  value       = aws_lb.app.dns_name
}

output "target_group_arn" {
  description = "ARN of the ALB targetgroup"
  value       = aws_lb_target_group.app.arn

}

output "alb_sg_id" {
  description = "security group ID of ALB"
  value       = aws_security_group.alb_sg.id

}
