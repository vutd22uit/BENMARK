output "s3_bucket_names" {
  description = "Names of created S3 buckets"
  value = {
    compliant_bucket  = aws_s3_bucket.compliant_bucket.id
    logging_bucket    = aws_s3_bucket.logging_bucket.id
    cloudtrail_bucket = aws_s3_bucket.cloudtrail_bucket.id
  }
}

output "cloudtrail_arn" {
  description = "ARN of the CloudTrail"
  value       = aws_cloudtrail.main.arn
}

output "cloudtrail_kms_key_id" {
  description = "KMS key ID used for CloudTrail encryption"
  value       = aws_kms_key.cloudtrail.key_id
}

output "security_group_ids" {
  description = "IDs of created security groups"
  value = {
    compliant_ssh   = aws_security_group.compliant_ssh.id
    compliant_https = aws_security_group.compliant_https.id
  }
}

output "compliance_summary" {
  description = "Summary of CIS controls implemented"
  value = {
    cis_2_1_1 = "CloudTrail enabled in all regions with encryption"
    cis_2_2   = "S3 buckets have public access blocked"
    cis_2_6   = "S3 buckets have access logging enabled"
    cis_4_1   = "Security groups do not allow SSH from 0.0.0.0/0"
  }
}
