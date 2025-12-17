# GitHub OIDC Provider
data "tls_certificate" "github" {
  url = "https://token.actions.githubusercontent.com/.well-known/openid-configuration"
}

resource "aws_iam_openid_connect_provider" "github" {
  url             = "https://token.actions.githubusercontent.com"
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.github.certificates[0].sha1_fingerprint]
}

# The Role GitHub assumes
resource "aws_iam_role" "github_actions" {
  name = "github-actions-deploy-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRoleWithWebIdentity"
      Effect = "Allow"
      Principal = { Federated = aws_iam_openid_connect_provider.github.arn }
      Condition = {
        StringLike = { "token.actions.githubusercontent.com:sub" : "repo:${var.github_repo}:*" }
      }
    }]
  })
}

# Permissions for the Role
resource "aws_iam_role_policy" "deploy_policy" {
  name = "github-actions-deploy-policy"
  role = aws_iam_role.github_actions.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = ["s3:PutObject", "s3:GetObject", "s3:ListBucket", "s3:DeleteObject"]
        Resource = [aws_s3_bucket.website.arn, "${aws_s3_bucket.website.arn}/*"]
      },
      {
        Effect = "Allow"
        Action = ["cloudfront:CreateInvalidation"]
        Resource = [aws_cloudfront_distribution.s3_distribution.arn]
      }
    ]
  })
}

