output "bucket_id" {
  value = aws_s3_bucket.lake.id
}

output "bucket_arn" {
  value = aws_s3_bucket.lake.arn
}

output "athena_results_bucket" {
  value = aws_s3_bucket.athena_results.id
}