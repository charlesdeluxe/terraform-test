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



# TODO use interpolation for the s3 bucket name in Resource
resource "aws_iam_role_policy" "nginx" {
  name = "nginx_iam_role_policy"
  role = "${ aws_iam_role.nginx.id }"
  policy = <<EOF
{
   "Version": "2012-10-17",
   "Statement": [
     {
       "Effect": "Allow",
       "Action": [
         "s3:GetBucketLocation",
         "s3:ListAllMyBuckets"
       ],
       "Resource": "*"
     },
     {
       "Effect": "Allow",
       "Action": ["s3:ListBucket"],
       "Resource": ["*"]
     },
     {
       "Effect": "Allow",
       "Action": [
         "s3:PutObject",
         "s3:GetObject"
       ],
       "Resource": ["*"]
     }
   ]
 }
EOF
}



# {
#    "Version": "2012-10-17",
#    "Statement": [
#      {
#        "Effect": "Allow",
#        "Action": [
#          "s3:GetBucketLocation",
#          "s3:ListAllMyBuckets"
#        ],
#        "Resource": "*"
#      },
#      {
#        "Effect": "Allow",
#        "Action": ["s3:ListBucket"],
#        "Resource": ["arn:aws:s3:::<BUCKET-NAME>"]
#      },
#      {
#        "Effect": "Allow",
#        "Action": [
#          "s3:PutObject",
#          "s3:GetObject"
#        ],
#        "Resource": ["arn:aws:s3:::<BUCKET-NAME>/*"]
#      }
#    ]
#  }



