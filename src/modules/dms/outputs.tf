output "dms_task_arn" {
  value       = aws_dms_replication_task.cdc.replication_task_arn
  description = "ARN of the DMS replication task"
}