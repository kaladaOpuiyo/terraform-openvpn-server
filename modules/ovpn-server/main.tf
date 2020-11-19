data "aws_ami" "openvpn" {
  filter {
    name   = "name"
    values = [format("%s-*", var.resource_name)]
  }
  most_recent = true
  owners      = ["self"]
}



data "template_file" "user_data" {

  template = file("${path.module}/templates/user-data.sh.tpl")

  vars = {
    dns_zone = data.aws_route53_zone.hosted_zone.id
    fqdn     = format("vpn.%s", var.domain)
  }

}

data "aws_instance" "openvpn" {

  filter {
    name   = "tag:Name"
    values = [var.resource_name]
  }

  filter {
    name   = "tag:aws:autoscaling:groupName"
    values = [aws_autoscaling_group.openvpn.0.id]
  }
  depends_on = [aws_autoscaling_group.openvpn, aws_launch_template.openvpn]
}

data "aws_vpc" "vpc" {

  tags = {
    Name = var.vpc_name
  }
}

data "aws_route53_zone" "hosted_zone" {
  name = var.domain
}

data "aws_subnet_ids" "subnets" {
  vpc_id = data.aws_vpc.vpc.id

}

resource "aws_autoscaling_group" "openvpn" {

  count                     = var.instance_count
  desired_capacity          = var.instance_count
  health_check_grace_period = 300
  health_check_type         = "EC2"
  max_size                  = var.instance_count
  min_size                  = var.instance_count
  vpc_zone_identifier       = data.aws_subnet_ids.subnets.ids
  name_prefix               = aws_launch_template.openvpn.latest_version

  launch_template {
    id      = aws_launch_template.openvpn.id
    version = "$Latest"
  }

  lifecycle {
    create_before_destroy = true
  }

  tag {
    key                 = "Name"
    value               = format("%s", var.resource_name)
    propagate_at_launch = true
  }

  termination_policies = ["OldestInstance"]
}


resource "aws_launch_template" "openvpn" {

  name_prefix = format("%s", var.resource_name)

  block_device_mappings {
    device_name = "/dev/xvda"

    ebs {
      iops        = 100
      volume_size = var.volume_size
      volume_type = var.volume_type

    }
  }

  capacity_reservation_specification {
    capacity_reservation_preference = "open"
  }

  ebs_optimized = true

  image_id = data.aws_ami.openvpn.id

  instance_initiated_shutdown_behavior = "terminate"

  instance_market_options {
    market_type = "spot"
    spot_options {
      instance_interruption_behavior = "terminate"
    }
  }

  iam_instance_profile {
    arn = var.iam_instance_profile_openvpn_arn
  }

  instance_type = var.instance_type


  key_name = var.key_name

  network_interfaces {
    delete_on_termination = true
    security_groups       = [var.security_group_id]
  }

  tag_specifications {
    resource_type = "instance"

    tags = {
      Name           = format("%s", var.resource_name)
      associated_vpc = var.vpc_name
    }
  }

  tag_specifications {
    resource_type = "volume"

    tags = {
      Name = format("%s", var.resource_name)
    }
  }

  user_data = base64encode(data.template_file.user_data.rendered)

  lifecycle {
    create_before_destroy = true
  }
}


resource "aws_route53_record" "openvpn" {

  name    = format("vpn.%s", var.domain)
  records = [data.aws_instance.openvpn.public_ip]
  ttl     = "300"
  type    = "A"
  zone_id = data.aws_route53_zone.hosted_zone.id
}

