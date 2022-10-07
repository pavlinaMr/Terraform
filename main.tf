##################################################################################
# CONFIGURATION - added for Terraform 0.14
##################################################################################

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~>3.0"
    }
  }
  required_version  = ">= 0.14.9"
}
##################################################################################
# PROVIDERS
##################################################################################

provider "aws" {
  profile = "default"
  region  = var.region
}

resource "aws_iam_role" "application_role" {
    name = "${var.namespace}-cloudwatch-role"
    path = "/"
    
    assume_role_policy = file("policies/application_assume_role_policy.json")  
}

resource "aws_iam_instance_profile" "application_profile" {
    name = "${var.namespace}-app-profile"
    role = aws_iam_role.application_role.name
}

resource "aws_iam_policy" "cloudwatch_log_full_access_policy" {
    name = "${var.namespace}-cloudwatchlogs-full-access"
    path = "/"

    policy = file("policies/application_policy.json")
}

resource "aws_iam_policy_attachment" "cloudwatch_log_full_access_policy" {
    name = "${var.namespace}-cloudwatch_log_full_access_policy"
    roles = [ aws_iam_role.application_role.name ]
    policy_arn = aws_iam_policy.cloudwatch_log_full_access_policy.arn
}

module "networking" {
  source        = "./networking"
  region        = var.region
  availability_zone_A = var.availability_zone_A
  availability_zone_B = var.availability_zone_B
  vpc_cidr      = var.vpc_cidr
  subnets       = var.subnets
  namespace = var.namespace
}

module "compute" {
  source         = "./compute"
  region         = var.region
  availability_zone_A = var.availability_zone_A
  availability_zone_B = var.availability_zone_B
  alb_sg         = module.loadbalancing.alb_sg
  alb_tg_arn     = module.loadbalancing.alb_tg_arn
  private_subnet_app1 = module.networking.private_subnet_app1
  private_subnet_app2 = module.networking.private_subnet_app2
  private_subnet_db1  = module.networking.private_subnet_db1
  private_subnet_db2  = module.networking.private_subnet_db2
  vpc_id         = module.networking.vpc_id
  application_profile =  aws_iam_instance_profile.application_profile.name
  namespace   = var.namespace 
}

module "loadbalancing" {
  source         = "./loadbalancing"
  public_subnet1 = module.networking.public_subnet1
  public_subnet2 = module.networking.public_subnet2
  vpc_id         = module.networking.vpc_id 
  application_sg = module.compute.application_sg
}
