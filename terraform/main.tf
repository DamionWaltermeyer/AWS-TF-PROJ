
module "network" {
  source               = "./modules/network"
  vpc_cidr             = "10.0.0.0/16"
  public_subnet_cidrs  = ["10.0.1.0/24", "10.0.2.0/24"]
  private_subnet_cidrs = ["10.0.101.0/24", "10.0.102.0/24"]
  enable_nat_gateway   = true
}

module "compute" {
  source           = "./modules/compute"
  ami_id           = var.ami_id
  instance_type    = var.instance_type
  subnet_id        = module.network.private_subnet_ids[0]
  vpc_id           = module.network.vpc_id
  alb_sg_id        = module.load_balancer.alb_sg_id
  target_group_arn = module.load_balancer.target_group_arn
  
  db_host     = module.data.db_endpoint
  db_name     = var.db_name
  db_user     = var.db_user
  db_password = var.db_password
}

module "data" {
  source             = "./modules/data"
  vpc_id             = module.network.vpc_id
  private_subnet_ids = module.network.private_subnet_ids
  app_sg_id          = module.compute.app_sg_id

  db_name     = var.db_name
  db_user     = var.db_user
  db_password = var.db_password
}

module "load_balancer" {
  source            = "./modules/load_balancer"
  vpc_id            = module.network.vpc_id
  public_subnet_ids = module.network.public_subnet_ids
  certificate_arn   = var.certificate_arn

}