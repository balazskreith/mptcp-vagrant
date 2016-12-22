About
=====
This repo contains vagrant configurations to help you test Multipath TCP with multiple host interfaces.

The setup enables you to test MPTCP from the virtual machine without requiring MPTCP 
support from the host.

The box is downloaded from https://atlas.hashicorp.com/hoangtran/boxes/mptcp-iperf/, containing:
- multipath TCP version 0.91
- MPTCP socket API
- tweaked iperf3 for multipath TCP


Requirements
============
You need a recent vagrant installed and virtualbox. Get it at http://www.vagrantup.com/downloads.html
and https://www.virtualbox.org/wiki/Downloads

The plugin  vagrant-trigger is also required (see below for installing it).

You also need to have root access via sudo so the script can add NAT rules.
Currently Linux and Mac OS X hosts are supported.

Using it
========

Get it and use it:

    git clone https://github.com/hoang-tranviet/mptcp-vagrant.git
    cd mptcp-vagrant
    # only the first time:
    vagrant plugin install vagrant-triggers
    vagrant up

This will:

  * download a vagrant box
  * start the virtual machine
  * setup MASQUERADE (NAT) on two host interfaces

To validate all works as expected, issue this command:

    host$ vagrant ssh 

    vm$ curl www.multipath-tcp.org

The outpout should be message full of joy, congratulating you for your MPTCP capabilities!

You stop the vm by issuing

    host$ vagrant halt

This will also remove the NAT that was setup when starting the vm.
  

Credits
=======

Originally developed by Raphael Bauduin.
Thanks to @mpyw for the Mac OS X NAT.