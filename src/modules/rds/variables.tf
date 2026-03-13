variable "vpc_id" {
  type        = string
  description = "VPC ID where RDS and security groups live"
}

variable "subnet_ids" {
  type        = list(string)
  description = "List of subnet IDs for the DB subnet group"
}

variable "dms_sg_id" {
  type        = string
  description = "Security group ID of the DMS replication instance"
}

variable "rds_username" {
  type = string
}

variable "rds_password" {
  type      = string
  sensitive = true
}

variable "rds_db_name" {
  type = string
}