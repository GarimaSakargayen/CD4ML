resource "aws_vpc" "cd4ml-vpc" {
  cidr_block           = var.cidr_block
  enable_dns_hostnames = true
  tags = {
    Name                                        = "cd4ml-eks-node"
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
  }
  lifecycle {
    ignore_changes = [tags]
  }
}

