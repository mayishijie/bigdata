#!/bin/bash 
es_home=/opt/module/es/elasticsearch-6.6.0
kibana_home=/opt/module/es/kibana-6.6.0-linux-x86_64

case $1  in
 "start") {
  for i in hadoop10 hadoop11 hadoop12
  do
    ssh $i  "source /etc/profile;${es_home}/bin/elasticsearch >/dev/null 2>&1 &"
 
   done
   nohup ${kibana_home}/bin/kibana >/opt/module/es/kibana-6.6.0-linux-x86_64/logs/kibana.log 2>&1 &
};;
"stop") {
  ps -ef|grep ${kibana_home} |grep -v grep|awk '{print $2}'|xargs kill
  for i in hadoop10 hadoop11 hadoop12
  do
      ssh $i "ps -ef|grep $es_home |grep -v grep|awk '{print \$2}'|xargs kill" >/dev/null 2>&1
  done
  
};;

esac
