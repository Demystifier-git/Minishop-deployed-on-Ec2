resource "aws_launch_template" "this" {

  name_prefix = "backend-lt-"

  image_id = var.backend_ami

  instance_type = var.instance_type

  vpc_security_group_ids = var.security_group_ids

  iam_instance_profile {
  arn = var.instance_profile_arn
}

  user_data = base64encode(templatefile(
    "${path.module}/userdata.sh",
    {
      aws_region               = var.aws_region
      secret_name              = var.secret_name
      backend_version_parameter = var.backend_version_parameter
    }
  ))
}

resource "aws_autoscaling_group" "this" {

  name = "backend-asg"

  desired_capacity = var.desired_capacity
  max_size         = var.max_size
  min_size         = var.min_size

  vpc_zone_identifier = var.private_subnets

  target_group_arns = [
    var.target_group_arn
  ]

  health_check_type = "ELB"

  health_check_grace_period = 300

  default_instance_warmup = 300

  launch_template {
    id      = aws_launch_template.this.id
    version = "$Latest"
  }

  instance_refresh {
    strategy = "Rolling"

    preferences {
      min_healthy_percentage = 100
    }

     triggers = [
    "launch_template"
  ]
  }

  tag {
    key                 = "Name"
    value               = "backend-asg-instance"
    propagate_at_launch = true
  }
}

resource "aws_autoscaling_policy" "cpu" {

  name = "backend-cpu-scaling"

  policy_type = "TargetTrackingScaling"

  autoscaling_group_name = aws_autoscaling_group.this.name

  target_tracking_configuration {

    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }

    target_value = 60
  }
}

resource "aws_autoscaling_policy" "requests" {

  name = "backend-request-scaling"

  policy_type = "TargetTrackingScaling"

  autoscaling_group_name = aws_autoscaling_group.this.name

  target_tracking_configuration {

    predefined_metric_specification {

      predefined_metric_type = "ALBRequestCountPerTarget"

      resource_label = "${var.lb_arn_suffix}/${var.target_group_arn_suffix}"
    }

    target_value = 1000
  }
}
