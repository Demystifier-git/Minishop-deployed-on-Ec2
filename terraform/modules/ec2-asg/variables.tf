variable "private_subnets" {
  type = list(string)
}

variable "security_group_ids" {
  type = list(string)
}

variable "target_group_arns" {
  type = list(string)
}

variable "key_name" {
  type = string
}

variable "backend_ami" {
  type = string
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

variable "lb_arn_suffix" {}
variable "target_group_arn_suffix" {}

variable "aws_region" {
  type = string
}

variable "backend_version_parameter" {
  type = string
}

variable "secret_name" {
  type = string
}

variable "instance_profile_arn" {
  type = string
}
