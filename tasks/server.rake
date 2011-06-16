# -*- ruby -*-

desc "Set up new Chef server"
task :setup_server do
  if File.exists?('.chef/knife.rb') and not ENV['FORCE']
    raise "Knife is already configured. If you know what you're doing, use FORCE=1."
  end

  require 'fog'
  require 'net/ssh'
  require 'net/scp'

  # Start instance using fog
  EC2 = Fog::Compute.new(
    :provider => 'AWS',
    :aws_access_key_id => AWS_ACCESS_KEY_ID,
    :aws_secret_access_key => AWS_SECRET_ACCESS_KEY,
    :region => AWS_REGION
  )

  server_instance_params = {
    :image_id => AWS_AMI,
    :flavor_id => AWS_INSTANCE_TYPE,
    :availability_zone => AWS_ZONE,
    :groups => [ AWS_GROUP, AWS_GROUP_SERVER ],
    :key_pair => EC2.key_pairs.get(AWS_KEY_PAIR)
  }
  raise 'No key pair #{AWS_KEY_PAIR}' unless server_instance_params[:key_pair]

  puts "Starting new EC2 instance"
  server_instance = EC2.servers.create(server_instance_params)
  puts "Started instance #{server_instance.id}"

  print 'Waiting for instance...'
  server_instance.wait_for do
    print '.'
    STDOUT.flush
    ready?
  end
  puts " done."
  puts "Instance is at #{server_instance.dns_name} (#{server_instance.public_ip_address})"

  print 'Waiting for ssh... '
  sleep 20
  begin
    Net::SSH.start( server_instance.dns_name,
                    'root',
                    :keys => [ ".chef/#{AWS_KEY_PAIR}.pem" ] ) do |ssh|
      print <<-EOF
done.
Copying setup.sh
EOF
      ssh.scp.upload! "scripts/setup-server-deb.sh", "setup.sh"

      puts "Running initialisation script"
      ssh.exec! 'sh ./setup.sh' do |ch, stream, data|
        if stream == :stderr
          STDERR.write data
          STDERR.flush
        else
          STDOUT.write data
          STDOUT.flush
        end
      end

      puts "Downloading validation.pem"
      ssh.scp.download! "/etc/chef/validation.pem", "./.chef/validation.pem"
    end
  rescue Errno::ECONNREFUSED
    # Not ready yet
    print '. '
    STDOUT.flush
    sleep 5
  rescue
    raise
  else
    break
  end while true

  puts <<EOF
Please fill knife configuration form by pasting these answers:
  Where should I put the config file?: ./.chef/knife.rb
  clientname: choose one
  existing admin clientname: chef-validator
  admin client's private key: #{Dir.getwd}/.chef/validation.pem
  validation clientname: chef-validator
  location of the validation key: #{Dir.getwd}/.chef/validation.pem
  path to a chef repository: #{Dir.getwd}
EOF
  sh "knife configure -s http://#{server_instance.dns_name}:4000 -i"

  puts "Your chef server is at #{server_instance.dns_name}."
  sh "knife status"
end
