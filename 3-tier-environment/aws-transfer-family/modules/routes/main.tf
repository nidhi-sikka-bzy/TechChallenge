resource "aws_route_table" "public" {
  count = var.create_routes && var.count_of_public_subnets > 0 ? var.public_route_table_count : 0

  vpc_id = var.vpc_id

  tags = merge(
    var.tags,
    { Name = element(concat(var.route_name_prefix, [""]), count.index) }
  )
}

resource "aws_route" "public" {
  count = var.create_routes && var.count_of_public_subnets > 0 ? var.public_route_table_count : 0

  route_table_id         = aws_route_table.public[count.index].id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = var.igw_id
}

resource "aws_route_table_association" "public" {
  count = var.create_routes && var.count_of_public_subnets > 0 ? var.count_of_public_subnets : 0

  subnet_id      = var.public_subnet_ids[count.index]
  route_table_id = var.public_route_table_count > 1 ? aws_route_table.public[count.index].id : aws_route_table.public[0].id
}
