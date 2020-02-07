resource "aws_s3_bucket" "cd4ml-s3" {
  bucket = "cd4ml-${lower(var.cd4ml_env)}"
  acl    = "public-read-write"
  tags = {
    name        = "cd4ml bucket"
    environment = "training"
  }
  policy = <<POLICY
{
 "Version": "2012-10-17",
 "Statement": [
                {
                    "Sid": "PublicReadGetObject",
                    "Effect": "Allow",
                    "Principal": "*",
                    "Action": "s3:GetObject",
                    "Resource": "arn:aws:s3:::cd4ml-${lower(var.cd4ml_env)}/*"
                }
              ]
}
POLICY

}

resource "aws_s3_bucket" "cd4ml-s3-prod" {
  bucket = "cd4ml-prod"
  acl    = "public-read-write"
  tags = {
    name        = "cd4ml bucket"
    environment = "training"
  }
  policy = <<POLICY
{
 "Version": "2012-10-17",
 "Statement": [
                {
                    "Sid": "PublicReadGetObject",
                    "Effect": "Allow",
                    "Principal": "*",
                    "Action": "s3:GetObject",
                    "Resource": "arn:aws:s3:::cd4ml-prod/*"
                }
              ]
}
POLICY

}

resource "aws_s3_bucket" "cd4ml-s3-backup" {
  bucket = "cd4ml-backup"
  acl    = "public-read-write"
  tags = {
    name        = "cd4ml bucket"
    environment = "training"
  }
  policy = <<POLICY
{
 "Version": "2012-10-17",
 "Statement": [
                {
                    "Sid": "PublicReadGetObject",
                    "Effect": "Allow",
                    "Principal": "*",
                    "Action": "s3:GetObject",
                    "Resource": "arn:aws:s3:::cd4ml-backup/*"
                }
              ]
}
POLICY

}

