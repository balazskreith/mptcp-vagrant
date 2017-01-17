#!/bin/bash
set -x

echo "port halt nat"
uname_str=$(uname)

get_hostonlyIface() {
	hostonlyIface="$(ip route| awk '$1 == "192.168.33.0/24" {print $3}')"
}

del_IPv6_on_hostonlyIface() {
	get_hostonlyIface
	sudo ip addr del fde4:8dba:82e1::1/64 dev ${hostonlyIface}
}

disable_IPv6_masquerade() {
	echo "==> Disabling IPv6 Masquerading"
	sudo ip6tables -t nat -D POSTROUTING -s fde4:8dba:82e1::c4/64 -j MASQUERADE
}

if [[ "$uname_str" == "Linux" ]]; then

	echo "==> Disabling IP Masquerading on host"

	sudo iptables -t nat -D POSTROUTING -s 192.168.33.0/24 -j MASQUERADE

	ifcount=$(/sbin/ip route | grep default| wc -l)
	string=($(/sbin/ip route | grep default| awk '{print $3,$5}'))

	if (( "$ifcount" >= 2 )); then
		gateway1=${string[0]}
		interface1=${string[1]}
		gateway2=${string[2]}
		interface2=${string[3]}
		echo "==> Remove source-routing"
		sudo ip rule del from 192.168.34.10 table 2
		sudo ip route del 192.168.34.0/24 dev $interface2 scope link table 2
		sudo ip route del default  via $gateway2  dev $interface2    table 2

		echo "==> Disabling IP Masquerading on second interface"
		sudo iptables -t nat -D POSTROUTING -s 192.168.34.0/24 -j MASQUERADE -o $interface2
	fi

	disable_IPv6_masquerade
	del_IPv6_on_hostonlyIface

elif [[ "$uname_str" == "Darwin" ]]; then
	sudo sysctl -w net.inet.ip.forwarding=0
	sudo pfctl -df /etc/pf.conf > /dev/null 2>&1;
else
	echo "FAILED! Host OS unknown"
fi