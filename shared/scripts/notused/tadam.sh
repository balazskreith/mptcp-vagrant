#!/bin/sh
# This script was originally made for creating testbed for mprtp (https://github.com/balazskreith/gst-mprtp)
# But it turned out it can be useful to make testbed for mptcp as well.

set -x

NS_MID="ns_mid"

#Remove existing namespace
sudo ip netns del $NS_MID

#Remove existing veth pairs
sudo ip link del "snd1"
sudo ip link del "mid1in"
sudo ip link del "mid1out"
sudo ip link del "snd2"
sudo ip link del "rcv1"

#Create veth pairs
sudo ip link add "snd1" type veth peer name "mid1in"
sudo ip link add "mid1out" type veth peer name "rcv1"

#Bring up
sudo ip link set dev "snd1" up
sudo ip link set dev "mid1in" up
sudo ip link set dev "mid1out" up
sudo ip link set dev "rcv1" up

#Create the specific namespaces
sudo ip netns add $NS_MID

#Move the interfaces to the namespace
sudo ip link set "mid1in" netns $NS_MID
sudo ip link set "mid1out" netns $NS_MID

#Configure the loopback interface in namespace
sudo ip netns exec $NS_MID ip address add 127.0.0.1/8 dev lo
sudo ip netns exec $NS_MID ip link set dev lo up

#J> Setup LXBs in NS_MID
sudo ip netns exec $NS_MID ip link add name br0 type bridge
sudo ip netns exec $NS_MID ip link set dev br0 up

### Bring up veths in MID
sudo ip netns exec $NS_MID ip link set dev "mid1in" up
sudo ip netns exec $NS_MID ip link set dev "mid1out" up

### Add veth to LXBs
sudo ip netns exec $NS_MID ip link set "mid1in" master br0
sudo ip netns exec $NS_MID ip link set "mid1out" master br0

ip link set dev "snd1" up
ip address add 10.0.1.12/24 dev "snd1"
ip link set dev "rcv1" up
ip address add 10.0.2.12/24 dev "rcv1"

sudo ip rule add from 10.0.1.12 table 1
#
sudo ip route add 10.0.2.0/24 dev "snd1" scope link table 1

sudo ip rule add from 10.0.2.12 table 2
#
sudo ip route add 10.0.1.0/24 dev "rcv1" scope link table 2 

#Add IP forwarding rule
sudo ip netns exec $NS_MID sysctl -w net.ipv4.ip_forward=1
#dd of=/proc/sys/net/ipv4/ip_forward <<<1

sudo ip netns exec $NS_MID "./tc_ns_mid.sh"
