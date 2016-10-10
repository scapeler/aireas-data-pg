
##exit 0

SYSTEMCODE="SCAPE604"
SYSTEMPATH="/opt"

LOGFILE=$SYSTEMPATH/$SYSTEMCODE/log/aireas-hist-data.log
echo "Start procedure on: " `date` >>$LOGFILE

mkdir -p $SYSTEMPATH/$SYSTEMCODE/aireas/aera
mkdir -p $SYSTEMPATH/$SYSTEMCODE/log

#cd  $SYSTEMPATH/$SYSTEMCODE/scape-aireas
cd  $SYSTEMPATH/$SYSTEMCODE/aireas-data-pg
#/usr/local/bin/node index.js aireas-hist-data.js >>$LOGFILE


/usr/local/bin/node index.js aireas-aera2sql.js aera-airport-201607 
#sleep 10

#>>$LOGFILE

echo "End   procedure on: " `date` # >>$LOGFILE
