resource "aws_security_group" "asg" {
  name   = var.name
  vpc_id = var.vpc_id

  # Allow Prometheus (EC2 A) to scrape OTel Collector
  ingress {
    description     = "Prometheus to OTel Collector"
    from_port       = 8889
    to_port         = 8889
    protocol        = "tcp"
    security_groups = [var.web_security_group_id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = var.name
  }

}