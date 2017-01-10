#!/bin/bash
set -x

# set default route via the bridge, not the nat
host_ipv4="192.168.33.1"

ip route del default via 10.0.2.2
ip route add default via $host_ipv4

	echo " set source routing on guest VM"
	# packets having srcIP=192.168.33.10 are sent over eth1, through table1
	ip rule add from 192.168.33.10  table 1
	ip route add 192.168.33.0/24  dev eth1 scope link table 1
	ip route add default via  192.168.33.1  dev eth1 table 1

	# packets having srcIP=192.168.34.10 are sent over eth2, through table2
	ip rule add from 192.168.34.10  table 2
	ip route add 192.168.34.0/24  dev eth2 scope link table 2
	ip route add default via  192.168.34.1  dev eth2 table 2

	# # default route for the selection process of normal internet-traffic
	# ip route add default scope global nexthop via 192.168.33.1 dev eth1

echo "configure MPTCP parameters:"
modprobe mptcp_coupled
modprobe mptcp_olia
modprobe mptcp_balia
modprobe mptcp_wvegas
modprobe mptcp_binder
sysctl -w net.ipv4.tcp_congestion_control=olia
sysctl -w net.mptcp.mptcp_path_manager=default
sysctl -w net.mptcp.mptcp_scheduler=default