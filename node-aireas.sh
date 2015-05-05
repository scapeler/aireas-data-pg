#!/bin/sh

cd `dirname $0`
node node-aireas.js >>$1 2>>$1
exit 0
