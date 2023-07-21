#! /bin/bash
for i in hadoop10 hadoop11
do
	echo "---------------$i start log--------------------"
	ssh $i "java -jar /opt/module/log-collector-1.0-SNAPSHOT-jar-with-dependencies.jar $1 $2 >/dev/null 2>&1 &"
done
