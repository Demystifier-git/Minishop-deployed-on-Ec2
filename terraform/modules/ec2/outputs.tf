output "instance_id" {
  value = aws_instance.this.id
}

output "private_ip" {
  value = aws_instance.this.public_ip
}

output "instance_profile_arn" {
  value = aws_iam_instance_profile.ec2_profile.arn
}