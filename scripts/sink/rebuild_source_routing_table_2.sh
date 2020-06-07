#!/bin/bash

string=($(/sbin/ip route | grep default| awk '{print $3,$5}'))

# there are two default interfaces (or more)
gateway1=${string[0]}
interface1=${string[1]}
gateway2=${string[2]}
interface2=${string[3]}
echo "==> TWO active interfaces detected: $interface1, $interface2"
second_iface=true
echo "==> Set source-routing on second interface"
# forward packets from 192.168.34.10 to second interface
sudo ip rule add from 192.168.34.10 table 2
sudo ip route add 192.168.34.0/24 dev $interface2 scope link table 2
sudo ip route add default  via $gateway2  dev $interface2    table 2
