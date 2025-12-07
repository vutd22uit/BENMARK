# CIS AWS Foundations Benchmark - Section 1: Identity and Access Management

# CIS 1.1: Avoid the use of the "root" account
control 'cis-aws-1.1' do
  impact 1.0
  title 'Avoid the use of the "root" account'
  desc 'The "root" account has unrestricted access to all resources in the AWS account. It is highly recommended that the use of this account be avoided.'
  
  describe aws_iam_root_user do
    it { should_not have_access_key }
  end
end

# CIS 1.4: Ensure access keys are rotated every 90 days or less
control 'cis-aws-1.4' do
  impact 1.0
  title 'Ensure access keys are rotated every 90 days or less'
  desc 'Access keys consist of an access key ID and secret access key, which are used to sign programmatic requests that you make to AWS. AWS users need their own access keys to make programmatic calls to AWS from the AWS Command Line Interface (AWS CLI), Tools for Windows PowerShell, the AWS SDKs, or direct HTTP calls using the APIs for individual AWS services.'
  
  aws_iam_users.where(has_console_password: false).entries.each do |user|
    user.access_keys.entries.each do |key|
      describe key do
        its('created_days_ago') { should cmp <= 90 }
      end
    end
  end
end

# CIS 1.5: Ensure IAM password policy requires at least one uppercase letter
control 'cis-aws-1.5' do
  impact 1.0
  title 'Ensure IAM password policy requires at least one uppercase letter'
  desc 'Password policies are, in part, used to enforce password complexity requirements. IAM password policies can be used to ensure password are comprised of different character sets.'
  
  describe aws_iam_password_policy do
    it { should require_uppercase_characters }
  end
end

# CIS 1.6: Ensure IAM password policy requires at least one lowercase letter
control 'cis-aws-1.6' do
  impact 1.0
  title 'Ensure IAM password policy requires at least one lowercase letter'
  desc 'Password policies are, in part, used to enforce password complexity requirements.'
  
  describe aws_iam_password_policy do
    it { should require_lowercase_characters }
  end
end

# CIS 1.7: Ensure IAM password policy requires at least one symbol
control 'cis-aws-1.7' do
  impact 1.0
  title 'Ensure IAM password policy requires at least one symbol'
  desc 'Password policies are, in part, used to enforce password complexity requirements.'
  
  describe aws_iam_password_policy do
    it { should require_symbols }
  end
end

# CIS 1.8: Ensure IAM password policy requires at least one number
control 'cis-aws-1.8' do
  impact 1.0
  title 'Ensure IAM password policy requires at least one number'
  desc 'Password policies are, in part, used to enforce password complexity requirements.'
  
  describe aws_iam_password_policy do
    it { should require_numbers }
  end
end

# CIS 1.9: Ensure IAM password policy requires minimum length of 14 or greater
control 'cis-aws-1.9' do
  impact 1.0
  title 'Ensure IAM password policy requires minimum length of 14 or greater'
  desc 'Password policies are, in part, used to enforce password complexity requirements.'
  
  describe aws_iam_password_policy do
    its('minimum_password_length') { should be >= 14 }
  end
end

# CIS 1.10: Ensure IAM password policy prevents password reuse
control 'cis-aws-1.10' do
  impact 1.0
  title 'Ensure IAM password policy prevents password reuse'
  desc 'IAM password policies can prevent the reuse of a given password by the same user.'
  
  describe aws_iam_password_policy do
    its('number_of_passwords_to_remember') { should be >= 24 }
  end
end

# CIS 1.11: Ensure IAM password policy expires passwords within 90 days or less
control 'cis-aws-1.11' do
  impact 1.0
  title 'Ensure IAM password policy expires passwords within 90 days or less'
  desc 'IAM password policies can require passwords to be rotated or expired after a given number of days.'
  
  describe aws_iam_password_policy do
    its('max_password_age_in_days') { should be <= 90 }
  end
end
