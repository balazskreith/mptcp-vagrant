#!/bin/sh

set +x

# Make sure we use the option we want
sudo sysctl -w net.ipv4.tcp_congestion_control=mptcp_coupled
sudo sysctl net.mptcp.mptcp_path_manager=fullmesh

SCENARIO="scenario4"
NS_SRC1="ns_src1"

/shared/scripts/${SCENARIO}/source_setup.sh
TARGET_DIR="/shared/results/${SCENARIO}"
#rm -rf $TARGET_DIR
mkdir $TARGET_DIR
echo "$TARGET_DIR is created"
RUNTIME=120
END=10
for i in $(seq 1 $END); do
  echo "BEGIN RUN: $i"
  RESULTSDIR="${TARGET_DIR}/run_${i}"
  rm -rf $RESULTSDIR
  echo "\t$RESULTSDIR is deleted"
  mkdir $RESULTSDIR
  echo "\t$RESULTSDIR is created"
  CMD_FILE="/shared/temp/iperf_5201.sh"
  echo "iperf3 -c 192.168.53.100 -p 5201 -t $RUNTIME >$RESULTSDIR/iperf_client_5201.txt &" >$CMD_FILE
  chmod +x $CMD_FILE
  sudo ip netns exec $NS_SRC1 $CMD_FILE
  iperf3 -c 192.168.53.100 -p 5202 -t $RUNTIME >${RESULTSDIR}/iperf_client_5202.txt &
  sleep $RUNTIME
  echo "\t An extra 5 seconds safety waiting time is enforced."
  sleep 5
  echo "END RUN: $i"
  echo "------------"
done
echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
echo "! Tests are saved under $TARGET_DIR      !"
echo "! Take care to get it out from this box. !"
echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
