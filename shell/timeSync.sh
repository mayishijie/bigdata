#!/bin/bash
ntpdate us.pool.ntp.org
[ $? == 0 ] && hwclock -w
