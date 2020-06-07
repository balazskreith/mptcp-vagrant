# -*- mode: ruby -*-
# vi: set ft=ruby :

ENV['VAGRANT_DEFAULT_PROVIDER'] = 'virtualbox'

# Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  config.vm.define "source" do |source|
    source.vm.box = "hoangtran/mptcp-iperf"
    source.vm.hostname = "mptcpbox-source"

    source.ssh.insert_key = false
    source.vbguest.auto_update = false

    source.vm.network "private_network", ip: "192.168.53.10", virtualbox__intnet: "net-1"
    source.vm.network "private_network", ip: "192.168.54.10", virtualbox__intnet: "net-1"

    source.vm.synced_folder '.', '/vagrant', disabled: true
    source.vm.synced_folder './shared', '/shared', disabled: false

    source.vm.provider "virtualbox" do |vb|
      vb.customize ['modifyvm', :id, '--natdnsproxy1', 'on'] 

      vb.customize ["modifyvm", :id, "--nictype1", "Am79C973"]
      vb.customize ["modifyvm", :id, "--nictype2", "Am79C973"]
      vb.customize ["modifyvm", :id, "--nictype3", "Am79C973"]
      vb.customize ["modifyvm", :id, "--nictype4", "Am79C973"]
      vb.customize ["modifyvm", :id, "--nicpromisc2", "allow-all"]
      vb.customize ["modifyvm", :id, "--nicpromisc3", "allow-all"]
      
      # For scenario 3 we need to turn it on
      # vb.customize ["bandwidthctl", :id, "add", "Limit1", "--type", "network", "--limit", "1m"]
      # vb.customize ["modifyvm", :id, "--nicbandwidthgroup2", "Limit1"]
      # vb.customize ["bandwidthctl", :id, "add", "Limit2", "--type", "network", "--limit", "1m"]
      # vb.customize ["modifyvm", :id, "--nicbandwidthgroup3", "Limit1"]
      # vb.customize ["bandwidthctl", :id, "add", "Limit3", "--type", "network", "--limit", "1m"]
      # vb.customize ["modifyvm", :id, "--nicbandwidthgroup4", "Limit1"]
    
    end
    
    source.trigger.after :up do |trigger|
        trigger.run = {path: "./scripts/source/post_up.sh"}
    end
    source.trigger.after :halt do |trigger|
      trigger.run = {path: "./scripts/source/post_halt.sh"}
    end
    
    source.vm.provision "shell", path: "scripts/source/provision.sh", run: "always"
  end


  config.vm.define "sink" do |sink|
    sink.vm.box = "hoangtran/mptcp-iperf"
    sink.vm.hostname = "mptcpbox-sink"

    sink.ssh.insert_key = false
    sink.vbguest.auto_update = false

    sink.vm.network "private_network", ip: "192.168.53.100", virtualbox__intnet: "net-1"
    sink.vm.network "private_network", ip: "192.168.54.100", virtualbox__intnet: "net-1"

    sink.vm.synced_folder '.', '/vagrant', disabled: true
    sink.vm.synced_folder './shared', '/shared', disabled: false

    sink.vm.provider "virtualbox" do |vb|
      vb.customize ['modifyvm', :id, '--natdnsproxy1', 'on'] 

      vb.customize ["modifyvm", :id, "--nictype1", "Am79C973"]
      vb.customize ["modifyvm", :id, "--nictype2", "Am79C973"]
      vb.customize ["modifyvm", :id, "--nictype3", "Am79C973"]
      vb.customize ["modifyvm", :id, "--nictype4", "Am79C973"]
    end
    
    sink.trigger.after :up do |trigger|
        trigger.run = {path: "./scripts/sink/post_up.sh"}
    end
    sink.trigger.after :halt do |trigger|
      trigger.run = {path: "./scripts/sink/post_halt.sh"}
    end
    
    sink.vm.provision "shell", path: "scripts/sink/provision.sh", run: "always"
  end
  config.vm.post_up_message = %{
  #######################################################################
    vagrant ssh
    curl www.multipath-tcp.org
   #######################################################################
  }   
  
end
