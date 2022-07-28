resource "aws_vpc" "this" {

  cidr_block           = var.cidr_block
  instance_tenancy     = var.instance_tenancy
  enable_dns_hostnames = var.enable_dns_hostnames
  enable_dns_support   = var.enable_dns_support

  tags = merge(
    var.tags,
    { Name = var.vpc_resource_name }
  )
}

resource "aws_flow_log" "this" {
  count = var.create_flow_log ? 1 : 0

  log_destination = aws_cloudwatch_log_group.this[0].arn
  iam_role_arn    = aws_iam_role.this[0].arn
  vpc_id          = aws_vpc.this.id
  traffic_type    = var.traffic_type

  tags = merge(
    var.tags,
    { Name = var.vpc_resource_name }
  )
}

resource "aws_cloudwatch_log_group" "this" {
  count = var.create_flow_log ? 1 : 0
  name = local.vpc_flow_log_group_name

  tags = merge(
    var.tags,
    { Name = var.vpc_resource_name }
  )
}

resource "aws_iam_role" "this" {
  count = var.create_flow_log ? 1 : 0
  name = local.vpc_flow_log_group_role_name

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": "vpc-flow-logs.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
  tags = merge(
    var.tags,
    { Name = var.vpc_resource_name }
  )
}

resource "aws_iam_role_policy" "this" {
  count = var.create_flow_log ? 1 : 0
  name = local.vpc_flow_log_group_policy_name
  role = aws_iam_role.this[0].id

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents",
        "logs:DescribeLogGroups",
        "logs:DescribeLogStreams"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF
}
