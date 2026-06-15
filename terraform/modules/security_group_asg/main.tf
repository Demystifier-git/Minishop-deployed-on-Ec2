resource "aws_security_group" "this" {
  name        = var.name
  description = var.description
  vpc_id      = var.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = var.tags
}

ingress {
  description     = "Prometheus to OTel"
  from_port       = 8889
  to_port         = 8889
  protocol        = "tcp"

  security_groups = [module.ec2_sg.security_group_id]
}