data "aws_route53_zone" "zone" {
  name         = var.route53_zone
  private_zone = false
}

locals {
  name_prefix = "${var.businessunit}-${var.environment}-${var.product}"
  tags = merge({ Client = "internaldevops", Contact = "nidhi9sikka@gmail.com" }, var.tags)
}

module "sftp_server" {
  source                 = "../imported-modules/sftp-server"
  tags                   = local.tags
  name                   = local.name_prefix
  stage_name             = var.environment
  domain                 = "${var.product}.${var.region}.${data.aws_route53_zone.zone.name}"
  zone_id                = data.aws_route53_zone.zone.id
  secret_prefix          = local.name_prefix
  endpoint_details       = var.endpoint_details
}
