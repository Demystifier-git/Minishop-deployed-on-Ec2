variable "aws_region" {
  type = string

}

variable "vpc_cidr" {
  description = "The CIDR block for the VPC"
  type        = string

}

variable "availability_zones" {
  description = "List of availability zones to create subnets in"
  type        = list(string)

}



variable "ec2_ami" {
  description = "The AMI ID to use for EC2 instances"
  type        = string
}

variable "certificate_arn" {
  description = "ARN of the ACM SSL certificate"
  type        = string
}

variable "domain_name" {
  description = "main Domain name for the application"
  type        = string
}

variable "hosted_zone_id" {
  description = "Route53 hosted zone ID"
  type        = string
}

variable "subdomain" {
  description = "Subdomain for the application"
  type        = string

}


variable "instance_type" {
  type = string
}

variable "desired_capacity" {
  type = number
}

variable "max_size" {
  type = number
}

variable "min_size" {
  type = number
}


variable "db_username" {
  description = "Master username for the RDS database"
  type        = string
  sensitive   = true
}

variable "db_password" {
  description = "Master password for the RDS database"
  type        = string
  sensitive   = true
}

variable "db_engine_version" {
  description = "MySQL engine version for the RDS instance"
  type        = string
}

variable "db_instance_class" {
  description = "RDS instance class"
  type        = string
}

variable "db_allocated_storage" {
  description = "Allocated storage for the RDS instance in GB"
  type        = number
}

variable "db_sg_name" {
  description = "Name of the database security group"
  type        = string
  default     = "db-new"
}

variable "db_name" {
  description = "Name of database"
  type        = string
}

variable "environment" {
  description = "Deployment environment"
  type        = string
}

variable "project_name" {
  description = "Project name"
  type        = string
}

# =========================
# ECR Variables
# =========================
variable "ecr_repository_name" {
  description = "Name of the ECR repository"
  type        = string
}

variable "ecr_image_tag_mutability" {
  description = "Whether image tags are mutable or immutable"
  type        = string
}

variable "ecr_scan_on_push" {
  description = "Enable image scanning on push"
  type        = bool
}

# =========================
# Secrets Manager Variables
# =========================
variable "secret_name" {
  description = "Name of the application secret"
  type        = string
}

variable "secret_description" {
  description = "Description of the secret"
  type        = string
}

variable "secret_recovery_window_in_days" {
  description = "Recovery window before secret deletion"
  type        = number
}

variable "grafana_admin_user" {
  type = string
}

variable "grafana_admin_password" {
  type      = string
  sensitive = true
}

variable "grafana_root_url" {
  type = string
}

variable "smtp_host" {
  type = string
}

variable "smtp_user" {
  type = string
}

variable "smtp_password" {
  type      = string
  sensitive = true
}

variable "smtp_from" {
  type = string
}

variable "s3_bucket_domain_name" {
  description = "S3 bucket domain name used as CloudFront origin (e.g. bucket.s3.amazonaws.com)"
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9.-]+\\.s3(\\.amazonaws\\.com)?$", var.s3_bucket_domain_name))
    error_message = "Must be a valid S3 bucket domain name."
  }
}

variable "logs_bucket_name" {
  description = "S3 bucket name used for CloudFront/WAF logs"
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9.-]{3,63}$", var.logs_bucket_name))
    error_message = "Logs bucket name must be a valid S3 bucket name (3-63 lowercase letters, numbers, dots, or hyphens)."
  }
}


