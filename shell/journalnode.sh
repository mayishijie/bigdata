#!/bin/bash
case $1 in
"start"){
  for i in hadoop10 hadoop11 hadoop12
  do
      echo "----------$i-------------"
      ssh $i "/opt/module/hadoop-3.1.3/bin/hdfs --daemon start journalnode"
  done
};;
"stop"){
  for i in hadoop10 hadoop11 hadoop12
  do
      echo "----------$i-------------"
      ssh $i "/opt/module/hadoop-3.1.3/bin/hdfs --daemon stop journalnode"
  done
};;
"status"){
  for i in hadoop10 hadoop11 hadoop12
  do
      echo "----------$i-------------"
      ssh $i "/opt/module/hadoop-3.1.3/bin/hdfs --daemon status journalnode"
  done
};;
esac
