#!/bin/sh

set +x

SCENARIO="scenario5"

/shared/scripts/${SCENARIO}/sink_setup.sh

#  ${SCENARIO##*/}
#printf '%s\n' "${SCENARIO}"
TARGET_DIR="/shared/results/"
sudo pkill iperf3
sudo pkill iperf3
iperf3 -s -p 5201 >$TARGET_DIR/${SCENARIO}_iperf_server_5201.txt &
iperf3 -s -p 5202 >$TARGET_DIR/${SCENARIO}_iperf_server_5202.txt &
iperf3 -s -p 5203 >$TARGET_DIR/${SCENARIO}_iperf_server_5203.txt &
