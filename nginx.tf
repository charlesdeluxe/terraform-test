resource "aws_instance" "nginx" {
  connection {
    user = "ubuntu"
    private_key = "${local.private_key}"
    agent = "${local.agent}"
  }

  root_block_device {
    volume_size = "${var.aws_nginx_instance_disk_size}"
  }

  count = "${var.num_of_nginx}"
  instance_type = "${var.aws_nginx_instance_type}"
  iam_instance_profile = "${aws_iam_instance_profile.nginx.name}"

  tags {
   owner = "${var.owner}"
   Name = "nginx-${count.index + 1}"
  }

  ami = "${var.aws_ami}"
  key_name = "${var.ssh_key_name}"

  vpc_security_group_ids = ["${aws_security_group.nginx.id}"]

  subnet_id = "${aws_subnet.public.id}"

  lifecycle {
    ignore_changes = ["tags.Name", "tags.cluster"]
  }
}


resource "null_resource" "nginx" {

  count = "${var.num_of_nginx}"

  connection {
    host = "${element(aws_instance.nginx.*.public_ip, count.index)}"
    user = "ubuntu"
    private_key = "${local.private_key}"
    agent = "${local.agent}"
  }

  provisioner "remote-exec" {
    script = "scripts/setup.sh"
  }
}


output "Nginx Public IPs" {
  value = ["${aws_instance.nginx.*.public_ip}"]
}


