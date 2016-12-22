#!/bin/bash
set -x

echo "port up nat"
uname_str=$(uname)

read interface2 ip2 gateway2 < ./second_interface.txt

if [[ "$uname_str" == "Linux" ]]; then

	echo "==> Set source-routing"
	# forward packets from 192.168.34.10 to second interface
	sudo ip rule add from 192.168.34.10 table 2
	sudo ip route add 192.168.34.0/24 dev $interface2 scope link table 2
	sudo ip route add default  via $gateway2  dev $interface2    table 2

	echo "==> Enabling IP Masquerading on host"
	# set masquerade on default interface
	sudo iptables -t nat -A POSTROUTING -s 192.168.33.0/24 -j MASQUERADE
	# set masquerade on second interface
	sudo iptables -t nat -A POSTROUTING -s 192.168.34.0/24 -j MASQUERADE -o $interface2

elif [[ "$uname_str" == "Darwin" ]]; then
	sudo sysctl -w net.inet.ip.forwarding=1
	echo "nat on en0 from 192.168.33.0/24 to any -> en0" | sudo pfctl -ef - >/dev/null 2>&1; 
else
	echo "FAILED! Host OS unknown"
fi