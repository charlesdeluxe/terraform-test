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
}















# resource "aws_placement_group" "test" {
#   name     = "test"
#   strategy = "cluster"
# }

# resource "aws_autoscaling_group" "test" {
#   name                      = "foobar3-terraform-test"
#   max_size                  = 5
#   min_size                  = 3
#   health_check_grace_period = 300
#   health_check_type         = "ELB"
#   desired_capacity          = 3
#   force_delete              = true
#   placement_group           = "${aws_placement_group.test.id}"
#   launch_configuration      = "${aws_launch_configuration.foobar.name}"
#   vpc_zone_identifier       = ["${aws_subnet.example1.id}", "${aws_subnet.example2.id}"]

#   initial_lifecycle_hook {
#     name                 = "foobar"
#     default_result       = "CONTINUE"
#     heartbeat_timeout    = 2000
#     lifecycle_transition = "autoscaling:EC2_INSTANCE_LAUNCHING"

#     notification_metadata = <<EOF
# {
#   "foo": "bar"
# }
# EOF

#     notification_target_arn = "arn:aws:sqs:us-east-1:444455556666:queue1*"
#     role_arn                = "arn:aws:iam::123456789012:role/S3Access"
#   }

#   tag {
#     key                 = "foo"
#     value               = "bar"
#     propagate_at_launch = true
#   }

#   timeouts {
#     delete = "15m"
#   }

#   tag {
#     key                 = "lorem"
#     value               = "ipsum"
#     propagate_at_launch = false
#   }
# }