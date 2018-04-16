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
  vpc_zone_identifier       = ["${aws_subnet.public_a.id}","${aws_subnet.public_b.id}","${aws_subnet.public_c.id}"]
  min_size             = 3
  max_size             = 5

  health_check_grace_period = 300
  health_check_type         = "EC2"

  target_group_arns = ["${aws_lb_target_group.test.arn}"]

  tags = [
    {
      key = "Name"
      value = "nginx"
      propagate_at_launch = true
    },
    {
      key = "owner"
      value = "Charles"
      propagate_at_launch = true
    },
  ]


  lifecycle {
    create_before_destroy = true
  }
  
  depends_on = ["aws_s3_bucket_object.object"]
}

resource "aws_autoscaling_policy" "test" {
  name  = "test"
  adjustment_type = "ChangeInCapacity"
  policy_type = "TargetTrackingScaling"
  autoscaling_group_name = "${aws_autoscaling_group.test.name}"

  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }
    target_value = 1
  }

}


