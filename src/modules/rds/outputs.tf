output "rds_endpoint" {
  value = aws_db_instance.source.endpoint
}

output "rds_address" {
  value = aws_db_instance.source.address
}