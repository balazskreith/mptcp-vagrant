#!/bin/bash

set -x

#!/bin/sh

BW=2000
LATENCY=100
BURST=15400

INTERFACE="eth1"

sudo tc qdisc del dev "$INTERFACE" root
sudo tc qdisc add dev "$INTERFACE" root handle 1: netem delay "$LATENCY"ms
sudo tc qdisc add dev "$INTERFACE" parent 1: handle 2: tbf rate "$BW"kbit burst "$BURST" latency 300ms minburst 1540

BW=2000
LATENCY=100
BURST=15400

INTERFACE="eth2"

sudo tc qdisc del dev "$INTERFACE" root
sudo tc qdisc add dev "$INTERFACE" root handle 1: netem delay "$LATENCY"ms
sudo tc qdisc add dev "$INTERFACE" parent 1: handle 2: tbf rate "$BW"kbit burst "$BURST" latency 300ms minburst 1540
