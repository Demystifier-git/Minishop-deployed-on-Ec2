output "lb_arn" {
  value = aws_lb.app.arn
}

output "lb_arn_suffix" {
  value = aws_lb.app.arn_suffix
}

output "lb_security_group_id" {
  value = aws_security_group.lb_sg.id
}

output "frontend_tg_arn_suffix" {
  value = aws_lb_target_group.frontend.arn_suffix
}

output "grafana_tg_arn_suffix" {
  value = aws_lb_target_group.grafana.arn_suffix
}

output "prometheus_tg_arn_suffix" {
  value = aws_lb_target_group.prometheus.arn_suffix
}

output "frontend_tg_arn" {
  value = aws_lb_target_group.frontend.arn
}

output "grafana_tg_arn" {
  value = aws_lb_target_group.grafana.arn
}

output "prometheus_tg_arn" {
  value = aws_lb_target_group.prometheus.arn
}

output "lb_dns_name" {
  value = aws_lb.app.dns_name
}

output "lb_zone_id" {
  value = aws_lb.app.zone_id
}

output "frontend_target_group_arn" {
  value = aws_lb_target_group.frontend.arn
}

output "backend_target_group_arn" {
  value = aws_lb_target_group.backend.arn
}

output "backend_target_group_arn_suffix" {
  value = aws_lb_target_group.backend.arn_suffix
}

output "otel_target_group_arn" {
  value = aws_lb_target_group.otel.arn
}

