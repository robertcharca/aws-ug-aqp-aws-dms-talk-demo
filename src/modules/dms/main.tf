resource "aws_dms_replication_subnet_group" "default" {
  replication_subnet_group_id          = "dms-demo-subnet-group"
  replication_subnet_group_description = "Demo subnet group"
  subnet_ids                           = var.subnet_ids
}

resource "aws_dms_replication_instance" "this" {
  replication_instance_id     = "dms-demo-instance"
  replication_instance_class  = "dms.t3.medium"
  allocated_storage           = 20
  multi_az                    = false
  publicly_accessible         = true
  vpc_security_group_ids      = [var.dms_sg_id]
  replication_subnet_group_id = aws_dms_replication_subnet_group.default.id
}

resource "aws_dms_endpoint" "source" {
  endpoint_id   = "rds-mysql-source"
  endpoint_type = "source"
  engine_name   = "mysql"
  username      = var.rds_username
  password      = var.rds_password
  server_name   = var.rds_address
  port          = 3306
  database_name = var.rds_db_name
  ssl_mode      = "none"
}

resource "aws_dms_s3_endpoint" "target" {
  endpoint_id   = "s3-cdc-target"
  endpoint_type = "target"

  service_access_role_arn = var.dms_s3_role_arn
  bucket_name             = var.s3_bucket_id
  bucket_folder           = "cdc-lake"

  data_format                      = "parquet"
  include_op_for_full_load         = true
  timestamp_column_name            = "__dms_ts"
  date_partition_enabled           = true
  parquet_timestamp_in_millisecond = true
  compression_type                 = "GZIP"

  cdc_min_file_size      = 64000
  cdc_max_batch_interval = 3600
  preserve_transactions  = false
  add_column_name        = true
}

resource "aws_dms_replication_task" "cdc" {
  replication_task_id      = "rds-to-s3-cdc-demo"
  replication_instance_arn = aws_dms_replication_instance.this.replication_instance_arn
  source_endpoint_arn      = aws_dms_endpoint.source.endpoint_arn
  target_endpoint_arn      = aws_dms_s3_endpoint.target.endpoint_arn
  migration_type           = "full-load-and-cdc"
  start_replication_task   = false

  table_mappings = jsonencode({
    rules = [{
      "rule-type"      = "selection"
      "rule-id"        = "1"
      "rule-name"      = "select-table"
      "object-locator" = { "schema-name" = var.rds_db_name, "table-name" = var.table_name }
      "rule-action"    = "include"
    }]
  })
}