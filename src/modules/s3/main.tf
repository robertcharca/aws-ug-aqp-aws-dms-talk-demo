resource "aws_s3_bucket" "lake" {
  bucket        = "dms-cdc-demo-${var.account_id}"
  force_destroy = true
}

resource "aws_s3_bucket" "athena_results" {
  bucket        = "dms-athena-results-${var.account_id}"
  force_destroy = true
}