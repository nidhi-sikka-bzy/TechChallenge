# NOTE: This file deploys Global Accelerator.

module "global-accelerator" {
  source          = "../modules/global-accelerator"
  ga_name         = local.ga_name
  tags            = var.tags
  endpoint_region = {
    primary = var.AWS_REGION
    secondary = var.Second_AWS_REGION
  }
  server_endpoint = {
    primary = [data.aws_eip.peip1.id,data.aws_eip.peip2.id]
    secondary = [data.aws_eip.seip1.id,data.aws_eip.seip2.id]
  }
}
