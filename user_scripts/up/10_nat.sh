#!/bin/bash
set -x

echo "port up nat"
uname_str=$(uname)

# this is needed for masquerading to take effect
# on some Distros (like Debian) it is disabled by default
enable_ip_forwarding_on_linux() {
	echo "==> Enabling IP forwarding on host"
	sudo sysctl -w net.ipv4.ip_forward=1
	sudo sysctl -w net.ipv4.conf.all.forwarding=1
	sudo sysctl -w net.ipv6.conf.all.forwarding=1
}

get_hostonlyIface() {
	hostonlyIface="$(ip route| awk '$1 == "192.168.33.0/24" {print $3}')"
}

add_IPv6_on_hostonlyIface() {
	get_hostonlyIface
	sudo ip addr add fde4:8dba:82e1::1/64 dev ${hostonlyIface}
}

set_up_IPv6_masquerade() {
	echo "==> Setting up IPv6 NAT"
	ipv6_capable=true
	add_IPv6_on_hostonlyIface
	sudo ip6tables -t nat -A POSTROUTING -s fde4:8dba:82e1::c4/64 -j MASQUERADE
}

second_iface=false
ipv6_capable=false

if [[ "$uname_str" == "Linux" ]]; then

	enable_ip_forwarding_on_linux

	echo "==> Enabling IP Masquerading on host"
	# set masquerade on default interface
	sudo iptables -t nat -A POSTROUTING -s 192.168.33.0/24 -j MASQUERADE

	ifcount=$(/sbin/ip route | grep default| wc -l)
	string=($(/sbin/ip route | grep default| awk '{print $3,$5}'))

	case $ifcount in
	0)
		echo "==> ERROR: no default route found :(, please check if you have Internet connection"
		;;
	1)
		echo "==> ONE active interface detected: ${string[0]}, gateway: ${string[1]}"
		echo "==> please consider to enable your second interface"
		set_up_IPv6_masquerade
		;;
	*)
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

		# set masquerade on second interface
		sudo iptables -t nat -A POSTROUTING -s 192.168.34.0/24 -j MASQUERADE -o $interface2

		set_up_IPv6_masquerade
		ipv6_capable=true
		;;
	esac

elif [[ "$uname_str" == "Darwin" ]]; then
	sudo sysctl -w net.inet.ip.forwarding=1
	iface1=$(route get 8.8.8.8| awk '$1=="interface:" {print $2}')
	if [[ $iface1 == "en0" ]]; then
		iface2="en1"
	else
		iface2="en0"
	fi
	echo "nat on $iface1 from 192.168.33.0/24 to any -> $iface1" | sudo pfctl -ef - >/dev/null 2>&1;
	echo "nat on $iface2 from 192.168.34.0/24 to any -> $iface2" | sudo pfctl -ef - >/dev/null 2>&1;
else
	echo "FAILED! Host OS unknown"
fi

# sent host status to guest via this file
echo -e "# This file shows host's network status, which is used as input for iperf test script
second_iface	$second_iface
ipv6_capable	$ipv6_capable" > ./sent_to_guest/host_status
