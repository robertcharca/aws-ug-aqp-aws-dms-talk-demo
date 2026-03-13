output "dms_s3_role_arn" {
  value = aws_iam_role.dms_s3.arn
}

output "glue_role_arn" {
  value = aws_iam_role.glue.arn
}