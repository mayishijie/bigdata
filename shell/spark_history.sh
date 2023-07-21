#!/bin/bash
case $1 in
"start"){
do
  echo "===========start-history-server=============="
  /opt/module/spark-2.4.5-bin-hadoop2.7/sbin/start-history-server.sh
  done
}
  ;;
"stop"){

do
  echo "===========stop-history-server.sh=============="
  /opt/module/spark-2.4.5-bin-hadoop2.7/sbin/stop-history-server.sh
  done
}
;;
esac
