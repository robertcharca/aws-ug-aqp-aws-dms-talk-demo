variable "vpc_id" {
  type = string
}

variable "dms_sg_id" {
  type        = string
  description = "Security group ID for the DMS replication instance"
}

variable "subnet_ids" {
  type = list(string)
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

variable "rds_address" {
  type = string
}

variable "dms_s3_role_arn" {
  type = string
}

variable "s3_bucket_id" {
  type = string
}

variable "table_name" {
  type = string
}