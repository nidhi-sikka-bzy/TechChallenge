# NOTE: This file implements two-way replication via the [regions] variable.
# "terraform apply" must be performed two times in order to complete the two-way replication configuration...

data "aws_route53_zone" "zone" {
  name         = var.route53_zone
  private_zone = false
}

locals {
  name_prefix = "${var.businessunit}-${var.environment}-${var.product}"
  tags = merge({ Client = "internaldevops", Contact = "nidhi9sikka@gmail.com" }, var.tags)
}

module "bucket_primary" {
  source         = "../modules/imported-modules/bucket"
  name           = local.name_prefix
  domain         = "${data.aws_route53_zone.zone.name}"
  regions        = [var.AWS_REGION,var.Second_AWS_REGION]
  tags           = var.tags
}

module "bucket_secondary" {
  source          = "../modules/imported-modules/bucket"
  providers = {
    aws = aws.secondary
  }
  name           = local.name_prefix
  domain         = "${data.aws_route53_zone.zone.name}"
  regions        = [var.Second_AWS_REGION,var.AWS_REGION]
  tags           = var.tags
}
