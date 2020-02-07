output "sg-ssh_id" { #makes security groups build before webservers
  value = aws_security_group.ssh_in_out.id
}

output "flask_in_out" { #makes security groups build before webservers
  value = aws_security_group.flask_in_out.id
}

output "eks_cluster_in_out" { #makes security groups build before webservers
  value = aws_security_group.eks_cluster_in_out.id
}

output "public_security_groups" {
  value = [aws_security_group.ssh_in_out.id, aws_security_group.flask_in_out.id, aws_security_group.eks_cluster_in_out.id]
  depends_on = [
    aws_security_group.ssh_in_out,
    aws_security_group.flask_in_out,
    aws_security_group.eks_cluster_in_out,
  ]
}

output "eks_cluser_security_groups" {
  value      = [aws_security_group.eks_cluster_in_out.id]
  depends_on = [aws_security_group.eks_cluster_in_out]
}

output "eks_node_security_groups" {
  value = [aws_security_group.eks_node_in_out.id, aws_security_group.ssh_in_out.id]
  depends_on = [
    aws_security_group.eks_node_in_out,
    aws_security_group.ssh_in_out,
  ]
}

