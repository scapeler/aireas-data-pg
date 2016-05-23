
##exit 0

SYSTEMCODE=SCAPE604
SYSTEMPATH=/opt/$SYSTEMCODE/

LOGFILE=$SYSTEMPATH/$SYSTEMCODE/log/aireas-data.log
echo "Start procedure on: " `date` >>$LOGFILE

mkdir -p $SYSTEMPATH/$SYSTEMCODE/aireas/aireas/tmp
mkdir -p $SYSTEMPATH/$SYSTEMCODE/log

cd  $SYSTEMPATH/$SYSTEMCODE/scape-aireas
/usr/local/bin/node index.js aireas-data-v2.js >>$LOGFILE
/usr/local/bin/node index.js aireas2json-v2.js >>$LOGFILE
/usr/local/bin/node index.js aireas2sql-v2.js >>$LOGFILE
/usr/local/bin/node index.js aireas2grid.js >>$LOGFILE
/usr/local/bin/node index.js aireas-signal.js >>$LOGFILE

echo "End   procedure on: " `date` >>$LOGFILE
