resource "aws_autoscaling_attachment" "backend" {
  autoscaling_group_name = module.ec2_asg.asg_name
  lb_target_group_arn    = module.lb_ssl.backend_target_group_arn
}

resource "aws_autoscaling_attachment" "otel" {
  autoscaling_group_name = module.ec2_asg.asg_name
  lb_target_group_arn    = module.lb_ssl.otel_target_group_arn
}