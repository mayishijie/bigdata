#!/bin/bash
for i in nn1 nn2 nn3
do
 hdfs haadmin -getServiceState $i
done
