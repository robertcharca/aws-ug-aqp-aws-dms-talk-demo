variable "region" {
  default = "us-east-1"
}

variable "rds_username" {
  default = "admin"
}

variable "rds_password" {
  sensitive = true
}

variable "rds_db_name" {
  default = "demodb"
}

variable "table_name" {
  default = "customers_transactions"
}