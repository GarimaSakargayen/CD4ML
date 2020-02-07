variable "EKS_Cluster_Security_Group" {
  type = list(string)
}

variable "eks_cluser_role_arn" {
}

variable "eks_nodes_role_arn" {
}

variable "Public_Subnet_id_list" {
  type = list
}

variable "cluster_name" {
}

variable "cd4ml_env" {
}

