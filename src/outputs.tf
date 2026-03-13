output "s3_bucket" {
  value = module.s3.bucket_id
}

output "rds_endpoint" {
  value = module.rds.rds_endpoint
}

output "glue_database" {
  value = module.athena_glue.glue_database_name
}

output "dms_task_arn" {
  value = module.dms.dms_task_arn
}

output "athena_results_bucket" {
  value = module.s3.athena_results_bucket
}