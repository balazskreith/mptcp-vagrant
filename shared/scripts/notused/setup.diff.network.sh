#!/bin/sh
# This script was originally made for creating testbed for mprtp (https://github.com/balazskreith/gst-mprtp)
# But it turned out it can be useful to make testbed for mptcp as well.

set -x

S11="veth0s1"
S11="veth0s1"
S21="veth0s2"
S11M="veth0s1in"
S21M="veth0s2in"
MR1="veth0out"
R1="veth0r1"

S12="veth1s1"
S12M="veth1s1in"
S22M="veth1s2in"
S22="veth1s2"
MR2="veth1out"
R2="veth1r1"

NS_SRC1="ns_src1"
NS_SRC2="ns_src2"
NS_RCV="ns_rcv"
NS_MID="ns_mid"

#Remove existing namespace
sudo ip netns del $NS_SRC1
sudo ip netns del $NS_SRC2
sudo ip netns del $NS_RCV
sudo ip netns del $NS_MID

#Remove existing veth pairs
sudo ip link del $S11
sudo ip link del $S12
sudo ip link del $S21
sudo ip link del $S22
sudo ip link del $R1
sudo ip link del $S12M
sudo ip link del $S22M
sudo ip link del $MR1
sudo ip link del $R2
sudo ip link del $MR2

#Create veth pairs
sudo ip link add $S11 type veth peer name $S11M
sudo ip link add $MR1 type veth peer name $R1

sudo ip link add $S21 type veth peer name $S21M
sudo ip link add $S22 type veth peer name $S22M

sudo ip link add $S12 type veth peer name $S12M
sudo ip link add $MR2 type veth peer name $R2

#Bring up
sudo ip link set dev $S11 up
sudo ip link set dev $S11M up
sudo ip link set dev $S21M up
sudo ip link set dev $S21 up
sudo ip link set dev $MR1 up
sudo ip link set dev $R1 up

sudo ip link set dev $S12 up
sudo ip link set dev $S12M up
sudo ip link set dev $S22M up
sudo ip link set dev $S22 up
sudo ip link set dev $MR2 up
sudo ip link set dev $R2 up

#Create the specific namespaces
sudo ip netns add $NS_SRC1
sudo ip netns add $NS_SRC2
sudo ip netns add $NS_RCV
sudo ip netns add $NS_MID

#Move the interfaces to the namespace
sudo ip link set $S11 netns $NS_SRC1
sudo ip link set $S21 netns $NS_SRC2
sudo ip link set $S11M netns $NS_MID
sudo ip link set $S21M netns $NS_MID
sudo ip link set $MR1 netns $NS_MID
sudo ip link set $R1 netns $NS_RCV

sudo ip link set $S12 netns $NS_SRC1
sudo ip link set $S22 netns $NS_SRC2
sudo ip link set $S12M netns $NS_MID
sudo ip link set $S22M netns $NS_MID
sudo ip link set $MR2 netns $NS_MID
sudo ip link set $R2 netns $NS_RCV

#Configure the loopback interface in namespace
sudo ip netns exec $NS_SRC1 ip address add 127.0.0.1/8 dev lo
sudo ip netns exec $NS_SRC1 ip link set dev lo up
sudo ip netns exec $NS_SRC2 ip address add 127.0.0.1/8 dev lo
sudo ip netns exec $NS_SRC2 ip link set dev lo up
sudo ip netns exec $NS_RCV ip address add 127.0.0.1/8 dev lo
sudo ip netns exec $NS_RCV ip link set dev lo up
sudo ip netns exec $NS_MID ip address add 127.0.0.1/8 dev lo
sudo ip netns exec $NS_MID ip link set dev lo up

#J> Setup LXBs in NS_MID
sudo ip netns exec $NS_MID ip link add name br0 type bridge
sudo ip netns exec $NS_MID ip link set dev br0 up
sudo ip netns exec $NS_MID ip link add name br1 type bridge
sudo ip netns exec $NS_MID ip link set dev br1 up
sudo ip netns exec $NS_MID ip link add name br2 type bridge
sudo ip netns exec $NS_MID ip link set dev br2 up

### Bring up veths in MID
sudo ip netns exec $NS_MID ip link set dev $S11M up
#sudo ip netns exec $NS_MID ip link set dev $S21M up
sudo ip netns exec $NS_MID ip link set dev $MR1 up
sudo ip netns exec $NS_MID ip link set dev $S12M up
#sudo ip netns exec $NS_MID ip link set dev $S22M up
sudo ip netns exec $NS_MID ip link set dev $MR2 up

### Add veth to LXBs
sudo ip netns exec $NS_MID ip link set $S11M master br0
#sudo ip netns exec $NS_MID ip link set $S21M master br0
sudo ip netns exec $NS_MID ip link set $MR1 master br0
sudo ip netns exec $NS_MID ip link set $S12M master br1
#sudo ip netns exec $NS_MID ip link set $S22M master br1
sudo ip netns exec $NS_MID ip link set $MR2 master br1
#Bring up interface in namespace in the end hosts
sudo ip netns exec $NS_SRC1 ip link set dev $S11 up
sudo ip netns exec $NS_SRC1 ip address add 10.0.1.12/24 dev $S11
sudo ip netns exec $NS_SRC1 ip link set dev $S12 up
sudo ip netns exec $NS_SRC1 ip address add 10.0.2.12/24 dev $S12

sudo ip netns exec $NS_SRC2 ip link set dev $S21 up
sudo ip netns exec $NS_SRC2 ip address add 10.0.1.22/24 dev $S21
sudo ip netns exec $NS_SRC2 ip link set dev $S22 up
sudo ip netns exec $NS_SRC2 ip address add 10.0.2.22/24 dev $S22

sudo ip netns exec $NS_RCV ip link set dev $R1 up
sudo ip netns exec $NS_RCV ip address add 10.1.0.12/24 dev $R1
sudo ip netns exec $NS_RCV ip link set dev $R2 up
sudo ip netns exec $NS_RCV ip address add 10.2.0.12/24 dev $R2

SRC1_ROUTING_TABLE_1="1"
SRC1_ROUTING_TABLE_2="2"

# Add rules to the ip table
# Add Rules and default paths for SRC1
sudo ip netns exec $NS_SRC1 ip rule add from 10.0.1.12 table $SRC1_ROUTING_TABLE_1
sudo ip netns exec $NS_SRC1 ip rule add from 10.0.2.12 table $SRC1_ROUTING_TABLE_2

sudo ip netns exec $NS_SRC1 ip route add 10.0.1.0/24 dev $S11 scope link table $SRC1_ROUTING_TABLE_1
sudo ip netns exec $NS_SRC1 ip route add 10.1.0.0/24 dev $S11 scope link table $SRC1_ROUTING_TABLE_1
sudo ip netns exec $NS_SRC1 ip route add default via 10.0.1.12 dev $S11 table $SRC1_ROUTING_TABLE_1

sudo ip netns exec $NS_SRC1 ip route add 10.0.2.0/24 dev $S12 scope link table $SRC1_ROUTING_TABLE_2
sudo ip netns exec $NS_SRC1 ip route add 10.1.0.0/24 dev $S12 scope link table $SRC1_ROUTING_TABLE_2
sudo ip netns exec $NS_SRC1 ip route add default via 10.0.2.12 dev $S12 table $SRC1_ROUTING_TABLE_2

#sudo ip netns exec $NS_SRC1 ip route add 10.1.0.0/24 via 10.0.1.12
#sudo ip netns exec $NS_SRC1 ip route add 10.2.0.0/24 via 10.0.1.12

# Add Rules and default paths for RCV
sudo ip netns exec $NS_RCV ip rule add from 10.1.0.12 table $SRC1_ROUTING_TABLE_1
sudo ip netns exec $NS_RCV ip route add 10.1.0.0/24 dev $R1 scope link table $SRC1_ROUTING_TABLE_1
sudo ip netns exec $NS_RCV ip route add 10.0.1.0/24 dev $R1 scope link table $SRC1_ROUTING_TABLE_1
sudo ip netns exec $NS_RCV ip route add default via 10.1.0.12 dev $R1 table $SRC1_ROUTING_TABLE_1

sudo ip netns exec $NS_RCV ip rule add from 10.2.0.12 table $SRC1_ROUTING_TABLE_2
sudo ip netns exec $NS_RCV ip route add 10.2.0.0/24 dev $R2 scope link table $SRC1_ROUTING_TABLE_2
sudo ip netns exec $NS_RCV ip route add 10.0.1.0/24 dev $R2 scope link table $SRC1_ROUTING_TABLE_2
sudo ip netns exec $NS_RCV ip route add default via 10.2.0.12 dev $R2 table $SRC1_ROUTING_TABLE_2

#sudo ip netns exec $NS_RCV ip route add 10.0.1.0/24 via 10.1.0.12
#sudo ip netns exec $NS_RCV ip route add 10.0.2.0/24 via 10.2.0.12

#sudo ip netns exec $NS_RCV ip route add 10.0.0.0/30 via 10.0.0.5
# ip route add default via 10.1.1.1 dev eth0 table $SND_TABLE_1

#sudo ip netns exec $NS_SRC2 ip rule add from 10.0.0.22 table $SRC1_ROUTING_TABLE_1
#sudo ip netns exec $NS_SRC2 ip rule add from 10.0.1.22 table $SRC1_ROUTING_TABLE_2
#
#sudo ip netns exec $NS_SRC2 ip route add 10.0.0.0/24 dev $S21 scope link table $SRC1_ROUTING_TABLE_1
#sudo ip netns exec $NS_SRC2 ip route add default via 10.0.0.22 dev $S21 table $SRC1_ROUTING_TABLE_1
#
#sudo ip netns exec $NS_SRC2 ip route add 10.0.1.0/24 dev $S22 scope link table $SRC1_ROUTING_TABLE_2
#sudo ip netns exec $NS_SRC2 ip route add default via 10.0.1.22 dev $S22 table $SRC1_ROUTING_TABLE_2

#sudo ip netns exec $NS_SRC2 ip route add 10.0.0.0/24 via 10.0.0.22
#sudo ip netns exec $NS_SRC2 ip route add 10.0.1.0/24 via 10.0.1.22

# and here we define routes

#Add IP forwarding rule
sudo ip netns exec $NS_MID sysctl -w net.ipv4.ip_forward=1
#dd of=/proc/sys/net/ipv4/ip_forward <<<1

sudo ip netns exec $NS_MID "./tc_ns_mid.sh"
