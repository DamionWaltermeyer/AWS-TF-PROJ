output "vpc_id" { # compute and alb will need this
  value = module.network.vpc_id
}

output "public_subnet_ids" { #for ALB
  value = module.network.public_subnet_ids
}

output "private_subnet_ids" { #for compute
  value = module.network.private_subnet_ids
}

output "nat_gateway_id" { #incase I need it for cloudwatch
  value = module.network.nat_gateway_id
}

output "alb_dns_name" {
  description = "Public DNS of the ALB"
  value       = module.load_balancer.alb_dns_name
}

output "alb_sg_id" {
  value = module.load_balancer.alb_sg_id
}
