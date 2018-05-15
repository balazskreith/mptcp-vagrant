#!/bin/bash
set -x

iface1=enp0s8
iface2=enp0s9

set_default_route() {
	# set default route via the bridge, not the nat
	host_ipv4="192.168.33.1"
	host_ipv6="fde4:8dba:82e1::1"

	ip route del default via 10.0.2.2
	ip route add default via $host_ipv4

	ip addr add fde4:8dba:82e1::c4/64  dev $iface1
	ip -6 route add default via $host_ipv6 dev $iface1
}

set_source_routing_on_guest() {
	echo " set source routing on guest VM"
	# packets having srcIP=192.168.33.10 are sent over iface1, through table1
	ip rule add from 192.168.33.10  table 1
	ip route add 192.168.33.0/24  dev $iface1 scope link table 1
	ip route add default via  192.168.33.1  dev $iface1 table 1

	# packets having srcIP=192.168.34.10 are sent over iface2, through table2
	ip rule add from 192.168.34.10  table 2
	ip route add 192.168.34.0/24  dev $iface2 scope link table 2
	ip route add default via  192.168.34.1  dev $iface2 table 2

	# # default route for the selection process of normal internet-traffic
	# ip route add default scope global nexthop via 192.168.33.1 dev iface1
}

configure_MPTCP_parameters() {
	modprobe mptcp_coupled
	modprobe mptcp_olia
	modprobe mptcp_balia
	modprobe mptcp_wvegas
	modprobe mptcp_binder
	sysctl -w net.ipv4.tcp_congestion_control=olia
	sysctl -w net.mptcp.mptcp_path_manager=default
	sysctl -w net.mptcp.mptcp_scheduler=default
	sysctl -w net.mptcp.mptcp_debug=1
}

echo "configure guest VM"

set_default_route
set_source_routing_on_guest
# configure_MPTCP_parameters