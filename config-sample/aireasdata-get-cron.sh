
##exit 0

SYSTEMCODE="SCAPE604"
SYSTEMPATH="/opt"

LOGFILE=$SYSTEMPATH/$SYSTEMCODE/log/aireas-data.log
echo "Start procedure on: " `date` >>$LOGFILE

mkdir -p $SYSTEMPATH/$SYSTEMCODE/aireas/aireas/tmp
mkdir -p $SYSTEMPATH/$SYSTEMCODE/log

cd  $SYSTEMPATH/$SYSTEMCODE/scape-aireas
/usr/local/sbin/node index.js aireas-data >>$LOGFILE
/usr/local/sbin/node index.js aireas2json.js >>$LOGFILE
/usr/local/sbin/node index.js aireas2sql.js >>$LOGFILE 2>>$LOGFILE
/usr/local/sbin/node index.js aireas2grid.js >>$LOGFILE
/usr/local/sbin/node index.js aireas-signal.js >>$LOGFILE

echo "End   procedure on: " `date` >>$LOGFILE
