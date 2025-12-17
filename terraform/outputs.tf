
output "github_role_arn" {
  value = aws_iam_role.github_actions.arn
}
output "cloudfront_distribution_id" {
  value = aws_cloudfront_distribution.s3_distribution.id
}
output "cloudfront_distribution_domain_name" {
  value = aws_cloudfront_distribution.s3_distribution.domain_name
}

output "s3_bucket_name" {
  value = aws_s3_bucket.website.id
}