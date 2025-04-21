output "vpc_id" {
  description = "The VPC for the test app"
  value       = aws_vpc.main.id
}

output "public_subnet_ids" {
  description = "public subnet ids"
  value       = aws_subnet.public[*].id
}
output "private_subnet_ids" {
  description = "the private subnets"
  value       = aws_subnet.private[*].id

}

output "nat_gateway_id" {
  description = "The NAT Gateway ID"
  value       = aws_nat_gateway.gw.id
}