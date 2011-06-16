# Append all or some of these to your .chef/knife.rb

knife[:aws_access_key_id] = ""
knife[:aws_secret_access_key] = ""
knife[:aws_ssh_key_id] = ""
knife[:region] = "eu-west-1"
knife[:availability_zone] = "eu-west-1b"
knife[:flavor] = 'm1.small'
knife[:image] = 'ami-17447363'  # 32-bit Debian Squeeze in EU region

# Load the patch for sudo (useful with images with root login)
::Kernel::load(
  ::File.join(
    ::File.dirname(__FILE__),
    '..', 'config', 'knife_nosudo.rb'))
