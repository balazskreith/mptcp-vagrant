About
=====

This repo is forked from https://github.com/hoang-tranviet/mptcp-vagrant to perform 
fairness tests on MPTCP using different test scenarios. 

Although the original repo contains many possibility to run tests, 
for special need I have made a couple of changes.

 -  The Vagrantfile creates two machines: source, and sink. Source is used to run 
 iperf clients, and sink is used to run iperf server. Although the source and sink 
 are connected to the internet via VBox default NAT interface, 
 the tests are performed between the two virtual machines.
 - I also deleted most of the comments in the Vagrantfile, to see what it is doing.   
 - Source and sink uses two network interfaces to connect each other via an internal 
 network setup between the two VMs.
 - Scenarios use linux namespaces, inside the source, in order to control the 
 fullmesh between the endpoints.
 
 Any of who wants to perform a test for mptcp, I highly recommend to use the iperf 
 , which uses mptcp socket.
 
Setting up
==========

Get it from github:

    git clone https://github.com/balazskreith/mptcp-vagrant.git
    cd mptcp-vagrant

and now we can start:

    vagrant up

This will:

  * download a vagrant box if this is the first time it run
  * start the virtual machine
  * setup 3 interfaces on guest VMs
  * share the /shared folder, so you can run scenarios.

Using it
========

To validate all works as expected, issue this command:

To run a test, first you need to run the task for the sink:

    $ vagrant ssh sink
    $ /shared/scripts/scenario3/sink_task.sh
    
After that you need to run the scenario on the source too:

    $ vagrant ssh sink
    $ /shared/scripts/scenario3/source_task.sh

The results are saved under /shared/results/scenario3

tweaked iperf3
--------------

This is very much the heart of the test, and this is why this box is used.
more information: https://github.com/hoang-tranviet/mptcp-vagrant 

Update
======================

Well, feel free to make PR, or anything, I am not gonna stop you.

Credits
=======

The repo was forked from https://github.com/hoang-tranviet/mptcp-vagrant.
But if you have any questions related to the test you can perform using this repo, 
please write to me, if you have questions about mptcp, please do not write to me.


