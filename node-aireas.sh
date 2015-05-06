#!/bin/sh

cd `dirname $0`
node node-aireas.js >>$1 2>>$1
exit 1  # unequal zero for respawn
