#!/bin/sh

set -x

BW=2000
LATENCY=100
BURST=15400

MR1="eth1"

sudo tc qdisc del dev "$MR1" root
sudo tc qdisc add dev "$MR1" root handle 1: netem delay "$LATENCY"ms
sudo tc qdisc add dev "$MR1" parent 1: handle 2: tbf rate "$BW"kbit burst "$BURST" latency 300ms minburst 1540

MR1="eth2"

sudo tc qdisc del dev "$MR1" root
sudo tc qdisc add dev "$MR1" root handle 1: netem delay "$LATENCY"ms
sudo tc qdisc add dev "$MR1" parent 1: handle 2: tbf rate "$BW"kbit burst "$BURST" latency 300ms minburst 1540
