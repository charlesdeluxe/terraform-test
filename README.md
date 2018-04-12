# Terraform Test

All pull requests must demonstrate a working set of terraform configs which provisions 3 Nginx servers on AWS, each instance having private read access to the same S3 bucket.

The terraform configs should create the following:
* A new VPC within the account.
* A private S3 bucket.
* An autoscaling group of nginx servers 3 wide within the newly created VPC with access to the created s3 bucket.

All resources should be created in us-west-2 when applicable.