
# VPC

output "vpc_id" {
  value = module.vpc.vpc_id
}


# SUBNETS

output "public_subnet_ids" {
  value = module.subnets.public_subnet_ids
}

output "private_subnet_ids" {
  value = module.subnets.private_subnet_ids
}


# INTERNET GATEWAY

output "igw_id" {
  value = module.igw.igw_id
}


# NAT GATEWAY

output "nat_id" {
  value = module.nat.nat_id
}


# SECURITY GROUPS

output "web_sg_id" {
  value = module.web_sg.sg_id
}

output "vpc_sg_id" {
  value = module.vpc_sg.sg_id
}


# EC2 (single instance)

output "ec2_instance_id" {
  value = module.ec2.instance_id
}

output "ec2_private_ip" {
  value = module.ec2.private_ip
}


# LOAD BALANCER

output "lb_dns_name" {
  value = module.lb_ssl.lb_dns_name
}

output "lb_zone_id" {
  value = module.lb_ssl.lb_zone_id
}


# ROUTE53

output "route53_fqdn" {
  value = module.route53.fqdn
}


# AUTO SCALING GROUP

output "asg_name" {
  value = module.ec2_asg.asg_name
}

output "asg_launch_template_id" {
  value = module.ec2_asg.launch_template_id
}

output "ecr_repository_url" {
  value = module.ecr.repository_url
}

output "ecr_repository_arn" {
  value = module.ecr.repository_arn
}

output "secret_arn" {
  value = module.app_secret.secret_arn
}

output "secret_name" {
  value = module.app_secret.secret_name
}

output "cloudfront_domain" {
  value = module.cloudfront_waf.cloudfront_domain_name
}

output "waf_arn" {
  value = module.cloudfront_waf.waf_web_acl_arn
}

