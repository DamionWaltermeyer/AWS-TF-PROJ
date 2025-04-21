import os
import sys

#This file sets up a TF directory with some aws basics tied to main.tf

base_dir = "terraform"

paths = [
    base_dir,
    f"{base_dir}/modules",
    f"{base_dir}/modules/network",
    f"{base_dir}/modules/compute",
    f"{base_dir}/modules/data",
    f"{base_dir}/modules/load_balancer",

]


main_tf_content = '''
module "network" {
  source   = "./modules/network"
  vpc_cidr = "x.x.x.x/xx"
}

module "compute" {
  source      = "./modules/compute"
  ami_id      = "ami-somethingorother"
  instance_type = var.instance_type
  subnet_id   = "subnet-abc123" 
}

module "data" {
  source      = "./modules/data"
  db_name     = "mydb"
  db_user     = "admin"
  db_password = "ChangeMe123!"
}
'''

variables_tf_content = '''
variable "region" {
  default = "us-east-1"
}

variable "instance_type" {
  default = "t3.micro"
}
'''

providers_tf_content = '''
provider "aws" {
  region = var.region
}
'''

tfvars_example_content = '''
region = "us-east-1"
instance_type = "t3.micro"
'''

# Module placeholders
empty_tf = ""

# File mapping
files = {
    f"{base_dir}/main.tf": main_tf_content,
    f"{base_dir}/variables.tf": variables_tf_content,
    f"{base_dir}/outputs.tf": empty_tf,
    f"{base_dir}/providers.tf": providers_tf_content,
    f"{base_dir}/terraform.tfvars.example": tfvars_example_content,
    f"{base_dir}/modules/network/main.tf": empty_tf,
    f"{base_dir}/modules/network/variables.tf": empty_tf,
    f"{base_dir}/modules/network/outputs.tf": empty_tf,
    f"{base_dir}/modules/compute/main.tf": empty_tf,
    f"{base_dir}/modules/compute/variables.tf": empty_tf,
    f"{base_dir}/modules/compute/outputs.tf": empty_tf,
    f"{base_dir}/modules/data/main.tf": empty_tf,
    f"{base_dir}/modules/data/variables.tf": empty_tf,
    f"{base_dir}/modules/data/outputs.tf": empty_tf,
    f"{base_dir}/modules/load_balancer/main.tf": "",
    f"{base_dir}/modules/load_balancer/variables.tf": "",
    f"{base_dir}/modules/load_balancer/outputs.tf": "",

}

# Create directories
for path in paths:
    os.makedirs(path, exist_ok=True)

# Create files
for filepath, content in files.items():
    with open(filepath, "w") as f:
        f.write(content)

print("\nconfirming...")
missing_items = []

# Check directories
for path in paths:
    if not os.path.isdir(path):
        print(f"Missing directory: {path}")
        missing_items.append(path)
    else:
        print(f"Found directory: {path}")

# Check files
for filepath in files:
    if not os.path.isfile(filepath):
        print(f"Missing file: {filepath}")
        missing_items.append(filepath)
    else:
        print(f"Found file: {filepath}")

# All Good?
if not missing_items:
    print("\nAll files and directories successfully created!")
else:
    print("\nIncomplete setup! Please review missing items above.")
    sys.exit(1)

print("Terraform all set")
