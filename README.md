About
=====

This repo contains vagrant configurations to help you test Multipath TCP:

- use virtual machine without requiring MPTCP support from the host.
- test with multiple host interfaces.
- test with dual-stack IPv4/IPv6.

The Ubuntu box is downloaded from https://atlas.hashicorp.com/hoangtran/boxes/mptcp-iperf/, containing:

- multipath TCP version 0.91
- MPTCP socket API.  <br />
  (This is the only public API for finely control MPTCP at subflow level (create or remove subflow...). It is not yet merged to mainstreamed MPTCP. More information can be found at https://inl.info.ucl.ac.be/system/files/main_8.pdf and https://tools.ietf.org/html/draft-hesmans-mptcp-socket-01)
- tweaked iperf3 for multipath TCP


Requirements
============

Host OS: Currently Linux and Mac OS X hosts are supported.

You need a recent vagrant and virtualbox installed. They are available at http://www.vagrantup.com/downloads.html and https://www.virtualbox.org/wiki/Downloads
If you are using Linux, we have auto install scripts in our repository below.

You also need to have root access via sudo so the script can add NAT rules.

Setting up
==========

Get it from github:

    git clone https://github.com/hoang-tranviet/mptcp-vagrant.git
    cd mptcp-vagrant

and now we can start:

    vagrant up

This will:

  * download a vagrant box if this is the first time it run
  * start the virtual machine
  * setup 2 interfaces on guest VM
  * setup MASQUERADE (NAT) on two host interfaces if available. <br />
    Each guest interface will be mapped to a host interface.
  * setup MASQUERADE (NAT) on IPv6-enabled interface if available.

Using it
========

To validate all works as expected, issue this command:

    host$ vagrant ssh 

    vm$ curl www.multipath-tcp.org

The outpout should be message full of joy, congratulating you for your MPTCP capabilities!

To confirm that the second interface NAT or IPv6 NAT works correctly,
you can run the pingtest

    ./pingtest

tweaked iperf3
--------------

Let's try with something more concrete :)

This box also contains a tweaked iperf3 for multipath measurements.
It can create MPTCP subflows at your wish, and get statistics for each subflow.
You can refer its README.md for more information on how to use it.

But for now, you can run throughput tests to our iperf server by this script:

    vm:~$ ./run_all_tests

You can also capture packet trace during iperf test by:

    vm:~$ ./run_all_tests capture

And dump-*.pcap files will be created in home folder.
You stop the vm by issuing

    host$ vagrant halt

This will also remove the NAT that was setup when starting the vm.
  

Update the box version
======================

When there is a new box version available (on atlas.hashicorp.com/hoangtran/boxes/mptcp-iperf/),
vagrant will notify when you do "vagrant up".

You can update the box but the old environment (including VM) need to be destroyed.
Make sure that you have backed up stuff inside the VM before update the box.

The process is as following:

    vagrant box update
    vagrant destroy
    vagrant up

Here you need "vagrant destroy" to destroy the current environment,
before creating a new one based on new box.
If you just want to try the new one but still keep the current environment safe,
let's copy the mptcp-vagrant folder (or another clone of this repo)
to another place and play with it.


Credits
=======

Originally developed by Raphael Bauduin. <br \>
Thanks to @mpyw for the Mac OS X NAT. <br \>
Thanks to @aclarembeau for dealing with firewalld on Fedora.

For any issue or question, do not hesitate to contact me at hoang.tran (a) uclouvain.be

