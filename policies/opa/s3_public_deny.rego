# CIS 2.2: Ensure S3 buckets are not public
# This policy denies S3 buckets with public ACLs or missing public access blocks

package terraform.s3

import future.keywords.contains
import future.keywords.if

# Deny S3 buckets with public-read or public-read-write ACL
deny[msg] {
    resource := input.resource_changes[_]
    resource.type == "aws_s3_bucket"
    resource.change.after.acl
    public_acl := resource.change.after.acl
    public_acl == "public-read"
    
    msg := sprintf(
        "CIS 2.2 VIOLATION: S3 bucket '%s' has public-read ACL. This violates CIS AWS Foundations Benchmark.",
        [resource.address]
    )
}

deny[msg] {
    resource := input.resource_changes[_]
    resource.type == "aws_s3_bucket"
    resource.change.after.acl
    public_acl := resource.change.after.acl
    public_acl == "public-read-write"
    
    msg := sprintf(
        "CIS 2.2 VIOLATION: S3 bucket '%s' has public-read-write ACL. This violates CIS AWS Foundations Benchmark.",
        [resource.address]
    )
}

# Deny S3 buckets without public access block
deny[msg] {
    bucket := input.resource_changes[_]
    bucket.type == "aws_s3_bucket"
    bucket_name := bucket.change.after.bucket
    
    # Check if there's a corresponding public access block
    not has_public_access_block(bucket_name)
    
    msg := sprintf(
        "CIS 2.2 VIOLATION: S3 bucket '%s' does not have a public access block configured. All S3 buckets must have public access blocked.",
        [bucket.address]
    )
}

# Helper function to check if bucket has public access block
has_public_access_block(bucket_name) {
    block := input.resource_changes[_]
    block.type == "aws_s3_bucket_public_access_block"
    block.change.after.bucket == bucket_name
    block.change.after.block_public_acls == true
    block.change.after.block_public_policy == true
    block.change.after.ignore_public_acls == true
    block.change.after.restrict_public_buckets == true
}

# Warn if S3 bucket doesn't have encryption
warn[msg] {
    bucket := input.resource_changes[_]
    bucket.type == "aws_s3_bucket"
    bucket_name := bucket.change.after.bucket
    
    not has_encryption(bucket_name)
    
    msg := sprintf(
        "CIS 2.1 WARNING: S3 bucket '%s' does not have server-side encryption configured.",
        [bucket.address]
    )
}

has_encryption(bucket_name) {
    encryption := input.resource_changes[_]
    encryption.type == "aws_s3_bucket_server_side_encryption_configuration"
    encryption.change.after.bucket == bucket_name
}
