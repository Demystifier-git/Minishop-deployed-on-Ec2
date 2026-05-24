resource "aws_launch_template" "this" {
  name_prefix   = "app-lt-"
  image_id      = var.ec2_ami
  instance_type = var.instance_type

  vpc_security_group_ids = var.security_group_ids

  user_data = base64encode(<<EOF
#!/bin/bash

echo "Starting app..."

EOF
  )
}


# AUTO SCALING GROUP


resource "aws_autoscaling_group" "this" {
  name                = "app-asg"
  desired_capacity    = var.desired_capacity
  max_size            = var.max_size
  min_size            = var.min_size
  vpc_zone_identifier = var.private_subnets

  health_check_type         = "ELB"
  health_check_grace_period = 300

  target_group_arns = [var.target_group_arn]

  launch_template {
    id      = aws_launch_template.this.id
    version = "$Latest"
  }

  # Helps prevent premature scaling decisions
  default_instance_warmup = 300

  tag {
    key                 = "Name"
    value               = "asg-instance"
    propagate_at_launch = true
  }
}


# CPU TARGET TRACKING


resource "aws_autoscaling_policy" "cpu_target_tracking" {
  name                   = "cpu-target-tracking"
  policy_type            = "TargetTrackingScaling"
  autoscaling_group_name = aws_autoscaling_group.this.name

  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }

    # Maintain average CPU around 60%
    target_value = 60
  }
}


# ALB REQUEST TARGET TRACKING


resource "aws_autoscaling_policy" "alb_requests_tracking" {
  name                   = "alb-requests-tracking"
  policy_type            = "TargetTrackingScaling"
  autoscaling_group_name = aws_autoscaling_group.this.name

  target_tracking_configuration {

    predefined_metric_specification {
      predefined_metric_type = "ALBRequestCountPerTarget"

      resource_label = "${var.lb_arn_suffix}/${var.target_group_arn_suffix}"
    }

    # Requests per target before scaling
    target_value = 1000
  }
}