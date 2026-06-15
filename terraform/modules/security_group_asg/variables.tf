variable "name" {}
variable "description" {}
variable "vpc_id" {}

variable "tags" {
  type    = map(string)
  default = {}
}
variable "web_security_group_id" {
  type = string
}

variable "sg_name" {
  type = string
}