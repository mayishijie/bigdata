#!/bin/bash
for i in hadoop10 hadoop11 hadoop12
do
    echo "========== $i =========="
    ssh -t $i "sudo date -s $1"
done
