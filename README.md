About
=====

This repo contains vagrant configurations to help you test Multipath TCP:

- use virtual machine without requiring MPTCP support from the host.
- test with multiple host interfaces.

The Ubuntu box is downloaded from https://atlas.hashicorp.com/hoangtran/boxes/mptcp-iperf/, containing:

- multipath TCP version 0.91
- MPTCP socket API
- tweaked iperf3 for multipath TCP


Requirements
============

Host OS: Currently Linux and Mac OS X hosts are supported.

You need a recent vagrant and virtualbox installed. <br />
Get it at http://www.vagrantup.com/downloads.html  <br />
and https://www.virtualbox.org/wiki/Downloads

The plugin  vagrant-trigger is also required (see below for installing it).

You also need to have root access via sudo so the script can add NAT rules.

Seting up
=========

Get it and use it:

    git clone https://github.com/hoang-tranviet/mptcp-vagrant.git
    cd mptcp-vagrant

    # only the first time:
    vagrant plugin install vagrant-triggers

    vagrant up

This will:

  * download a vagrant box if this is the first time it run
  * start the virtual machine
  * setup 2 interfaces on guest VM
  * setup MASQUERADE (NAT) on two host interfaces.
    Each guest interface will be mapped to a host interface.

Using it
========

To validate all works as expected, issue this command:

    host$ vagrant ssh 

    vm$ curl www.multipath-tcp.org

The outpout should be message full of joy, congratulating you for your MPTCP capabilities!

tweaked iperf3
--------------

Let's try with something more concrete :)

This box also contains a tweaked iperf3 for multipath measurements.
It can create MPTCP subflows at your wish, and get statistics for each subflow.
You can refer its README.md for more information on how to use it.

But for now, you can run throughput tests to our iperf server at OVH by this script:

    vm:~$ ./mptcp-iperf-tests


You stop the vm by issuing

    host$ vagrant halt

This will also remove the NAT that was setup when starting the vm.
  

Credits
=======

Originally developed by Raphael Bauduin.
Thanks to @mpyw for the Mac OS X NAT.

For any issue or question, do not hesitate to contact me at hoang.tran (a) uclouvain.be