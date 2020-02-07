resource "aws_internet_gateway" "cd4ml-igw" {
  vpc_id = var.vpc_id
  tags = {
    Name = "cd4ml-igw"
  }
}

