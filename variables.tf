
variable "ssh_key_name" {
  description = "ssh key name associated with your instances for login"
  default = "default"
}

variable "owner" {
  description = "owner of deployed component"
  default = ""
}

variable "ssh_private_key_filename" {
 default = "/dev/null"
 description = "Path to file containing your ssh private key"
}

variable "aws_ami" {
  description = "ami to use"
  default = "ami-43a15f3e"
}

variable "aws_profile" {
  description = "AWS profile to use"
  default     = "default"
}

variable "aws_region" {
  description = "AWS region to launch servers."
  default     = "us-east-1"
}

variable "bucket_name" {
  description = "Name of S3 bucket"
  default     = "hipc3u7pmjdg3ojq1"
}

variable "aws_nginx_instance_disk_size" {
  description = "default size of the root disk (GB)"
  default = "10"
}

variable "aws_nginx_instance_type" {
  description = "AWS instance type"
  default = "t2.large"
}

variable "num_of_nginx" {
  description = "num of instances"
  default = 3
}