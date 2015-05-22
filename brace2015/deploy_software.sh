#!/bin/bash
#
# Short script to deploy short changes in the BRACE middleware 
#
MYSET=""
SET1="node1 node2 node3 node4"
SET2="node5 node6 node7 node8"
SET3="node9 node10 node11 node12"
SET4="node14 node15 node16 node17"
SET5="node28 node29 node30 node32"
SET6="node19 node20 node22 node26"
SET7="node33 node34 node35 node36"
case "$1" in
  1)
    MYSET=$SET1
    ;;
  2)
    MYSET=$SET2
    ;;
  3)
    MYSET=$SET3
    ;;
  4)
    MYSET=$SET4
    ;;
  5)
    MYSET=$SET5
    ;;
  6)
    MYSET=$SET6
    ;;
  7)
    MYSET=$SET7
    ;;
esac
for i in $MYSET
do
  echo "Deploying on $i"
  scp -o StrictHostKeyChecking=no Middleware2015Brace/TaskIssuer.jar root@$i:/root/TaskIssuer/TaskIssuer.jar
  scp -o StrictHostKeyChecking=no Middleware2015Brace/GlobalMonitor.jar root@$i:/root/GlobalMonitorNode/GlobalMonitor.jar
  scp -o StrictHostKeyChecking=no Middleware2015Brace/Agent.jar root@$i:/root/RoverAgent/Agent.jar
  scp -r -o StrictHostKeyChecking=no Specifications root@$i:/root/RoverAgent/
done
