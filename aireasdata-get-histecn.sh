
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


/usr/local/bin/node index.js aireas-histecn2json.js 00 
sleep 20
/usr/local/bin/node index.js aireas-histecn2json.js 01 
sleep 20
/usr/local/bin/node index.js aireas-histecn2json.js 02 
sleep 20
/usr/local/bin/node index.js aireas-histecn2json.js 11
sleep 20
/usr/local/bin/node index.js aireas-histecn2json.js 12
sleep 20
/usr/local/bin/node index.js aireas-histecn2json.js 21
sleep 20
/usr/local/bin/node index.js aireas-histecn2json.js 22
sleep 20
/usr/local/bin/node index.js aireas-histecn2json.js 31
sleep 20
/usr/local/bin/node index.js aireas-histecn2json.js 32
sleep 20
/usr/local/bin/node index.js aireas-histecn2json.js 33 
sleep 20
/usr/local/bin/node index.js aireas-histecn2json.js 34 

#>>$LOGFILE

echo "End   procedure on: " `date` # >>$LOGFILE
