resource "aws_iam_policy" "policy" {
  for_each    = local.has_policies
  name        = var.name
  name_prefix = local.name_prefix
  path        = "/"
  policy      = data.aws_iam_policy_document.merged.json

  description = "A policy for the ${local.profile_name} role."

  tags = local.tags
}

data "aws_iam_policy_document" "merged" {
  source_policy_documents = var.policy_documents
}
