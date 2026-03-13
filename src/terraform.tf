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

locals {
  account_id = data.aws_caller_identity.current.account_id
}

data "aws_vpc" "default" {}
data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

resource "aws_security_group" "dms" {
  vpc_id = data.aws_vpc.default.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "dms-demo-sg"
  }
}

resource "aws_iam_role" "dms_vpc_management" {
  name = "dms-vpc-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action    = "sts:AssumeRole"
        Effect    = "Allow"
        Principal = { Service = "dms.amazonaws.com" }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "dms_vpc_management" {
  role       = aws_iam_role.dms_vpc_management.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonDMSVPCManagementRole"
}

module "s3" {
  source     = "./modules/s3"
  account_id = local.account_id
}

module "iam" {
  source        = "./modules/iam"
  s3_bucket_arn = module.s3.bucket_arn
}

module "rds" {
  source       = "./modules/rds"
  vpc_id       = data.aws_vpc.default.id
  subnet_ids   = data.aws_subnets.default.ids
  dms_sg_id    = aws_security_group.dms.id
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
  dms_sg_id       = aws_security_group.dms.id
}

module "athena_glue" {
  source        = "./modules/athena_glue"
  glue_role_arn = module.iam.glue_role_arn
  s3_bucket_id  = module.s3.bucket_id
}