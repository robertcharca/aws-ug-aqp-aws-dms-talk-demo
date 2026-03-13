resource "aws_s3_bucket" "lake" {
  bucket        = "dms-cdc-demo-${var.account_id}"
  force_destroy = true
}