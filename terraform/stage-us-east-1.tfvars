environment = "master"
aws_region  = "us-east-1"
account_id  = "581154480033"

prod_account_id   = "581154480033"
stage_account_id  = "581154480033"
dev_account_id    = "581154480033"
master_account_id = "581154480033"

tags = {
  "Name"        = "tf_task"
  "Environment" = "stage"
}


# --------------------
# VPC
# --------------------
vpc_cidr = "10.2.0.0/16"
az_count = "3"


# --------------------
# RDS
# --------------------
rds_instaces_count = "2"
rds_instance_type  = "db.t2.medium"

# --------------------
# EKS
# --------------------
node_group_instances_type = "c5.large"
desired_capacity          = "6"
min_capacity              = "6"
max_capacity              = "10"
