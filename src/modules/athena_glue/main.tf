resource "aws_glue_catalog_database" "demo" {
  name = "dms_cdc_demo"
}

resource "aws_glue_crawler" "demo" {
  name          = "dms-cdc-crawler"
  database_name = aws_glue_catalog_database.demo.name
  role          = var.glue_role_arn

  s3_target {
    path = "s3://${var.s3_bucket_id}/cdc-lake/"
  }
}