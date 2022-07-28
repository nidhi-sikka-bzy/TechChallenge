locals {
  name_prefix = "${var.businessunit}-${var.environment}-${var.product}"
  bucket      = "${var.businessunit}-${var.environment}-${var.product}.${var.Client_REGION}"
  tags        = merge({ Client = "internaldevops", Contact = "nidhi9sikka@gmail.com" }, var.tags)
}

data "terraform_remote_state" "server" {
  backend = "s3"  
  config = {
    bucket = "terraform-state-${var.businessunit}-${var.environment}-${var.region}"
    key    = "internaldevops/transfer-family/${var.AWS_REGION}/transfer-server/terraform.tfstate"
    region = var.region
  }
}

/*data "terraform_remote_state" "bucket" {
  backend = "s3"  
  config = {
    bucket = "terraform-state-${var.businessunit}-${var.environment}-${var.region}"
    key    = "internaldevops/transfer-family/bucket-replication/terraform.tfstate"
    region = var.region
  }
}*/

module "sftp_client" {
  source              = "../modules/sftp-user"

  sftp_server_id      = data.terraform_remote_state.server.outputs.transfer-server-details.server.sftp_server_id
  bucket_name         = local.bucket
  password            = var.password
  client_name         = var.client_name
  tags                = local.tags
  secret_prefix       = data.terraform_remote_state.server.outputs.transfer-server-details.server.secret_prefix
  is_admin            = true
  AWS_REGION          = var.AWS_REGION
  Client_REGION       = var.Client_REGION
}
