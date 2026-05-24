variable "vpc_id" {}
variable "sg_name" {}
variable "lb_security_group_id" {
  description = "Load balancer security group ID"
  type        = string
}