
##exit 0

SYSTEMCODE="SCAPE604"
SYSTEMPATH="/opt"

LOGFILE=$SYSTEMPATH/$SYSTEMCODE/log/aireas-hist-data.log
echo "Start procedure on: " `date` >>$LOGFILE

mkdir -p $SYSTEMPATH/$SYSTEMCODE/aireas/aireas-hist/tmp
mkdir -p $SYSTEMPATH/$SYSTEMCODE/log

#cd  $SYSTEMPATH/$SYSTEMCODE/scape-aireas
cd  $SYSTEMPATH/$SYSTEMCODE/aireas-data-pg
#/usr/local/bin/node index.js aireas-hist-data.js >>$LOGFILE
/usr/local/bin/node index.js aireas-hist2json.js /opt/SCAPE604/aireas/aireas-hist/tmp/aireas-hist25_cal.txt >>$LOGFILE

#/usr/local/bin/node index.js aireas2sql.js >>$LOGFILE
#/usr/local/bin/node index.js aireas2grid.js >>$LOGFILE
#/usr/local/bin/node index.js aireas-signal.js >>$LOGFILE

echo "End   procedure on: " `date` >>$LOGFILE
