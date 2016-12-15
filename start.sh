#!/bin/bash

echo "Get understanding the host network"

printf "Enter the name of second_interface (default: wlan0): "
read -r interface2

if [[ -z "$interface2" ]]
then
	interface2="wlan0"
fi

# get ip from "ip addr" command
ip2="$(ip addr | awk '
/inet/ { ip[$NF] = $2; sub(/\/.*$/,"",ip[$NF]) }
END { print (ip["'${interface2}'"] ) }
')"

gateway=$(/sbin/ip route | grep default |grep wlan0 |awk '{ print $3 }')

echo "$interface2 $ip2 $gateway"

if [[ -z "$ip2" ]]; then
	echo "Please make sure ${interface2} has been connected to Internet"
fi

echo "$interface2 $ip2 $gateway" > ./second_interface.txt
