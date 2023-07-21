#!/bin/bash

case $1 in
"start"){
    for i in hadoop10 hadoop11 hadoop12
    do
        echo "------------- $i -------------"
        ssh $i "/opt/module/apache-zookeeper-3.5.7-bin/bin/zkServer.sh start"
    done 
};;
"stop"){
    for i in hadoop10 hadoop11 hadoop12
    do
        echo "------------- $i -------------"
        ssh $i "/opt/module/apache-zookeeper-3.5.7-bin/bin/zkServer.sh stop"
    done
};;
"status"){
    for i in hadoop10 hadoop11 hadoop12
    do
        echo "------------- $i -------------"
        ssh $i "/opt/module/apache-zookeeper-3.5.7-bin/bin/zkServer.sh status"
    done
};;
esac
