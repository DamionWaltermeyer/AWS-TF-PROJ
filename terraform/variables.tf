
variable "region" {
  default = "us-east-1"
}

variable "instance_type" {
  default = "t3.micro"
}

variable "ami_id" {
  type        = string
  description = "The AMI ID to use for the EC2 instance"
  default     = "ami-0c94855ba95c71c99"
}

variable "db_name" {
  type = string
}

variable "db_user" {
  type = string
}

variable "db_password" {
  type      = string
  sensitive = true
}

variable "certificate_arn" {
  type        = string
  description = "ARN of cert for https"
}
