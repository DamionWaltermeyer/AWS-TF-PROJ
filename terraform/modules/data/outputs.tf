output "db_endpoint" {
  description = "End point for damions-app-test database"
  value       = aws_db_instance.main.address
}

output "db_identifier" {
  value = aws_db_instance.main.id
}

