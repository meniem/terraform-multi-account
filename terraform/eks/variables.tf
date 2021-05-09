
variable "aws_region" {
  description = "AWS region."
}

variable "environment" {
  description = "Environment."
}

variable "tags" {
  description = "tags to propogate to all supported resources"
}

variable "cluster_log_retention" {
  type        = string
  description = "Log retention period"
  default     = 30
}

variable "kubernetes_version" {
  type        = string
  description = "kubernetes Version"
  default     = "1.19"
}

variable "node_group_instances_type" {
  type        = string
  description = "the KB node group instance size"
}

variable "desired_capacity" {
  type        = string
  description = "the Platform desired capacity"
}

variable "max_capacity" {
  type        = string
  description = "the Platform max capacity"
}

variable "min_capacity" {
  type        = string
  description = "the Platform min capacity"
}

