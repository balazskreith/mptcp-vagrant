#!/bin/bash

set -x

# We need a backroute to the other machine process lies inside a namespace
sudo ip route add 10.53.0.0/24 via 192.168.53.10
sudo ip route add 10.54.0.0/24 via 192.168.53.10
sudo ip route add 10.55.0.0/24 via 192.168.53.10
