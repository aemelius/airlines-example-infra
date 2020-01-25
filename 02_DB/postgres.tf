provider "aws" {
  region = "eu-west-2"
}

##############################################################
# Data sources to get VPC, subnets and security group details
##############################################################
data "aws_vpc" "default" {
  default = true
}

data "aws_subnet_ids" "all" {
  vpc_id = data.aws_vpc.default.id
}

data "aws_security_group" "default" {
  vpc_id = data.aws_vpc.default.id
  name   = "default"
}

variable "db_password" {
  type = "string"
}

#####
# DB
#####
module "db" {
  source = "terraform-aws-modules/rds/aws"

  identifier = "simple-flask-1"

  engine            = "postgres"
  engine_version    = "9.6.9"
  instance_class    = "db.t2.large"
  allocated_storage = 5
  storage_encrypted = false

  # kms_key_id        = "arm:aws:kms:<region>:<account id>:key/<kms key id>"
  name = "simpleflask1"

  # NOTE: Do NOT use 'user' as the value for 'username' as it throws:
  # "Error creating DB Instance: InvalidParameterValue: MasterUsername
  # user cannot be used as it is a reserved word used by the engine"
  username = "demouser"

  password = "${var.db_password}"
  port     = "5432"

  vpc_security_group_ids = [data.aws_security_group.default.id, module.postgresql_security_group.this_security_group_id]

  maintenance_window = "Mon:00:00-Mon:03:00"
  backup_window      = "03:00-06:00"

  # disable backups to create DB faster
  backup_retention_period = 0
  publicly_accessible = "true"
  tags = {
    Owner       = "user"
    Environment = "dev"
  }

  enabled_cloudwatch_logs_exports = ["postgresql", "upgrade"]

  # DB subnet group
  subnet_ids = data.aws_subnet_ids.all.ids

  # DB parameter group
  family = "postgres9.6"

  # DB option group
  major_engine_version = "9.6"

  # Snapshot name upon DB deletion
  final_snapshot_identifier = "demodb"

  # Database Deletion Protection
  deletion_protection = false
}


module "postgresql_security_group" {
  source  = "terraform-aws-modules/security-group/aws//modules/postgresql"
  version = "~> 3.0"
  name = "simpleflask1_sg"
  vpc_id = data.aws_vpc.default.id
  #ingress_cidr_blocks = ["82.54.68.90/32", "35.178.168.161/32", "35.178.190.74/32", "35.176.156.13/32"]
  #ingress_cidr_blocks = ["31.14.251.238/32", "192.168.0.0/19", "192.168.64.0/19", "192.168.32.0/19"]
  ingress_cidr_blocks = ["31.14.251.238/32"]
  ingress_with_source_security_group_id= [{from_port=5432, to_port=5432, protocol    = "tcp",
    description="PostgreSQL from kube nodes",
    source_security_group_id = "sg-0e66218d97da58c37"}]
}
