#!/bin/sh

set +x

NS_SRC1="ns_src1"
NS_SRC2="ns_src2"
NS_RCV="ns_rcv"
NS_MID="ns_mid"

CMD_FILE_RCV="${NS_RCV}.sh"
CMD_FILE_SRC1="${NS_SRC1}.sh"
CMD_FILE_SRC2="${NS_SRC2}.sh"
SCENARIO=${PWD##*/} # to assign to a variable

#  ${SCENARIO##*/}
#printf '%s\n' "${SCENARIO}"
mkdir /test_results
echo "/test_results is created"
TARGET_DIR="/test_results/${SCENARIO}"
mkdir $TARGET_DIR
echo "$TARGET_DIR is created"
RUNTIME=120
END=30
for i in $(seq 1 $END); do
  echo "BEGIN RUN: $i"
  RESULTSDIR="${TARGET_DIR}/run_${i}"
  rm -rf $RESULTSDIR
  echo "\t$RESULTSDIR is deleted"
  mkdir $RESULTSDIR
  echo "\t$RESULTSDIR is created"
  touch $CMD_FILE_RCV
  echo "iperf3 -s -p 5201 > $RESULTSDIR/iperf_srv_5201.txt &" >$CMD_FILE_RCV
  echo "iperf3 -s -p 5202 > $RESULTSDIR/iperf_srv_5202.txt &" >>$CMD_FILE_RCV
  echo "sleep $RUNTIME; sleep 2" >>$CMD_FILE_RCV
  echo "sudo pkill iperf3" >>$CMD_FILE_RCV
  chmod +x $CMD_FILE_RCV
  sudo ip netns exec $NS_RCV ./$CMD_FILE_RCV &

  touch $CMD_FILE_SRC1
  echo "iperf3 -c 10.0.0.112  -p 5201 -t $RUNTIME > $RESULTSDIR/${NS_SRC1}.txt" >$CMD_FILE_SRC1
  chmod +x $CMD_FILE_SRC1
  sudo ip netns exec $NS_SRC1 ./$CMD_FILE_SRC1 &

  touch $CMD_FILE_SRC2
  echo "iperf3 -c 10.0.0.112 -p 5202 -t $RUNTIME > $RESULTSDIR/${NS_SRC2}.txt " >$CMD_FILE_SRC2
  chmod +x $CMD_FILE_SRC2
  sudo ip netns exec $NS_SRC2 ./$CMD_FILE_SRC2 &

  echo "\t Waiting to perform the test ($RUNTIME sec)"
  sleep $RUNTIME
  echo "\t An extra 5 seconds safety waiting time is enforced"
  sleep 5
  echo "END RUN: $i"
  echo "------------"
done
echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
echo "! Tests are saved under $TARGET_DIR      !"
echo "! Take care to get it out from this box. !"
echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"

#sudo ip netns exec $NS_SRC1 iperf3 -c 10.0.0.112 -t 20 >src1.txt &
#echo "somethig else "
#sudo ip netns exec $NS_SRC2 iperf3 -c 10.0.0.112 -t 20 >src2.txt &
