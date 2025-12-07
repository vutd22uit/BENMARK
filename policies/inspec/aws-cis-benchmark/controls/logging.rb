# CIS AWS Foundations Benchmark - Section 2: Logging

# CIS 2.1: Ensure CloudTrail is enabled in all regions
control 'cis-aws-2.1' do
  impact 1.0
  title 'Ensure CloudTrail is enabled in all regions'
  desc 'AWS CloudTrail is a web service that records AWS API calls for your account and delivers log files to you. The recorded information includes the identity of the API caller, the time of the API call, the source IP address of the API caller, the request parameters, and the response elements returned by the AWS service.'
  
  describe aws_cloudtrail_trails do
    it { should exist }
  end
  
  aws_cloudtrail_trails.trail_arns.each do |trail|
    describe aws_cloudtrail_trail(trail) do
      it { should be_multi_region_trail }
      it { should be_logging }
      it { should have_log_file_validation_enabled }
    end
  end
end

# CIS 2.2: Ensure CloudTrail log file validation is enabled
control 'cis-aws-2.2' do
  impact 1.0
  title 'Ensure CloudTrail log file validation is enabled'
  desc 'CloudTrail log file validation creates a digitally signed digest file containing a hash of each log that CloudTrail writes to S3.'
  
  aws_cloudtrail_trails.trail_arns.each do |trail|
    describe aws_cloudtrail_trail(trail) do
      it { should have_log_file_validation_enabled }
    end
  end
end

# CIS 2.3: Ensure the S3 bucket used to store CloudTrail logs is not publicly accessible
control 'cis-aws-2.3' do
  impact 1.0
  title 'Ensure the S3 bucket used to store CloudTrail logs is not publicly accessible'
  desc 'CloudTrail logs a record of every API call made in your AWS account. These logs are stored in an S3 bucket. It is recommended that the bucket policy, or access control list (ACL), applied to the S3 bucket that CloudTrail logs to prevents public access to the CloudTrail logs.'
  
  aws_cloudtrail_trails.trail_arns.each do |trail|
    bucket_name = aws_cloudtrail_trail(trail).s3_bucket_name
    
    describe aws_s3_bucket(bucket_name) do
      it { should_not be_public }
    end
  end
end

# CIS 2.6: Ensure S3 bucket access logging is enabled on the CloudTrail S3 bucket
control 'cis-aws-2.6' do
  impact 1.0
  title 'Ensure S3 bucket access logging is enabled on the CloudTrail S3 bucket'
  desc 'S3 Bucket Access Logging generates a log that contains access records for each request made to your S3 bucket. An access log record contains details about the request, such as the request type, the resources specified in the request worked, and the time and date the request was processed.'
  
  aws_cloudtrail_trails.trail_arns.each do |trail|
    bucket_name = aws_cloudtrail_trail(trail).s3_bucket_name
    
    describe aws_s3_bucket(bucket_name) do
      it { should have_access_logging_enabled }
    end
  end
end

# CIS 2.7: Ensure CloudTrail logs are encrypted at rest using KMS CMKs
control 'cis-aws-2.7' do
  impact 1.0
  title 'Ensure CloudTrail logs are encrypted at rest using KMS CMKs'
  desc 'AWS CloudTrail is a web service that records AWS API calls made in a given AWS account. The recorded information includes the identity of the API caller, the time of the API call, the source IP address of the API caller, the request parameters, and the response elements returned by the AWS service. CloudTrail uses Amazon S3 for log file storage and delivery, so log files are stored durably. In addition to capturing CloudTrail logs within a specified S3 bucket for long term analysis, realtime analysis can be performed by configuring CloudTrail to send logs to CloudWatch Logs. For a trail that is enabled in all regions in an account, CloudTrail sends log files from all those regions to a CloudWatch Logs log group. It is recommended that CloudTrail logs be encrypted at rest.'
  
  aws_cloudtrail_trails.trail_arns.each do |trail|
    describe aws_cloudtrail_trail(trail) do
      it { should be_encrypted }
    end
  end
end
