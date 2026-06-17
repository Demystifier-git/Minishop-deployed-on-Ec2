variable "vpc_id" { type = string }
variable "public_subnet_ids" { type = list(string) }
variable "target_instance_id" { type = string }
variable "certificate_arn" { type = string } # ACM certificate ARN
variable "domain_name" { type = string }
