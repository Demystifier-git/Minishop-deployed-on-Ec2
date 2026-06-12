# VPC
module "vpc" {
  source     = "./modules/vpc"
  cidr_block = var.vpc_cidr
}

# Subnets
module "subnets" {
  source = "./modules/subnets"

  vpc_id             = module.vpc.vpc_id
  availability_zones = var.availability_zones
}

# Internet Gateway
module "igw" {
  source = "./modules/internet-gateway"

  vpc_id = module.vpc.vpc_id
}

# NAT Gateway
module "nat" {
  source = "./modules/nat-gateway"

  # NAT Gateway requires ONE public subnet
  public_subnet_id = module.subnets.public_subnet_ids[0]

  depends_on = [module.igw]
}

# Route Tables
module "routes" {
  source = "./modules/route-tables"

  vpc_id = module.vpc.vpc_id
  igw_id = module.igw.igw_id
  nat_id = module.nat.nat_id

  # Route module expects LISTS
  public_subnet_ids  = module.subnets.public_subnet_ids
  private_subnet_ids = module.subnets.private_subnet_ids
}

# Security Groups
module "web_sg" {
  source = "./modules/security-group-ec2"

  vpc_id  = module.vpc.vpc_id
  sg_name = "ec2-sg"

  lb_security_group_id = module.lb_ssl.lb_security_group_id

}

module "vpc_sg" {
  source = "./modules/security-group-VPC"

  vpc_id  = module.vpc.vpc_id
  sg_name = "vpc-sg"
}

# EC2
module "ec2" {
  source = "./modules/ec2"

  name = "web-server"


  # EC2 expects ONE subnet
  subnet_id = module.subnets.private_subnet_ids[0]

  security_group_ids = [module.web_sg.sg_id]

  ami           = var.ec2_ami
  instance_type = var.instance_type
  key_name      = null
}

# Load Balancer + SSL
module "lb_ssl" {
  source = "./modules/lb_ssl"

  vpc_id = module.vpc.vpc_id

  public_subnet_ids = module.subnets.public_subnet_ids

  target_instance_id = module.ec2.instance_id

  domain_name     = var.domain_name
  certificate_arn = var.certificate_arn
}

# Route53
module "route53" {
  source = "./modules/route53"

  hosted_zone_id = var.hosted_zone_id

  domain_name = var.domain_name
  subdomain   = var.subdomain

  lb_dns_name = module.lb_ssl.lb_dns_name
  lb_zone_id  = module.lb_ssl.lb_zone_id
}

# Auto Scaling Group
module "ec2_asg" {
  source = "./modules/ec2-asg"

  private_subnets    = module.subnets.private_subnet_ids
  security_group_ids = [module.web_sg.sg_id]
  target_group_arn   = module.lb_ssl.backend_target_group_arn

  key_name      = null
  backend_ami   = var.backend_ami
  instance_type = var.instance_type

  aws_region               = var.aws_region
  secret_name              = var.secret_name
  backend_version_parameter = var.backend_version_parameter

  desired_capacity        = var.desired_capacity
  max_size                = var.max_size
  min_size                = var.min_size

  lb_arn_suffix           = module.lb_ssl.lb_arn_suffix
  target_group_arn_suffix = module.lb_ssl.backend_target_group_arn_suffix

  depends_on = [
    module.lb_ssl
  ]
}


module "db_sg" {
  source         = "./modules/security-group-db"
  vpc_id         = module.vpc.vpc_id
  sg_name        = "db-new"
  allowed_sg_ids = [module.web_sg.sg_id]
}


# RDS
module "rds" {
  source = "./modules/rds"

  name               = "mysql-db"
  db_name            = var.db_name
  username           = var.db_username
  password           = var.db_password
  subnet_ids         = module.subnets.private_subnet_ids
  security_group_ids = [module.db_sg.sg_id]

  engine_version    = var.db_engine_version
  instance_class    = var.db_instance_class
  allocated_storage = var.db_allocated_storage
}

module "ecr" {
  source = "./modules/ecr"

  repository_name      = var.ecr_repository_name
  image_tag_mutability = var.ecr_image_tag_mutability
  scan_on_push         = var.ecr_scan_on_push

  tags = {
    Environment = var.environment
    Project     = var.project_name
  }
}

module "ecr_frontend" {
  source = "./modules/ecr"

  repository_name      = "minishop-frontend"
  image_tag_mutability = var.ecr_image_tag_mutability
  scan_on_push         = var.ecr_scan_on_push

  tags = {
    Environment = var.environment
    Project     = var.project_name
  }
}

module "app_secret" {
  source = "./modules/secrets-manager"

  secret_name             = var.secret_name
  description             = var.secret_description
  recovery_window_in_days = var.secret_recovery_window_in_days

  secret_string = jsonencode({
    GRAFANA_ADMIN_USER     = var.grafana_admin_user
    GRAFANA_ADMIN_PASSWORD = var.grafana_admin_password
    GRAFANA_ROOT_URL       = var.grafana_root_url

    SMTP_HOST     = var.smtp_host
    SMTP_USER     = var.smtp_user
    SMTP_PASSWORD = var.smtp_password
    SMTP_FROM     = var.smtp_from

    APP_ENV     = var.environment
    DB_USER     = var.db_username
    DB_PASSWORD = var.db_password
    DB_NAME     = var.db_name
    DB_HOST    = var.db_host
  })

  tags = {
    Project     = var.project_name
    Environment = var.environment
  }
}

# module "tf_state_backend" {
#   source = "./modules/tf_state_backend"
#
#   project_name = var.project_name
#   environment  = var.environment
# }

module "waf" {
  source = "./modules/waf"

  project_name = var.project_name
  environment  = var.environment
  alb_arn      = module.lb_ssl.lb_arn
}