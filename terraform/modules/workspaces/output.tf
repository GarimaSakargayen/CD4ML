locals {
  env = terraform.workspace
  aws_az_count = {
    "default" = 2
    "train"   = 2
    "prod"    = 2
  }
  public_subnet_range = {
    "default" = 1
    "train"   = 1
    "prod"    = 2
  }

  private_subnet_range = {
    "default" = 2
    "train"   = 2
    "prod"    = 4
  }

  cluster_name = {
    "default" = "cd4ml_train"
    "train"   = "cd4ml_train"
    "prod"    = "cd4ml_prod"
  }
  worker_desired_capacity = {
    "default" = 4
    "train"   = 4
    "prod"    = 5
  }

  worker_min_size = {
    "default" = 3
    "train"   = 3
    "prod"    = 3
  }

  worker_max_size = {
    "default" = 6
    "train"   = 6
    "prod"    = 8
  }

  aws_ebs_size = {
    "default" = 15
    "train"   = 15
    "prod"    = 15
  }

  eks_worker_instance_type = {
    "default" = "t2.large"
    "train"   = "t2.large"
    "prod"    = "t2.large"
  }
}

output "env" {
  value = local.env
}

output "aws_availability_zone_count" {
  value = local.aws_az_count[local.env]
}

output "aws_public_subnet_range" {
  value = local.public_subnet_range[local.env]
}

output "aws_private_subnet_range" {
  value = local.private_subnet_range[local.env]
}

output "aws_cluster_name" {
  value = local.cluster_name[local.env]
}

output "eks_worker_desired_capacity" {
  value = local.worker_desired_capacity[local.env]
}

output "eks_worker_min_size" {
  value = local.worker_min_size[local.env]
}

output "eks_worker_max_size" {
  value = local.worker_max_size[local.env]
}

output "aws_ebs_size" {
  value = local.aws_ebs_size[local.env]
}

output "eks_worker_instance_type" {
  value = local.eks_worker_instance_type[local.env]
}

