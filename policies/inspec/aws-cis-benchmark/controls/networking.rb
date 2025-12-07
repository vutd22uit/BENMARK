# CIS AWS Foundations Benchmark - Section 4: Networking

# CIS 4.1: Ensure no security groups allow ingress from 0.0.0.0/0 to port 22
control 'cis-aws-4.1' do
  impact 1.0
  title 'Ensure no security groups allow ingress from 0.0.0.0/0 to port 22'
  desc 'Security groups provide stateful filtering of ingress/egress network traffic to AWS resources. It is recommended that no security group allows unrestricted ingress access to port 22.'
  
  aws_security_groups.group_ids.each do |group_id|
    describe aws_security_group(group_id) do
      it { should_not allow_in(port: 22, ipv4_range: '0.0.0.0/0') }
      it { should_not allow_in(port: 22, ipv6_range: '::/0') }
    end
  end
end

# CIS 4.2: Ensure no security groups allow ingress from 0.0.0.0/0 to port 3389
control 'cis-aws-4.2' do
  impact 1.0
  title 'Ensure no security groups allow ingress from 0.0.0.0/0 to port 3389'
  desc 'Security groups provide stateful filtering of ingress/egress network traffic to AWS resources. It is recommended that no security group allows unrestricted ingress access to port 3389.'
  
  aws_security_groups.group_ids.each do |group_id|
    describe aws_security_group(group_id) do
      it { should_not allow_in(port: 3389, ipv4_range: '0.0.0.0/0') }
      it { should_not allow_in(port: 3389, ipv6_range: '::/0') }
    end
  end
end

# CIS 4.3: Ensure the default security group of every VPC restricts all traffic
control 'cis-aws-4.3' do
  impact 1.0
  title 'Ensure the default security group of every VPC restricts all traffic'
  desc 'A VPC comes with a default security group whose initial settings deny all inbound traffic, allow all outbound traffic, and allow all traffic between instances assigned to the security group. If you do not specify a security group when you launch an instance, the instance is automatically assigned to this default security group. Security groups provide stateful filtering of ingress/egress network traffic to AWS resources. It is recommended that the default security group restrict all traffic.'
  
  aws_vpcs.vpc_ids.each do |vpc_id|
    describe aws_security_group(group_name: 'default', vpc_id: vpc_id) do
      its('inbound_rules.count') { should eq 0 }
      its('outbound_rules.count') { should eq 0 }
    end
  end
end

# CIS 4.4: Ensure routing tables for VPC peering are "least access"
control 'cis-aws-4.4' do
  impact 0.5
  title 'Ensure routing tables for VPC peering are "least access"'
  desc 'Once a VPC peering connection is established, routing tables must be updated to establish any connections between the peered VPCs. These routes can be as specific as desired - even peering a VPC to only a single host on the other side of the connection.'
  
  # This is a manual check in most cases, but we can verify route tables exist
  aws_vpcs.vpc_ids.each do |vpc_id|
    describe aws_route_tables.where(vpc_id: vpc_id) do
      it { should exist }
    end
  end
end
