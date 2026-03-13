resource "aws_db_subnet_group" "default" {
  name       = "dms-demo-db-subnet"
  subnet_ids = var.subnet_ids
}

resource "aws_db_parameter_group" "cdc" {
  name   = "mysql-cdc-demo"
  family = "mysql8.0"
  parameter {
    name  = "binlog_format"
    value = "ROW"
  }
  parameter {
    name  = "binlog_row_image"
    value = "full"
  }
}

resource "aws_security_group" "rds" {
  vpc_id = var.vpc_id

  ingress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [var.dms_sg_id]
  }

  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_db_instance" "source" {
  identifier              = "dms-rds-demo"
  instance_class          = "db.t3.micro"
  allocated_storage       = 20
  engine                  = "mysql"
  engine_version          = "8.0"
  availability_zone       = "us-east-1a"
  username                = var.rds_username
  password                = var.rds_password
  db_name                 = var.rds_db_name
  parameter_group_name    = aws_db_parameter_group.cdc.name
  db_subnet_group_name    = aws_db_subnet_group.default.name
  vpc_security_group_ids  = [aws_security_group.rds.id]
  publicly_accessible     = true
  backup_retention_period = 1
  skip_final_snapshot     = true
}