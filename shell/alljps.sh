#!/bin/bash
for i in hadoop10 hadoop11 hadoop12
do 
	echo -----------$i----------------
	ssh $i "/opt/module/jdk1.8.0_212/bin/jps -ml"
done
