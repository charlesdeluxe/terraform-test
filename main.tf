
# Set provider details
provider "aws" {
  profile = "${var.aws_profile}"
  region = "${var.aws_region}"
}

locals {
  private_key = "${file(var.ssh_private_key_filename)}"
  agent = "${var.ssh_private_key_filename == "/dev/null" ? true : false}"
}

# Create VPC
resource "aws_vpc" "test" {
  cidr_block = "10.0.0.0/16"
  enable_dns_hostnames = "true"

tags {
   Name = "test"
  }
}

# Create Subnet
resource "aws_subnet" "public" {
  vpc_id                  = "${aws_vpc.test.id}"
  cidr_block              = "10.0.0.0/22"
  map_public_ip_on_launch = true
}



# Create s3 bucket
resource "aws_s3_bucket" "test_bucket" {
  bucket = "${var.bucket_name}"
  acl    = "private"

  tags {
    Name        = "test_bucket"
  }
}

# Put a file in the s3 bucket.  This will be fetched by nginx hosts to /var/www/html/
resource "aws_s3_bucket_object" "object" {
  bucket = "${var.bucket_name}"
  key    = "index.html"
  source = "files/index.html"
  etag   = "${md5(file("files/index.html"))}"
  depends_on = ["aws_s3_bucket.test_bucket"]
}


# Create an internet gateway for egress
resource "aws_internet_gateway" "default" {
  vpc_id = "${aws_vpc.test.id}"
}


# Grant the VPC internet access on its main route table
resource "aws_route" "internet_access" {
  route_table_id         = "${aws_vpc.test.main_route_table_id}"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = "${aws_internet_gateway.default.id}"
}


# Create security group
resource "aws_security_group" "nginx" {
  name        = "nginx-security-group"
  description = "A security group for the elb"
  vpc_id      = "${aws_vpc.test.id}"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress { 
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}





