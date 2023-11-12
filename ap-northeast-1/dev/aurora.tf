resource "aws_rds_cluster" "aurora_cluster" {
  cluster_identifier      = "${var.project_name}-${var.env}-aurora-cluster"
  engine                  = "aurora-mysql"
  database_name           = var.project_name
  master_username         = "tcdx"
  master_password         = "tcdx2023"
  backup_retention_period = 5
  preferred_backup_window = "07:00-09:00"
  skip_final_snapshot     = true
  vpc_security_group_ids = [
    aws_security_group.aurora_sg.id
  ]
  db_subnet_group_name = aws_db_subnet_group.aurora_subnet_group.name

  serverlessv2_scaling_configuration {
    min_capacity = 0.5
    max_capacity = 1
  }

  tags = {
    Name      = "${var.project_name}-${var.env}-aurora-cluster",
    Env       = var.env,
    ManagedBy = "Terraform"
  }
}

resource "aws_rds_cluster_instance" "aurora_cluster_instance" {
  identifier         = "${var.project_name}-${var.env}-aurora-cluster-instance"
  cluster_identifier = aws_rds_cluster.aurora_cluster.cluster_identifier
  instance_class     = "db.serverless"
  engine             = "aurora-mysql"

  tags = {
    Name      = "${var.project_name}-${var.env}-aurora-cluster-instance",
    Env       = var.env,
    ManagedBy = "Terraform"
  }
}

resource "aws_db_subnet_group" "aurora_subnet_group" {
  name = "${var.project_name}-${var.env}-aurora-subnet-group"
  subnet_ids = [
    aws_subnet.aurora_private_a.id,
    aws_subnet.aurora_private_c.id
  ]

  tags = {
    Name      = "${var.project_name}-${var.env}-aurora-subnet-group",
    Env       = var.env,
    ManagedBy = "Terraform"
  }
}
