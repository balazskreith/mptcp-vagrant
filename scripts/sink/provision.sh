#!/bin/bash
set -x

set_default_route() {
  # set default route via the bridge, not the nat
  host_ipv4="192.168.33.10"
  #  host_ipv6="fde4:8dba:82e1::1"

  ip route del default via 10.0.2.2
  ip route add default via $host_ipv4

  #	ip addr add fde4:8dba:82e1::c4/64  dev eth1
  #	ip -6 route add default via $host_ipv6 dev eth1
}

set_source_routing_on_guest() {
  echo " set source routing on guest VM"
  # packets having srcIP=192.168.33.10 are sent over eth1, through table1
  ip rule add from 192.168.33.100 table 1
  ip route add 192.168.33.0/24 dev eth1 scope link table 1
  ip route add default via 192.168.33.10 dev eth1 table 1

  # packets having srcIP=192.168.34.10 are sent over eth2, through table2
  ip rule add from 192.168.33.200 table 2
  ip route add 192.168.33.0/24 dev eth2 scope link table 2
  ip route add default via 192.168.33.20 dev eth2 table 2

  # # default route for the selection process of normal internet-traffic
  # ip route add default scope global nexthop via 192.168.33.1 dev eth1
}

configure_MPTCP_parameters() {
  modprobe mptcp_coupled
  modprobe mptcp_olia
  modprobe mptcp_balia
  modprobe mptcp_wvegas
  modprobe mptcp_binder
  sysctl -w net.ipv4.tcp_congestion_control=mptcp_coupled
  sysctl -w net.mptcp.mptcp_path_manager=default
  sysctl -w net.mptcp.mptcp_scheduler=default
  sysctl -w net.mptcp.mptcp_debug=1
}

echo "configure guest VM"

#set_default_route
#set_source_routing_on_guest
configure_MPTCP_parameters

sudo ip route del default via 10.0.2.2
sudo ip rule add from 192.168.53.100 table 1
sudo ip route add 192.168.54.0/24 dev eth1 scope link table 1
sudo ip route add 192.168.53.0/24 dev eth1 scope link table 1

sudo ip rule add from 192.168.54.100 table 2
sudo ip route add 192.168.53.0/24 dev eth2 scope link table 2
sudo ip route add 192.168.54.0/24 dev eth2 scope link table 2
