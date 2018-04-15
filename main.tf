
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
resource "aws_subnet" "public_b" {
  vpc_id                  = "${aws_vpc.test.id}"
  availability_zone = "us-west-2b"
  cidr_block              = "10.0.0.0/22"
  map_public_ip_on_launch = true
}

resource "aws_subnet" "public_a" {
  vpc_id                  = "${aws_vpc.test.id}"
  availability_zone = "us-west-2a"
  cidr_block              = "10.0.4.0/22"
  map_public_ip_on_launch = true
}

resource "aws_subnet" "public_c" {
  vpc_id                  = "${aws_vpc.test.id}"
  availability_zone = "us-west-2c"
  cidr_block              = "10.0.8.0/22"
  map_public_ip_on_launch = true
}


# Create s3 bucket for nginx files
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

# # Create s3 bucket for ELB access logs
# resource "aws_s3_bucket_object" "logs" {
#   bucket = "${var.logs_bucket_name}"
#   acl = "private"
# }

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
  description = "A security group for nginx hosts"
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

resource "aws_security_group" "lb_sg" {
  name = "lb-security-group"
  description = "security group for the load balancer"
  vpc_id = "${aws_vpc.test.id}"
  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port = 443
    to_port = 443
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]      
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Create load balancer
resource "aws_lb" "test" {
  name               = "nginx-lb"
  internal = false
  subnets = ["${aws_subnet.public_a.id}","${aws_subnet.public_b.id}", "${aws_subnet.public_c.id}"] 
  security_groups = ["${aws_security_group.lb_sg.id}"]
  idle_timeout = 300

  tags {
    Name = "nginx-lb"
  }
}

resource "aws_lb_target_group" "test" {
  name     = "nginx-lb-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = "${aws_vpc.test.id}"
}



resource "aws_lb_listener" "test" {
  load_balancer_arn = "${aws_lb.test.arn}"
  port = "80"
  protocol = "HTTP"
  default_action {
    target_group_arn = "${aws_lb_target_group.test.arn}"
    type = "forward"
  }
}

output "LB DNS" {
  value = "${aws_lb.test.dns_name}"
}
# Create SSL certificate? needed?



