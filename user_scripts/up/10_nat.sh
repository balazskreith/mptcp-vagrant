#!/bin/bash
set -x

echo "port up nat"
uname_str=$(uname)

if [[ "$uname_str" == "Linux" ]]; then

	echo "==> Enabling IP Masquerading on host"
	# set masquerade on default interface
	sudo iptables -t nat -A POSTROUTING -s 192.168.33.0/24 -j MASQUERADE

	if [ -f ./second_interface.txt ]; then
		read interface2 ip2 gateway2 < ./second_interface.txt
		echo "==> Set source-routing on second interface"
		# forward packets from 192.168.34.10 to second interface
		sudo ip rule add from 192.168.34.10 table 2
		sudo ip route add 192.168.34.0/24 dev $interface2 scope link table 2
		sudo ip route add default  via $gateway2  dev $interface2    table 2

		# set masquerade on second interface
		sudo iptables -t nat -A POSTROUTING -s 192.168.34.0/24 -j MASQUERADE -o $interface2
	else
		echo "./second_interface.txt not found, you can only use one interface"
		echo "consider to run ./start.sh"
	fi

elif [[ "$uname_str" == "Darwin" ]]; then
	sudo sysctl -w net.inet.ip.forwarding=1
	iface1=$(route get 8.8.8.8| awk '$1=="interface:" {print $2}')
	if [[ iface1 == "en0" ]]; then
		iface2="en1"
	else
		iface2="en0"
	fi
	echo "nat on $iface1 from 192.168.33.0/24 to any -> $iface1" | sudo pfctl -ef - >/dev/null 2>&1;
	echo "nat on $iface2 from 192.168.34.0/24 to any -> $iface2" | sudo pfctl -ef - >/dev/null 2>&1;
else
	echo "FAILED! Host OS unknown"
fi