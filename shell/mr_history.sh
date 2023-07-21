#!/bin/bash
case $1 in
"start")
do
  echo "===========start mr-jobhistory-daemon=============="
  /opt/module/hadoop-3.1.3/sbin/mr-jobhistory-daemon.sh start
  done
  ;;
"stop")
do
  echo "===========start mr-jobhistory-daemon=============="
  /opt/module/hadoop-3.1.3/sbin/mr-jobhistory-daemon.sh stop
  done
;;
esac
