# Load this file from knife.rb to work around knife-ec2#7
# http://tickets.opscode.com/browse/KNIFE_EC2-7
class Chef
  class Knife
    class Ec2ServerCreate
      alias _original_bootstrap_for_node bootstrap_for_node
      def bootstrap_for_node(server)
        bootstrap = _original_bootstrap_for_node(server)
        bootstrap.config[:use_sudo] = false
        bootstrap
      end
    end
  end
end
