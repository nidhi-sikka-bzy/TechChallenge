data "aws_iam_policy_document" "assume" {
  statement {
    sid     = "AllowAWSAssumeRole"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["${var.service}.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "assume_role" {
  source_json   = data.aws_iam_policy_document.assume.json
  override_json = var.assume_role_policy_document
}
