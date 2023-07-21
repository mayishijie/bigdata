#!/bin/bash
for i in hadoop10 hadoop11 hadoop12
do 
 echo "------$i------------"
 ssh $i "date"
done

