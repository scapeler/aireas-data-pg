#!/bin/bash

SYSTEMCODE="SCAPE604"
DATE=`date`

function checkRunning {
	PROCESSCR=$1
	SYSTEMCODECR=$2
	LOGNAMECR=$3
	RUNNINGCR=`/etc/init.d/$SYSTEMCODECR-$PROCESSCR status|grep "is running"`

        echo "Process: $PROCESSCR; Systemcode: $SYSTEMCODECR; Logname: $LOGNAMECR; Running: $RUNNINGCR"

	if [ "$RUNNINGCR" = "" ]; then
#		DATE=`date`
		JOBNOTKILLEDCR=`ps -ef | grep "$PROCESSCR.sh" | grep /bin/sh`
		echo "Job not killed: $JOBNOTKILLEDCR "
		if [ "$JOBNOTKILLEDCR" != "" ]; then
			echo "Killing job $PROCESSCR.sh"
			killall "$PROCESSCR.sh" 
		else
			echo "not killing job $PROCESSCR.sh"	
		fi
       		echo "Process start: $PROCESSCR  $DATE from /opt/$SYTEMCODECR/start-nodes.sh by crontab"     >> /opt/$SYSTEMCODECR/log/$LOGNAME
        	/etc/init.d/$SYSTEMCODECR-$PROCESSCR start >> /opt/$SYSTEMCODECR/log/$LOGNAME
	fi
}  

echo "Date: $DATE" 
/etc/init.d/SCAPE604-node-aireas status

checkRunning "node-aireas" $SYSTEMCODE node-aireas.log

/etc/init.d/SCAPE604-node-aireas status


