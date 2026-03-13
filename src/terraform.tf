terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  profile = "default"
  region  = var.region
}

data "aws_caller_identity" "current" {}
data "aws_vpc" "default" {}
data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

module "s3" {
  source = "./modules/s3"
}

module "iam" {
  source        = "./modules/iam"
  s3_bucket_arn = module.s3.bucket_arn
}

module "rds" {
  source       = "./modules/rds"
  vpc_id       = data.aws_vpc.default.id
  subnet_ids   = data.aws_subnets.default.ids
  dms_sg_id    = module.dms.dms_sg_id
  rds_username = var.rds_username
  rds_password = var.rds_password
  rds_db_name  = var.rds_db_name
}

module "dms" {
  source          = "./modules/dms"
  vpc_id          = data.aws_vpc.default.id
  subnet_ids      = data.aws_subnets.default.ids
  rds_username    = var.rds_username
  rds_password    = var.rds_password
  rds_db_name     = var.rds_db_name
  rds_address     = module.rds.rds_address
  dms_s3_role_arn = module.iam.dms_s3_role_arn
  s3_bucket_id    = module.s3.bucket_id
  table_name      = var.table_name
}

module "athena_glue" {
  source        = "./modules/athena_glue"
  glue_role_arn = module.iam.glue_role_arn
  s3_bucket_id  = module.s3.bucket_id
}