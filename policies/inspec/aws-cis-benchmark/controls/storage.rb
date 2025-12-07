# CIS AWS Foundations Benchmark - Section 2: Storage (S3)

# CIS 2.1.1: Ensure all S3 buckets employ encryption-at-rest
control 'cis-aws-2.1.1' do
  impact 1.0
  title 'Ensure all S3 buckets employ encryption-at-rest'
  desc 'Amazon S3 provides a variety of no, or low, cost encryption options to protect data at rest.'
  
  aws_s3_buckets.bucket_names.each do |bucket|
    describe aws_s3_bucket(bucket) do
      it { should have_default_encryption_enabled }
    end
  end
end

# CIS 2.1.2: Ensure S3 Bucket Policy is set to deny HTTP requests
control 'cis-aws-2.1.2' do
  impact 1.0
  title 'Ensure S3 Bucket Policy is set to deny HTTP requests'
  desc 'At the Amazon S3 bucket level, you can configure permissions through a bucket policy making the objects accessible only through HTTPS.'
  
  aws_s3_buckets.bucket_names.each do |bucket|
    next unless aws_s3_bucket(bucket).has_bucket_policy?
    
    policy = aws_s3_bucket(bucket).bucket_policy
    
    # Check if policy denies non-HTTPS requests
    describe "S3 bucket #{bucket} policy" do
      subject { policy }
      it 'should deny HTTP requests' do
        # This is a simplified check - in production, parse the policy JSON
        expect(subject.to_s).to match(/aws:SecureTransport.*false/i).or match(/Deny.*HTTP/i)
      end
    end
  end
end

# CIS 2.2.1: Ensure S3 buckets are not publicly accessible
control 'cis-aws-2.2.1' do
  impact 1.0
  title 'Ensure S3 buckets are not publicly accessible'
  desc 'Amazon S3 allows customers to store or retrieve any type of content from anywhere in the web. Often, customers have legitimate reasons to expose the S3 bucket to the public, for example, to host website content. However, these buckets often contain highly sensitive enterprise data which if left accessible to the public may result in sensitive data leaks.'
  
  aws_s3_buckets.bucket_names.each do |bucket|
    describe aws_s3_bucket(bucket) do
      it { should_not be_public }
    end
  end
end

# CIS 2.3.1: Ensure S3 bucket access logging is enabled
control 'cis-aws-2.3.1' do
  impact 1.0
  title 'Ensure S3 bucket access logging is enabled'
  desc 'S3 Bucket Access Logging generates a log that contains access records for each request made to your S3 bucket. An access log record contains details about the request, such as the request type, the resources specified in the request, and the time and date the request was processed. It is recommended that bucket access logging be enabled on the CloudTrail S3 bucket.'
  
  aws_s3_buckets.bucket_names.each do |bucket|
    describe aws_s3_bucket(bucket) do
      it { should have_access_logging_enabled }
    end
  end
end

# CIS 2.4.1: Ensure S3 bucket versioning is enabled
control 'cis-aws-2.4.1' do
  impact 0.5
  title 'Ensure S3 bucket versioning is enabled'
  desc 'Versioning is a means of keeping multiple variants of an object in the same bucket. Versioning-enabled buckets enable you to recover objects from accidental deletion or overwrite.'
  
  aws_s3_buckets.bucket_names.each do |bucket|
    describe aws_s3_bucket(bucket) do
      it { should have_versioning_enabled }
    end
  end
end
