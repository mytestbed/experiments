#!/bin/bash
#
# Short script to reset the Resource Controllers if required.
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
  echo "resetting controller on $i"
  scp -r -o StrictHostKeyChecking=no config.yml root@$i:/etc/omf_rc/config.yml
  ssh -o StrictHostKeyChecking=no root@$i "/etc/init.d/omf_rc restart"
done
echo "wait 10s to give them time to be ready..."
sleep 10

