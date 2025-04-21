variable "ami_id" {
  type    = string
  default = "ami-0c94855ba95c71c99"

}

variable "instance_type" {
  type    = string
  default = "t3.micro"
}

variable "subnet_id" {
  type = string

}

variable "vpc_id" {
  type = string
}

variable "alb_sg_id" {
  type        = string
  description = "SG for the ALB"

}

variable "target_group_arn" {
  type        = string
  description = "arn pf the ALB target group"
}

variable "db_host" {}
variable "db_user" {}
variable "db_name" {}
variable "db_password" {
  sensitive = true
}
