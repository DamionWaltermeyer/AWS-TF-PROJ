variable "vpc_id" {
  type = string
}

variable "private_subnet_ids" {
  type = list(string)
}

variable "app_sg_id" {
  type = string
}

variable "db_name" {
  type    = string
  default = "appdb"

  validation {
    condition     = can(regex("^[a-zA-Z0-9_]+$", var.db_name))
    error_message = "Database name must only contain letters, numbers, and underscores."
}
}

variable "db_user" {
  type    = string
  default = "appuser"

}

variable "db_password" {
  type      = string
  sensitive = true
  
}