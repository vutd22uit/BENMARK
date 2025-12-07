# CIS Linux Benchmark - Section 5.2: SSH Server Configuration

# CIS 5.2.1: Ensure SSH LogLevel is appropriate
control 'cis-linux-5.2.1' do
  impact 1.0
  title 'Ensure SSH LogLevel is INFO or VERBOSE'
  desc 'The INFO parameter specifies that login and logout activity will be logged. SSH provides the ability to log activity at various levels. It is recommended that the LogLevel be set to INFO or VERBOSE.'
  
  describe sshd_config do
    its('LogLevel') { should match(/INFO|VERBOSE/i) }
  end
end

# CIS 5.2.2: Ensure SSH X11 forwarding is disabled
control 'cis-linux-5.2.2' do
  impact 1.0
  title 'Ensure SSH X11 forwarding is disabled'
  desc 'The X11Forwarding parameter provides the ability to tunnel X11 traffic through the connection to enable remote graphic connections. SSH X11 forwarding should be disabled unless there is an operational requirement to use X11 applications directly.'
  
  describe sshd_config do
    its('X11Forwarding') { should eq 'no' }
  end
end

# CIS 5.2.3: Ensure SSH MaxAuthTries is set to 4 or less
control 'cis-linux-5.2.3' do
  impact 1.0
  title 'Ensure SSH MaxAuthTries is set to 4 or less'
  desc 'The MaxAuthTries parameter specifies the maximum number of authentication attempts permitted per connection. When the login failure count reaches half the number, error messages will be written to the syslog file detailing the login failure.'
  
  describe sshd_config do
    its('MaxAuthTries') { should cmp <= 4 }
  end
end

# CIS 5.2.4: Ensure SSH IgnoreRhosts is enabled
control 'cis-linux-5.2.4' do
  impact 1.0
  title 'Ensure SSH IgnoreRhosts is enabled'
  desc 'The IgnoreRhosts parameter specifies that .rhosts and .shosts files will not be used in RhostsRSAAuthentication or HostbasedAuthentication.'
  
  describe sshd_config do
    its('IgnoreRhosts') { should eq 'yes' }
  end
end

# CIS 5.2.5: Ensure SSH HostbasedAuthentication is disabled
control 'cis-linux-5.2.5' do
  impact 1.0
  title 'Ensure SSH HostbasedAuthentication is disabled'
  desc 'The HostbasedAuthentication parameter specifies if authentication is allowed through trusted hosts via the user of .rhosts, or /etc/hosts.equiv, along with successful public key client host authentication. This option only applies to SSH Protocol Version 2.'
  
  describe sshd_config do
    its('HostbasedAuthentication') { should eq 'no' }
  end
end

# CIS 5.2.6: Ensure SSH root login is disabled
control 'cis-linux-5.2.6' do
  impact 1.0
  title 'Ensure SSH root login is disabled'
  desc 'The PermitRootLogin parameter specifies if the root user can log in using ssh. The default is no.'
  
  describe sshd_config do
    its('PermitRootLogin') { should eq 'no' }
  end
end

# CIS 5.2.7: Ensure SSH PermitEmptyPasswords is disabled
control 'cis-linux-5.2.7' do
  impact 1.0
  title 'Ensure SSH PermitEmptyPasswords is disabled'
  desc 'The PermitEmptyPasswords parameter specifies if the SSH server allows login to accounts with empty password strings.'
  
  describe sshd_config do
    its('PermitEmptyPasswords') { should eq 'no' }
  end
end

# CIS 5.2.8: Ensure SSH PermitUserEnvironment is disabled
control 'cis-linux-5.2.8' do
  impact 1.0
  title 'Ensure SSH PermitUserEnvironment is disabled'
  desc 'The PermitUserEnvironment option allows users to present environment options to the ssh daemon.'
  
  describe sshd_config do
    its('PermitUserEnvironment') { should eq 'no' }
  end
end

# CIS 5.2.9: Ensure only strong ciphers are used
control 'cis-linux-5.2.9' do
  impact 1.0
  title 'Ensure only strong ciphers are used'
  desc 'This variable limits the ciphers that SSH can use during communication.'
  
  weak_ciphers = [
    '3des-cbc',
    'aes128-cbc',
    'aes192-cbc',
    'aes256-cbc',
    'arcfour',
    'arcfour128',
    'arcfour256',
    'blowfish-cbc',
    'cast128-cbc',
    'rijndael-cbc@lysator.liu.se'
  ]
  
  describe sshd_config do
    its('Ciphers') { should_not be_nil }
  end
  
  if sshd_config.Ciphers
    weak_ciphers.each do |cipher|
      describe sshd_config do
        its('Ciphers') { should_not include cipher }
      end
    end
  end
end

# CIS 5.2.10: Ensure only strong MAC algorithms are used
control 'cis-linux-5.2.10' do
  impact 1.0
  title 'Ensure only strong MAC algorithms are used'
  desc 'This variable limits the types of MAC algorithms that SSH can use during communication.'
  
  weak_macs = [
    'hmac-md5',
    'hmac-md5-96',
    'hmac-ripemd160',
    'hmac-sha1',
    'hmac-sha1-96',
    'umac-64@openssh.com',
    'hmac-md5-etm@openssh.com',
    'hmac-md5-96-etm@openssh.com',
    'hmac-ripemd160-etm@openssh.com',
    'hmac-sha1-etm@openssh.com',
    'hmac-sha1-96-etm@openssh.com',
    'umac-64-etm@openssh.com'
  ]
  
  describe sshd_config do
    its('MACs') { should_not be_nil }
  end
  
  if sshd_config.MACs
    weak_macs.each do |mac|
      describe sshd_config do
        its('MACs') { should_not include mac }
      end
    end
  end
end

# CIS 5.2.11: Ensure SSH Idle Timeout Interval is configured
control 'cis-linux-5.2.11' do
  impact 1.0
  title 'Ensure SSH Idle Timeout Interval is configured'
  desc 'The two options ClientAliveInterval and ClientAliveCountMax control the timeout of ssh sessions.'
  
  describe sshd_config do
    its('ClientAliveInterval') { should cmp <= 300 }
    its('ClientAliveInterval') { should cmp > 0 }
    its('ClientAliveCountMax') { should cmp <= 3 }
  end
end

# CIS 5.2.12: Ensure SSH LoginGraceTime is set to one minute or less
control 'cis-linux-5.2.12' do
  impact 1.0
  title 'Ensure SSH LoginGraceTime is set to one minute or less'
  desc 'The LoginGraceTime parameter specifies the time allowed for successful authentication to the SSH server.'
  
  describe sshd_config do
    its('LoginGraceTime') { should cmp <= 60 }
  end
end

# CIS 5.2.13: Ensure SSH access is limited
control 'cis-linux-5.2.13' do
  impact 1.0
  title 'Ensure SSH access is limited'
  desc 'There are several options available to limit which users and group can access the system via SSH. It is recommended that at least one of the following options be leveraged: AllowUsers, AllowGroups, DenyUsers, DenyGroups.'
  
  describe.one do
    describe sshd_config do
      its('AllowUsers') { should_not be_nil }
    end
    describe sshd_config do
      its('AllowGroups') { should_not be_nil }
    end
    describe sshd_config do
      its('DenyUsers') { should_not be_nil }
    end
    describe sshd_config do
      its('DenyGroups') { should_not be_nil }
    end
  end
end

# CIS 5.2.14: Ensure SSH warning banner is configured
control 'cis-linux-5.2.14' do
  impact 1.0
  title 'Ensure SSH warning banner is configured'
  desc 'The Banner parameter specifies a file whose contents must be sent to the remote user before authentication is permitted.'
  
  describe sshd_config do
    its('Banner') { should_not be_nil }
    its('Banner') { should_not eq 'none' }
  end
end
