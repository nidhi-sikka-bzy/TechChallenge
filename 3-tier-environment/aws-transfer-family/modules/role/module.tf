resource "aws_iam_role" "role" {
  name               = var.name
  name_prefix        = local.name_prefix
  path               = var.path
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
  description        = var.description

  force_detach_policies = true

  tags = merge(local.tags, { "ops/module-primary" : "aws/role" })
}

resource "aws_iam_role_policy_attachment" "policy" {
  for_each   = toset(var.policy_arns)
  role       = aws_iam_role.role.id
  policy_arn = each.key
}

resource "aws_iam_role_policy_attachment" "instance" {
  for_each   = local.has_policies
  role       = aws_iam_role.role.id
  policy_arn = aws_iam_policy.policy[each.key].arn
}
