#!/bin/bash
case $1 in
"start")
   for i in hadoop10 hadoop11 hadoop12
   do
   echo "============== $i kafka============== "
   ssh $i "/opt/module/kafka_2.11-2.4.1/bin/kafka-server-start.sh -daemon /opt/module/kafka_2.11-2.4.1/config/server.properties"
   done
;;
"stop")
   for i in hadoop10 hadoop11 hadoop12
   do
   echo "============== $i kafka============== "
   ssh $i "/opt/module/kafka_2.11-2.4.1/bin/kafka-server-stop.sh"
   done
esac
