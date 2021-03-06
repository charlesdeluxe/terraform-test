
variable "ssh_key_name" {
  description = "ssh key name associated with your instances for login"
  default = "deluxe-testing"
  # default = "default"
}

# required
variable "ssh_private_key_filename" {
 default = "/dev/null"
 description = "Path to file containing your ssh private key"
}

variable "aws_profile" {
  description = "AWS profile to use"
  default     = "deluxe"
  # default = "personal"
}

variable "aws_region" {
  description = "AWS region to launch servers."
  default     = "us-west-2"
}

# bucket is presently hard-coded in setup.sh and iam.tf -- cmims 2018-04-12
variable "bucket_name" {
  description = "Name of S3 bucket"
  default     = "hipc3u7pmjdg3ojq3"
}

variable "aws_nginx_instance_disk_size" {
  description = "default size of the root disk (GB)"
  default = "10"
}

variable "aws_nginx_instance_type" {
  description = "AWS instance type"
  default = "t2.micro"
}

variable "num_of_nginx" {
  description = "num of instances"
  default = 3
}