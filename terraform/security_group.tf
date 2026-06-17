resource "aws_security_group_rule" "promtail_to_loki" {
  type                     = "ingress"
  from_port                = 3100
  to_port                  = 3100
  protocol                 = "tcp"

  security_group_id        = module.web_sg.security_group_id
  source_security_group_id = module.backend_asg_sg.security_group_id
}

resource "aws_security_group_rule" "prometheus_to_otel" {
  type                     = "ingress"
  from_port                = 8889
  to_port                  = 8889
  protocol                 = "tcp"

  security_group_id        = module.backend_asg_sg.security_group_id
  source_security_group_id = module.web_sg.security_group_id
}

resource "aws_security_group_rule" "alb_to_backend" {
  type                     = "ingress"
  from_port                = 8000
  to_port                  = 8000
  protocol                 = "tcp"

  security_group_id        = module.backend_asg_sg.security_group_id
  source_security_group_id =  module.lb_ssl.lb_security_group_id
}

resource "aws_security_group_rule" "prometheus_to_otel" {
  type                     = "ingress"
  from_port                = 8889
  to_port                  = 8889
  protocol                 = "tcp"

  security_group_id        = module.backend_asg_sg.security_group_id
  source_security_group_id = module.lb_ssl.lb_security_group_id
}