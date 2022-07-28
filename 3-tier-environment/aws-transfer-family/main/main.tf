module "vpc" {
  source = "../modules/vpc"

  vpc_resource_name    = local.vpc_resource_name
  cidr_block           = var.cidr_block
  instance_tenancy     = var.instance_tenancy
  enable_dns_hostnames = var.enable_dns_hostnames
  enable_dns_support   = var.enable_dns_support
  tags                 = var.tags
}

resource "aws_security_group" "allow_all" {
  name        = "allow_all_IPs"
  description = "Allow Port 22 from ALL IPs"
  vpc_id      = module.vpc.vpc_id

  ingress {
    description      = "Allow Port 22 from ALL IPs"
    from_port        = 22
    to_port          = 22
    protocol         = "TCP"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  depends_on = [module.vpc]
}

module "public_subnets" {
  source = "../modules/subnets"

  vpc_id                  = local.vpc_id
  subnets                 = local.public_subnets_config
  map_public_ip_on_launch = var.public_map_public_ip_on_launch
  tags                    = var.tags

  depends_on = [module.vpc]
}

module "internet_gateway" {
  source = "../modules/internet-gateway"

  igw_resource_name       = local.igw_resource_name
  vpc_id                  = local.vpc_id
  subnets                 = length(local.public_subnets_config)
  tags                    = var.tags

  depends_on = [module.vpc]
}

module "public_routes" {
  source = "../modules/routes"

  create_routes            = var.create_default_public_routes
  public_route_table_count = var.public_route_table_count
  count_of_public_subnets  = length(local.public_subnets_config)
  route_name_prefix        = local.public_route_name_prefix
  public_subnet_ids        = module.public_subnets.subnet_id
  vpc_id                   = module.vpc.vpc_id
  igw_id                   = module.internet_gateway.internet_gateway_id
  tags                     = var.tags

  depends_on = [module.internet_gateway]
}

module "elastic_ip1" {
  source = "../modules/elastic-ip"

  create_eip        = var.create_eip
  eip_count         = 1
  vpc               = var.elastic_ips_vpc
  eip_resource_name = local.eip1_resource_name
  tags              = var.tags

  depends_on = [module.internet_gateway]
}

module "elastic_ip2" {
  source = "../modules/elastic-ip"

  create_eip        = var.create_eip
  eip_count         = 1
  vpc               = var.elastic_ips_vpc
  eip_resource_name = local.eip2_resource_name
  tags              = var.tags

  depends_on = [module.internet_gateway]
}

module "transfer-server" {
  source = "../modules/server"

  route53_zone = var.route53_zone
  businessunit = var.businessunit
  environment  = var.environment
  product      = var.product
  region       = var.AWS_REGION
  endpoint_details = {
    address_allocation_ids  = [join(", ", module.elastic_ip1.eip_ids),join(", ", module.elastic_ip2.eip_ids)]
    subnet_ids              = module.public_subnets.subnet_id
    vpc_id                  = module.vpc.vpc_id
    security_group_ids      = [aws_security_group.allow_all.id]
  }
  tags         = var.tags

  depends_on = [module.elastic_ip2]
}

data "aws_network_interfaces" "eni_id1" {
  filter {
    name   = "subnet-id"
    values = ["${element(module.public_subnets.subnet_id, 0)}"]
  }
  depends_on = [module.transfer-server]
}

data "aws_network_interfaces" "eni_id2" {
  filter {
    name   = "subnet-id"
    values = ["${element(module.public_subnets.subnet_id, 1)}"]
  }
  depends_on = [module.transfer-server]
}