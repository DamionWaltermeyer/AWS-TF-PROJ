resource "aws_security_group" "db_sg" {
  name        = "rds-db-sg"
  description = "allow from compute"
  vpc_id      = var.vpc_id



  ingress {
    description     = "Postgres from compute"
    from_port       = "5432"
    to_port         = "5432"
    protocol        = "tcp"
    security_groups = [var.app_sg_id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = local.common_tags
}


resource "aws_db_instance" "main" {
  identifier             = "secure-app-db"
  engine                 = "postgres"
  engine_version         = "14"
  instance_class         = "db.t3.micro"
  allocated_storage      = 20
  db_name                = var.db_name
  username               = var.db_user
  password               = var.db_password
  vpc_security_group_ids = [aws_security_group.db_sg.id]
  db_subnet_group_name   = aws_db_subnet_group.main.name
  skip_final_snapshot    = true
  tags                   = local.common_tags

}

resource "aws_db_subnet_group" "main" {
  name       = "rds-subnet-group"
  subnet_ids = var.private_subnet_ids

  tags = local.common_tags
}

