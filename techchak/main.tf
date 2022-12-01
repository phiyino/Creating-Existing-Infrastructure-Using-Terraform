# configure aws provider
provider "aws" {
    region = var.region
}

# create vpc
module "vpc" {
    source = "../modules/vpc"
    region                  = var.region
    project_name            = var.project_name
    vpc_cidr                = var.vpc_cidr
    public_subnet_az1_cidr  = var.public_subnet_az1_cidr
    public_subnet_az2_cidr  = var.public_subnet_az2_cidr
    private_subnet_az1_cidr = var.private_subnet_az1_cidr
    private_subnet_az2_cidr = var.private_subnet_az2_cidr
  
}

# create nat gateway
module "nat-gateway" {
    source = "../modules/nat-gateway"
    public_subnet_az1_id    = module.vpc.public_subnet_az1_id
    public_subnet_az2_id    = module.vpc.public_subnet_az2_id
    internet_gateway        = module.vpc.internet_gateway
    vpc_id                  = module.vpc.vpc_id
    private_subnet_az1_id   = module.vpc.private_subnet_az1_id
    private_subnet_az2_id   = module.vpc.private_subnet_az2_id
  
}

#create security group
module "security-group" {
    source = "../modules/security-group"
    vpc_id = module.vpc.vpc_id

  
}

#create mysql instance
module "mysql_server" {
    source = "../modules/mysql_server"
    ami_az1_id                  = var.ami_az1_id
    ami_az2_id                  = var.ami_az2_id
    private_subnet_az1_id       = module.vpc.private_subnet_az1_id
    private_subnet_az2_id       = module.vpc.private_subnet_az2_id
    database_security_group_id  = module.security-group.database_security_group_id
  
}

#create alb
module "alb" {
    source = "../modules/alb"
    project_name         = module.vpc.project_name
    alb_securitygroup_id = module.security-group.alb_securitygroup_id
    public_subnet_az1_id = module.vpc.public_subnet_az1_id
    public_subnet_az2_id = module.vpc.public_subnet_az2_id
    vpc_id               = module.vpc.vpc_id
  
}

#create webserver_asg
module "webserver_asg" {
    source = "../modules/webserver_asg"
    ami_az1_id                  = var.ami_az1_id
    webserver_security_group_id = module.security-group.webserver_security_group_id
    vpc_id                      = module.vpc.vpc_id
    public_subnet_az1_id        = module.vpc.public_subnet_az1_id
    public_subnet_az2_id        = module.vpc.public_subnet_az2_id
    alb_target_group_arn        = module.alb.alb_target_group_arn
    
  
}  