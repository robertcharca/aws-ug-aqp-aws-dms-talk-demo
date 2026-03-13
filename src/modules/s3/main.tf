resource "aws_s3_bucket" "lake" {
  bucket        = "dms-cdc-demo-${data.aws_caller_identity.current.account_id}"
  force_destroy = true
}