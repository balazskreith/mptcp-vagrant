#!/bin/bash
#
# Enable NAT and IP forwarding between guest and external networks
# Also create host_status to announce to guest
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
enable_ip_forwarding_on_mac() {
	sudo sysctl -w net.inet.ip.forwarding=1
	sudo sysctl -w net.inet6.ip6.forwarding=1
}

get_hostonlyIface() {
	hostonlyIface="$(ip route| awk '$1 == "192.168.33.0/24" {print $3}')"
}
get_hostonlyIface_mac() {
	hostonlyIface=""
	for iface in $(ifconfig -l); do
		ip4=$(ifconfig $iface | grep "192.168.33.1")
		if ! [ -z "$ip4" ]; then
			hostonlyIface=$iface
		fi
	done
}

# manually add an IPv6 address to vboxnet0/1 interface
# due to VirtualBox nasty bug with IPv6 host-only interface
# Look at www.virtualbox.org/ticket/14855
add_IPv6_on_hostonlyIface() {
	get_hostonlyIface
	sudo ip addr add fde4:8dba:82e1::1/64 dev ${hostonlyIface}
}
add_IPv6_on_hostonlyIface_mac() {
	get_hostonlyIface_mac
	sudo ifconfig ${hostonlyIface}  inet6  fde4:8dba:82e1::1/64
}

set_up_IPv6_masquerade() {
	ipv6_routes=$(/sbin/ip -6 route | grep default| wc -l)

	if [[ $ipv6_routes == 0 ]]; then
		echo "==> IPv6 is not available on Host"
	else
		echo "==> IPv6 is available, setting up IPv6 NAT..."
		ipv6_capable=true
		add_IPv6_on_hostonlyIface
		sudo ip6tables -t nat -A POSTROUTING -s fde4:8dba:82e1::c4/64 -j MASQUERADE
	fi
}
set_up_IPv6_nat_on_mac() {
	ipv6_iface=$(netstat -nr -f inet6 |grep -m 1 "default" | awk '{print $4}')
	if [ -z "$ipv6_iface" ]
	then
		echo "==> IPv6 is not available on Host"
	else
		echo "==> IPv6 is available, setting up IPv6 NAT..."
		ipv6_capable=true
		add_IPv6_on_hostonlyIface_mac
		echo "nat on $ipv6_iface from fde4:8dba:82e1::c4/64 to any -> $ipv6_iface" >> ./mac.rules
	fi
}

load_mac_rules() {
	sudo pfctl -evf ./mac.rules;
}

# firewalld rules are needed on some distros to allow traffic from the guest VM
add_firewalld_rules() {
	systemctl is-enabled firewalld &> /dev/null
	if [ $? == 0 ]; then 
		echo "==> Adding firewalld rules" 
		sudo firewall-cmd --zone trusted --add-source 192.168.33.0/24 > /dev/null
		sudo firewall-cmd --zone trusted --add-source 192.168.34.0/24 > /dev/null
	fi 
}

second_iface=false
ipv6_capable=false

if [[ "$uname_str" == "Linux" ]]; then

	enable_ip_forwarding_on_linux
	add_firewalld_rules

	echo "==> Enabling IP Masquerading on host"
	# set masquerade on default interface
	sudo iptables -t nat -A POSTROUTING -s 192.168.33.0/24 -j MASQUERADE

	ifcount=$(/sbin/ip route | grep default| wc -l)
	string=($(/sbin/ip route | grep default| awk '{print $3,$5}'))

	case $((ifcount)) in
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

		if [[ "$gateway1" == "$gateway2" ]]; then
			echo "Two interfaces use the same gateway, we use one interface only"
			second_iface=false
			set_up_IPv6_masquerade
			break
		else
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
		fi
		;;
	esac

elif [[ "$uname_str" == "Darwin" ]]; then
	enable_ip_forwarding_on_mac
	# iface1=$(route get 8.8.8.8| awk '$1=="interface:" {print $2}')

	ifcount=$(netstat -nr -f inet | grep default| wc -l)
	string=($(netstat -nr -f inet | grep default| awk '{print $2,$6}'))

	case $((ifcount)) in
	0)
		echo "==> ERROR: no default route found :(, please check if you have Internet connection"
		;;
	1)
		iface1=${string[1]}
		echo "==> ONE active interface detected: ${iface1}"
		echo "nat on $iface1 from 192.168.33.0/24 to any -> $iface1" > ./mac.rules
		set_up_IPv6_nat_on_mac
		load_mac_rules
		;;
	*)
		iface1=${string[1]}
		iface2=${string[3]}
		gateway2=${string[2]}

		echo "==> TWO active interfaces detected: $iface1, $iface2"
		second_iface=true
		echo "nat on $iface1 from 192.168.33.0/24 to any -> $iface1" > ./mac.rules
		echo "nat on $iface2 from 192.168.34.0/24 to any -> $iface2" >> ./mac.rules

		set_up_IPv6_nat_on_mac

		echo "==> Set source-routing on second interface"
		# otherwise packets from second vboxnet would be sent out via the first interface
		# echo "pass all" >> ./mac.rules
		echo "pass in route-to ($iface2 $gateway2) from 192.168.34.0/24" >> ./mac.rules

		load_mac_rules
		;;
	esac
else
	echo "FAILED! Host OS unknown"
fi

# sent host status to guest via this file
echo -e "# This file shows host's network status, which is used as input for iperf test script
second_iface	$second_iface
ipv6_capable	$ipv6_capable" > ./sent_to_guest/host_status
