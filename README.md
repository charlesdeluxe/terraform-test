# Terraform Test

All pull requests must demonstrate a working terraform script which provisions 3 identical Nginx servers on AWS, each having private read access to the same S3 bucket.  
* The S3 bucket MUST NOT be public.
* The servers should be provisioned onto a new VPC.