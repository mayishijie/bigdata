#!/bin/bash
case $1 in 
"start")
for i in hadoop12
do 
echo "----------$i $1 kafka to hdfs------------"
ssh $i "nohup /opt/module/apache-flume-1.9.0-bin/bin/flume-ng agent  -n a1 -f /opt/module/apache-flume-1.9.0-bin/job/kafka-flume-hdfs.conf -Dflume.root.logger=INFO,LOGFILE > /opt/module/apache-flume-1.9.0-bin/logs/flume.log.out 2>&1  &"
done
;;
"stop")
for i in hadoop12
do
ssh $i " ps -ef|grep kafka-flume-hdfs.conf|grep -v grep|awk   '{print \$2}'|xargs -n1 kill -9"
done
;;
esac
