# -*- mode: ruby -*-
# vi: set ft=ruby :

required_plugins = %w(vagrant-triggers)

plugins_to_install = required_plugins.select { |plugin| not Vagrant.has_plugin? plugin }
if not plugins_to_install.empty?
  puts "Installing plugins: #{plugins_to_install.join(' ')}"
  if system "vagrant plugin install #{plugins_to_install.join(' ')}"
    exec "vagrant #{ARGV.join(' ')}"
  else
    abort "Installation of one or more plugins has failed. Aborting."
  end
end

ENV['VAGRANT_DEFAULT_PROVIDER'] = 'virtualbox'

# Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  # All Vagrant configuration is done here. The most common configuration
  # options are documented and commented below. For a complete reference,
  # please see the online documentation at vagrantup.com.

  # Every Vagrant virtual environment requires a box to build off of.
  config.vm.box = "hoangtran/mptcp-iperf"
  # config.vm.box_version = '0.0.2'

  config.vm.hostname = "mptcpbox"

  config.ssh.insert_key = false
  # config.ssh.username = "vagrant"
  # config.ssh.password = "vagrant"
  # Disable automatic box update checking. If you disable this, then
  # boxes will only be checked for updates when the user runs
  # `vagrant box outdated`. This is not recommended.
  # config.vm.box_check_update = false
  config.vbguest.auto_update = false

  # Create a forwarded port mapping which allows access to a specific port
  # within the machine from a port on the host machine. In the example below,
  # accessing "localhost:8080" will access port 80 on the guest machine.
  # config.vm.network "forwarded_port", guest: 80, host: 8080

  # Create a private network, which allows host-only access to the machine
  # using a specific IP.
  # vm's eth1
  config.vm.network "private_network", ip: "192.168.33.10"
  # manual config IPv6 on the same interface with "192.168.33.10"
  config.vm.provision "shell", inline: "ip address add fde4:8dba:82e1::c4/64 dev eth1"
  # vm's eth2
  config.vm.network "private_network", ip: "192.168.34.10"
  ## below config would trigger a bug in Virtualbox
  ## causes Vagrant to crash (www.virtualbox.org/ticket/14855)
  # config.vm.network "private_network", ip: "fde4:8dba:82e1::c4"

  # Create a public network, which generally matched to bridged network.
  # Bridged networks make the machine appear as another physical device on
  # your network.
  # config.vm.network "public_network"

  # If true, then any SSH connections made will enable agent forwarding.
  # Default value: false
  # config.ssh.forward_agent = true

  # Share an additional folder to the guest VM. The first argument is
  # the path on the host to the actual folder. The second argument is
  # the path on the guest to mount the folder. And the optional third
  # argument is a set of non-required options.

  # Disable default shared folder and create our shared folder (rsync type)
  # do not use vbox shared folder so we can update kernel without loosing functionality
  config.vm.synced_folder '.', '/vagrant', disabled: true
  config.vm.synced_folder './sent_to_guest', '/sent_from_host', disabled: false

  # Provider-specific configuration so you can fine-tune various
  # backing providers for Vagrant. These expose provider-specific options.
  # Example for VirtualBox:
  #
   config.vm.provider "virtualbox" do |vb|
    vb.customize ['modifyvm', :id, '--natdnsproxy1', 'on'] 

    # fix boot hanging issue of (Ubuntu 14.04 + default Intel NIC)
    # by changing type of VM's NICs to AMD
    vb.customize ["modifyvm", :id, "--nictype1", "Am79C973"]
    vb.customize ["modifyvm", :id, "--nictype2", "Am79C973"]
    vb.customize ["modifyvm", :id, "--nictype3", "Am79C973"]
    vb.customize ["modifyvm", :id, "--nictype4", "Am79C973"]
  #   # Don't boot with headless mode
  #   vb.gui = true
  #
  #   # Use VBoxManage to customize the VM. For example to change memory:
  #   vb.customize ["modifyvm", :id, "--memory", "1024"]
  #   vb.customize ["modifyvm", :id, "--nictype1", "virtio"]
   end
  #
  # View the documentation for the provider you're using for more
  # information on available options.

  # Enable provisioning with CFEngine. CFEngine Community packages are
  # automatically installed. For example, configure the host as a
  # policy server and optionally a policy file to run:
  #
  # config.vm.provision "cfengine" do |cf|
  #   cf.am_policy_hub = true
  #   # cf.run_file = "motd.cf"
  # end
  #
  # You can also configure and bootstrap a client to an existing
  # policy server:
  #
  # config.vm.provision "cfengine" do |cf|
  #   cf.policy_server_address = "10.0.2.15"
  # end

  # Enable provisioning with Puppet stand alone.  Puppet manifests
  # are contained in a directory path relative to this Vagrantfile.
  # You will need to create the manifests directory and a manifest in
  # the file default.pp in the manifests_path directory.
  #
  # config.vm.provision "puppet" do |puppet|
  #   puppet.manifests_path = "manifests"
  #   puppet.manifest_file  = "default.pp"
  # end

  # Enable provisioning with chef solo, specifying a cookbooks path, roles
  # path, and data_bags path (all relative to this Vagrantfile), and adding
  # some recipes and/or roles.
  #
  # config.vm.provision "chef_solo" do |chef|
  #   chef.cookbooks_path = "../my-recipes/cookbooks"
  #   chef.roles_path = "../my-recipes/roles"
  #   chef.data_bags_path = "../my-recipes/data_bags"
  #   chef.add_recipe "mysql"
  #   chef.add_role "web"
  #
  #   # You may also specify custom JSON attributes:
  #   chef.json = { mysql_password: "foo" }
  # end

  # Enable provisioning with chef server, specifying the chef server URL,
  # and the path to the validation key (relative to this Vagrantfile).
  #
  # The Opscode Platform uses HTTPS. Substitute your organization for
  # ORGNAME in the URL and validation key.
  #
  # If you have your own Chef Server, use the appropriate URL, which may be
  # HTTP instead of HTTPS depending on your configuration. Also change the
  # validation key to validation.pem.
  #
  # config.vm.provision "chef_client" do |chef|
  #   chef.chef_server_url = "https://api.opscode.com/organizations/ORGNAME"
  #   chef.validation_key_path = "ORGNAME-validator.pem"
  # end
  #
  # If you're using the Opscode platform, your validator client is
  # ORGNAME-validator, replacing ORGNAME with your organization name.
  #
  # If you have your own Chef Server, the default validation client name is
  # chef-validator, unless you changed the configuration.
  #
  #   chef.validation_client_name = "ORGNAME-validator"
  config.vm.provision "shell", path: "scripts/provision.sh", run: "always"
  # update client test scripts as non-sudo user
  #config.vm.provision "shell", path: "scripts/update_iperf_test_scripts.sh", run: "always", privileged: false

  config.vm.post_up_message = %{
  #######################################################################

  Things should be set up for you to test MPTCP from the virtual machine.
  To log in, just issue the command
    vagrant ssh

  To validate that MPTCP is working from inside the vm, issue
    curl www.multipath-tcp.org

  You should get a joyful message announcing you are using MPTCP.

  To confirm that the second interface NAT or IPv6 NAT works correctly,
  you can run the pingtest
    ./pingtest

  To run the iperf test to our server:
    ./run_all_tests

  To capture packet trace, you can add argument: "./run_all_tests capture"

   #######################################################################
}   

  config.trigger.after :up do
    run "./scripts/post_up.sh"
  end
  config.trigger.after :halt do
    run "./scripts/post_halt.sh"
  end
end
