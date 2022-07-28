resource "aws_subnet" "this" {
  for_each = { for subnet in var.subnets : subnet.name_prefix => subnet } 

  vpc_id                  = var.vpc_id
  cidr_block              = each.value.cidr_block
  availability_zone       = each.value.availability_zone
  map_public_ip_on_launch = var.map_public_ip_on_launch

  tags = merge(
    var.tags,
    { Name =  each.key }
  )
}
