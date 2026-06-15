output "security_group_id" {
  description = "EC2 Security Group ID"
  value       = aws_security_group.web.id
}