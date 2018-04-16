resource "aws_iam_role" "nginx" {
  name = "nginx_iam_role"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}


resource "aws_iam_instance_profile" "nginx" {
  name = "nginx_iam_instance_profile"
  role = "${ aws_iam_role.nginx.name }"
}


resource "aws_iam_role_policy" "nginx" {
  name = "nginx_iam_role_policy"
  role = "${ aws_iam_role.nginx.id }"
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": ["s3:*"],
      "Resource": ["*"]
    }
  ]
}
EOF
}


