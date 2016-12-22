#!/bin/bash
set -x

echo "port halt nat"
uname_str=$(uname)

read interface2 ip2 gateway2 < ./second_interface.txt

if [[ "$uname_str" == "Linux" ]]; then

	echo "==> Remove source-routing"

	sudo ip rule del from 192.168.34.10 table 2
	sudo ip route del 192.168.34.0/24 dev $interface2 scope link table 2
	sudo ip route del default  via $gateway2  dev $interface2    table 2

	echo "==> Disabling IP Masquerading on host"

	sudo iptables -t nat -D POSTROUTING -s 192.168.33.0/24 -j MASQUERADE

	sudo iptables -t nat -D POSTROUTING -s 192.168.34.0/24 -j MASQUERADE -o $interface2

elif [[ "$uname_str" == "Darwin" ]]; then
	sudo sysctl -w net.inet.ip.forwarding=0
	sudo pfctl -df /etc/pf.conf > /dev/null 2>&1;
else
	echo "FAILED! Host OS unknown"
fi