variable "aws_region" {
  description = "Region for S3 bucket"
  default     = "ap-south-1" #  Change this to your desired region if not Mumbai
}

variable "domain_name" {
  description = "Your website domain name" # e.g. ayushukla.com
  type        = string
}

variable "bucket_name" {
  description = "S3 bucket name for website" # e.g. ayushukla.com
  type        = string
}

variable "github_repo" {
  description = "GitHub repo in format User/Repo" # e.g. ayushukla02/staticwebsite-hosting-infra-aws
  type        = string
}