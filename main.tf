terraform {
  required_version = ">= 1.0"
  
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
  
  # Credentials should be set via environment variables or AWS CLI config
  # Do NOT hardcode credentials in code
}

# Data source to get available AZs
data "aws_availability_zones" "available" {
  state = "available"
}

# Module: Networking (Part 1)
module "networking" {
  source = "./modules/networking"

  vpc_cidr           = var.vpc_cidr
  availability_zones = slice(data.aws_availability_zones.available.names, 0, 2)
  project_name       = var.project_name
  environment        = var.environment
}

# Module: Database (Part 1)
module "database" {
  source = "./modules/database"

  vpc_id              = module.networking.vpc_id
  vpc_cidr            = module.networking.vpc_cidr_block
  private_subnet_ids  = module.networking.private_subnet_ids
  db_instance_class   = var.db_instance_class
  db_allocated_storage = var.db_allocated_storage
  db_name             = var.db_name
  db_username         = var.db_username
  db_password         = var.db_password
  project_name        = var.project_name
  environment         = var.environment
}

# Module: Compute (Part 2)
module "compute" {
  source = "./modules/compute"

  vpc_id            = module.networking.vpc_id
  vpc_cidr          = module.networking.vpc_cidr_block
  public_subnet_ids = module.networking.public_subnet_ids
  instance_type     = var.instance_type
  min_size          = var.min_size
  max_size          = var.max_size
  desired_capacity  = var.desired_capacity
  project_name      = var.project_name
  environment       = var.environment
}

