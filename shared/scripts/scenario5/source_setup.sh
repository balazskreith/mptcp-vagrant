#!/bin/bash

set -x

#!/bin/sh

set -x
NS_SRC1="ns_src1"
SRC1_OUT_VETH="src1-out"
SRC1_IN_VETH="src1-in"

NS_SRC2="ns_src2"
SRC21_OUT_VETH="src2-out"
SRC21_IN_VETH="src2-in"

#sudo ip link add name br0 type bridge
#sudo ip link set br0 up
#sudo ip link set eth1 up
#sudo ip link set eth1 master br0

sudo ip netns del $NS_SRC1
sudo ip netns add $NS_SRC1

sudo ip netns del $NS_SRC2
sudo ip netns add $NS_SRC2

sudo ip link del $SRC1_OUT_VETH
sudo ip link del $SRC1_IN_VETH

sudo ip link del $SRC21_OUT_VETH
sudo ip link del $SRC21_IN_VETH

#Setup the cable between the out and in
sudo ip link add $SRC1_OUT_VETH type veth peer name $SRC1_IN_VETH

#Setup the cable between the out and in
sudo ip link add $SRC21_OUT_VETH type veth peer name $SRC21_IN_VETH

#Put the out part to the namespace
sudo ip link set $SRC1_OUT_VETH netns $NS_SRC1
#Put the out part to the namespace
sudo ip link set $SRC21_OUT_VETH netns $NS_SRC2

# Add a loopback to the created namespace
sudo ip netns exec $NS_SRC1 ip address add 127.0.0.1/8 dev lo
sudo ip netns exec $NS_SRC1 ip link set dev lo up
sudo ip netns exec $NS_SRC2 ip address add 127.0.0.1/8 dev lo
sudo ip netns exec $NS_SRC2 ip link set dev lo up

# Assign ip addresses to the peer cable and bring them up
sudo ip netns exec $NS_SRC1 ip address add 10.53.0.10/24 dev $SRC1_OUT_VETH
sudo ip netns exec $NS_SRC1 ip link set dev $SRC1_OUT_VETH up
sudo ip address add 10.53.0.20/24 dev $SRC1_IN_VETH
sudo ip link set $SRC1_IN_VETH up

sudo ip netns exec $NS_SRC2 ip address add 10.54.0.10/24 dev $SRC21_OUT_VETH
sudo ip netns exec $NS_SRC2 ip link set dev $SRC21_OUT_VETH up
sudo ip address add 10.54.0.20/24 dev $SRC21_IN_VETH
sudo ip link set $SRC21_IN_VETH up

# Add a default gateway from the interface through the peercable
sudo ip netns exec $NS_SRC1 sudo ip route add default via 10.53.0.20

sudo ip netns exec $NS_SRC2 ip rule add from 10.54.0.10 table 1
sudo ip netns exec $NS_SRC2 ip route add 192.168.54.0/24 via 10.54.0.20 table 1

sudo ip netns exec $NS_SRC2 sudo ip route add default via 10.54.0.20
#sudo ip netns exec $NS_SRC2 sudo ip route add default via 10.55.0.20

# And add a rule to the vbox machine to route packets from the namespace to the other vbox
sudo ip rule add from 10.53.0.20 table 3
sudo ip route add 192.168.53.0/24 via 192.168.53.10 table 3

sudo ip rule add from 10.54.0.20 table 4
sudo ip route add 192.168.54.0/24 via 192.168.54.10 table 4

# Make sure it is allowed, otherwise you will pull out your hair
sudo sysctl -w net.ipv4.ip_forward=1

# Now setup the bandwidth

BW=2000
LATENCY=100
BURST=15400

INTERFACE="eth1"

sudo tc qdisc del dev "$INTERFACE" root
sudo tc qdisc add dev "$INTERFACE" root handle 1: netem delay "$LATENCY"ms
sudo tc qdisc add dev "$INTERFACE" parent 1: handle 2: tbf rate "$BW"kbit burst "$BURST" latency 300ms minburst 1540

BW=2000
LATENCY=100
BURST=15400

INTERFACE="eth2"

sudo tc qdisc del dev "$INTERFACE" root
sudo tc qdisc add dev "$INTERFACE" root handle 1: netem delay "$LATENCY"ms
sudo tc qdisc add dev "$INTERFACE" parent 1: handle 2: tbf rate "$BW"kbit burst "$BURST" latency 300ms minburst 1540
