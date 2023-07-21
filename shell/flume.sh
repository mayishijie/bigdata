#!/bin/bash
case $1 in
"start") {
  for i in hadoop10 hadoop11;
  do
    echo " --------启动 $i 采集flume-------"
    ssh $i "nohup /opt/module/apache-flume-1.9.0-bin/bin/flume-ng agent --conf-file /opt/module/apache-flume-1.9.0-bin/job/file_flume_kafka.conf --name a1 -Dflume.root.logger=INFO,LOGFILE > /opt/module/apache-flume-1.9.0-bin/flume.log.out  2>&1  &"
  done
} ;;
"stop") {
  for i in hadoop10 hadoop11; do
    echo " --------停止 $i 采集flume-------"
    ssh $i "ps -ef | grep file_flume_kafka.conf | grep -v grep |awk  '{print \$2}' | xargs -n1 kill -9 "
  done

} ;;
esac

