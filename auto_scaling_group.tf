data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-trusty-14.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

# This launch configuration uses setup.sh as user_data to configure the instance
# when it comes up.  
resource "aws_launch_configuration" "as_conf" {
  name_prefix   = "nginx-"
  image_id      = "${data.aws_ami.ubuntu.id}"
  instance_type = "t2.micro"
  key_name      = "${var.ssh_key_name}"
  security_groups = ["${aws_security_group.nginx.id}"]
  user_data     = "${file("setup.sh")}"
  iam_instance_profile = "${aws_iam_instance_profile.nginx.id}"
  root_block_device {
    volume_size = "${var.aws_nginx_instance_disk_size}"
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "test" {
  name                 = "test"
  launch_configuration = "${aws_launch_configuration.as_conf.name}"
  vpc_zone_identifier       = ["${aws_subnet.public.id}"]
  min_size             = 3
  max_size             = 5

  lifecycle {
    create_before_destroy = true
  }
  
  depends_on = ["aws_s3_bucket_object.object"]
}

