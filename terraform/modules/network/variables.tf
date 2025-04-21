variable "vpc_cidr" {
  type    = string
  default = "10.0.0.0/16"

}

variable "public_subnet_cidrs" { # the public subnets 
  type    = list(string)
  default = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "private_subnet_cidrs" { # the private subnets
  type    = list(string)
  default = ["10.0.101.0/24", "10.0.102.0/24"]
}

variable "enable_nat_gateway" { #going to configure a nat gateway currently a todo
  type    = bool
  default = true
}
