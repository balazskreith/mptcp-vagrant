#!/bin/bash
#
set -x

# I am using Mac
#sudo sysctl -w net.inet.ip.forwarding=1
#sudo sysctl -w net.inet6.ip6.forwarding=1

#load_mac_rules() {
#  sudo pfctl -evf ./sink.mac.rules
#}

#echo "nat on $iface1 from 192.168.33.0/24 to any -> $iface1" >./sink.mac.rules
#echo "nat on $iface1 from 192.168.34.0/24 to any -> $iface1" >>./sink.mac.rules
#    set_up_IPv6_nat_on_mac
#load_mac_rules
