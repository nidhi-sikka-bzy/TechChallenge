data "aws_vpc" "vpc" {
  count = local.vpc_name == null ? 0 : 1

  tags = {
    Name = local.vpc_name
  }
}

data "aws_subnet_ids" "private" {
  count = local.vpc_name == null ? 0 : 1

  vpc_id = data.aws_vpc.vpc[0].id

  tags = {
    "net/private" = "true"
  }
}
