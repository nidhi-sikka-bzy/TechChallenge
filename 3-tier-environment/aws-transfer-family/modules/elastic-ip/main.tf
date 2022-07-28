resource "aws_eip" "this" {
  count = var.create_eip && var.eip_count > 0 ? var.eip_count : 0

  vpc  = var.vpc
  tags = merge(
    var.tags,
    { Name =  var.eip_resource_name }
  )
}