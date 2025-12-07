# CIS 2.2: Ensure S3 buckets are not public
# CIS 2.6: Ensure S3 bucket access logging is enabled

# COMPLIANT S3 Bucket
resource "aws_s3_bucket" "compliant_bucket" {
  bucket = "${var.project_name}-compliant-${var.environment}"

  tags = {
    Name        = "Compliant S3 Bucket"
    CIS_Control = "2.2, 2.6"
  }
}

resource "aws_s3_bucket_public_access_block" "compliant_bucket" {
  bucket = aws_s3_bucket.compliant_bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_versioning" "compliant_bucket" {
  bucket = aws_s3_bucket.compliant_bucket.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "compliant_bucket" {
  bucket = aws_s3_bucket.compliant_bucket.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# Logging bucket for access logs
resource "aws_s3_bucket" "logging_bucket" {
  bucket = "${var.project_name}-logs-${var.environment}"

  tags = {
    Name = "S3 Access Logs Bucket"
  }
}

resource "aws_s3_bucket_public_access_block" "logging_bucket" {
  bucket = aws_s3_bucket.logging_bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_logging" "compliant_bucket" {
  bucket = aws_s3_bucket.compliant_bucket.id

  target_bucket = aws_s3_bucket.logging_bucket.id
  target_prefix = "s3-access-logs/"
}

# NON-COMPLIANT S3 Bucket (for testing detection)
# Uncomment to test Checkov/OPA blocking
# resource "aws_s3_bucket" "non_compliant_bucket" {
#   bucket = "${var.project_name}-public-${var.environment}"
#   acl    = "public-read"  # CIS 2.2 VIOLATION
#
#   tags = {
#     Name        = "Non-Compliant S3 Bucket"
#     CIS_Control = "VIOLATION"
#   }
# }
