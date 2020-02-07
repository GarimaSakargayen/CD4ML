resource "aws_security_group" "ssh_in_out" {
  vpc_id = var.vpc_id
  name   = "cd4ml-ssh_in_out"
}

resource "aws_security_group" "flask_in_out" {
  vpc_id = var.vpc_id
  name   = "cd4ml-flask_in_out"
}

resource "aws_security_group" "prometheus_in_out" {
  vpc_id = var.vpc_id
  name   = "cd4ml-prometheus_in_out"
}

resource "aws_security_group" "grafana_in_out" {
  vpc_id = var.vpc_id
  name   = "cd4ml-grafana_in_out"
}

resource "aws_security_group" "eks_cluster_in_out" {
  vpc_id      = var.vpc_id
  name        = "cd4ml-eks_cluster"
  description = "Cluster communication with worker nodes"
  tags = {
    Name = "cd4ml-eks-cluster"
  }
}

resource "aws_security_group" "eks_node_in_out" {
  vpc_id      = var.vpc_id
  name        = "cd4ml-eks_node"
  description = "Communication between worker nodes"
  tags = {
    Name                                        = "cd4ml-eks-nodes"
    "kubernetes.io/cluster/${var.cluster_name}" = "owned"
    KubernetesCluster                           = var.cluster_name
  }
}

resource "aws_security_group_rule" "ssh_in" {
  type      = "ingress"
  from_port = 22
  to_port   = 22
  protocol  = "tcp"
  # TF-UPGRADE-TODO: In Terraform v0.10 and earlier, it was sometimes necessary to
  # force an interpolation expression to be interpreted as a list by wrapping it
  # in an extra set of list brackets. That form was supported for compatibility in
  # v0.11, but is no longer supported in Terraform v0.12.
  #
  # If the expression in the following list itself returns a list, remove the
  # brackets to avoid interpretation as a list of lists. If the expression
  # returns a single list item then leave it as-is and remove this TODO comment.
  cidr_blocks       = [local.ipAddress]
  security_group_id = aws_security_group.ssh_in_out.id
}

resource "aws_security_group_rule" "ssh_out" {
  type              = "egress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.ssh_in_out.id
}

resource "aws_security_group_rule" "flask_in" {
  type                     = "ingress"
  from_port                = 5000
  to_port                  = 5000
  protocol                 = "-1"
  security_group_id        = aws_security_group.flask_in_out.id
  source_security_group_id = aws_security_group.flask_in_out.id
}

resource "aws_security_group_rule" "flask_out" {
  type                     = "egress"
  from_port                = 5000
  to_port                  = 5000
  protocol                 = "-1"
  security_group_id        = aws_security_group.flask_in_out.id
  source_security_group_id = aws_security_group.flask_in_out.id
}

resource "aws_security_group_rule" "prometheus_in" {
  type                     = "ingress"
  from_port                = 9090
  to_port                  = 9090
  protocol                 = "-1"
  security_group_id        = aws_security_group.prometheus_in_out.id
  source_security_group_id = aws_security_group.prometheus_in_out.id
}

resource "aws_security_group_rule" "prometheus_out" {
  type                     = "egress"
  from_port                = 9090
  to_port                  = 9090
  protocol                 = "-1"
  security_group_id        = aws_security_group.prometheus_in_out.id
  source_security_group_id = aws_security_group.prometheus_in_out.id
}

resource "aws_security_group_rule" "grafana_in" {
  type                     = "ingress"
  from_port                = 3000
  to_port                  = 3000
  protocol                 = "-1"
  security_group_id        = aws_security_group.grafana_in_out.id
  source_security_group_id = aws_security_group.grafana_in_out.id
}

resource "aws_security_group_rule" "grafana_out" {
  type                     = "egress"
  from_port                = 3000
  to_port                  = 3000
  protocol                 = "-1"
  security_group_id        = aws_security_group.grafana_in_out.id
  source_security_group_id = aws_security_group.grafana_in_out.id
}

resource "aws_security_group_rule" "eks_cluster_in_localip" {
  type      = "ingress"
  from_port = 443
  to_port   = 443
  protocol  = "tcp"
  # TF-UPGRADE-TODO: In Terraform v0.10 and earlier, it was sometimes necessary to
  # force an interpolation expression to be interpreted as a list by wrapping it
  # in an extra set of list brackets. That form was supported for compatibility in
  # v0.11, but is no longer supported in Terraform v0.12.
  #
  # If the expression in the following list itself returns a list, remove the
  # brackets to avoid interpretation as a list of lists. If the expression
  # returns a single list item then leave it as-is and remove this TODO comment.
  cidr_blocks       = [local.ipAddress]
  security_group_id = aws_security_group.eks_cluster_in_out.id
}

resource "aws_security_group_rule" "eks_cluster_in_nodes" {
  type                     = "ingress"
  from_port                = 443
  to_port                  = 443
  protocol                 = "tcp"
  security_group_id        = aws_security_group.eks_cluster_in_out.id
  source_security_group_id = aws_security_group.eks_node_in_out.id
}

resource "aws_security_group_rule" "eks_cluster_out" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.eks_cluster_in_out.id
}

resource "aws_security_group_rule" "eks_node_in_self" {
  type                     = "ingress"
  from_port                = 0
  to_port                  = 65535
  protocol                 = "-1"
  security_group_id        = aws_security_group.eks_node_in_out.id
  source_security_group_id = aws_security_group.eks_node_in_out.id
}

resource "aws_security_group_rule" "eks_node_in_cluster" {
  type                     = "ingress"
  from_port                = 1025
  to_port                  = 65535
  protocol                 = "tcp"
  security_group_id        = aws_security_group.eks_node_in_out.id
  source_security_group_id = aws_security_group.eks_cluster_in_out.id
}

resource "aws_security_group_rule" "eks_node_in_https" {
  type                     = "ingress"
  from_port                = 443
  to_port                  = 443
  protocol                 = "tcp"
  security_group_id        = aws_security_group.eks_node_in_out.id
  source_security_group_id = aws_security_group.eks_cluster_in_out.id
}

resource "aws_security_group_rule" "eks_node_out" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.eks_node_in_out.id
}

