environment = "master"
aws_region  = "us-east-1"
account_id  = "581154480033"

prod_account_id   = "581154480033"
stage_account_id  = "581154480033"
dev_account_id    = "581154480033"
master_account_id = "581154480033"

tags = {
  "Name"        = "tf_task"
  "Environment" = "Master"
}

# --------------------
# VPC
# --------------------
vpc_cidr = "10.0.0.0/16"
az_count = "3"

# --------------------
# RDS
# --------------------
rds_instaces_count = "2"
rds_instance_type  = "db.t3.medium"

# --------------------
# EKS
# --------------------
node_group_instances_type = "t3.medium"
desired_capacity          = "2"
min_capacity              = "2"
max_capacity              = "5"

