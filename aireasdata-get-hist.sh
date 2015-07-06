
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
/usr/local/bin/node index.js aireas-hist2json.js /opt/SCAPE604/aireas/aireas-hist/tmp/aireas-hist1_cal.txt >>$LOGFILE
/usr/local/bin/node index.js aireas-hist2json.js /opt/SCAPE604/aireas/aireas-hist/tmp/aireas-hist2_cal.txt >>$LOGFILE
/usr/local/bin/node index.js aireas-hist2json.js /opt/SCAPE604/aireas/aireas-hist/tmp/aireas-hist3_cal.txt >>$LOGFILE
/usr/local/bin/node index.js aireas-hist2json.js /opt/SCAPE604/aireas/aireas-hist/tmp/aireas-hist4_cal.txt >>$LOGFILE
/usr/local/bin/node index.js aireas-hist2json.js /opt/SCAPE604/aireas/aireas-hist/tmp/aireas-hist5_cal.txt >>$LOGFILE
/usr/local/bin/node index.js aireas-hist2json.js /opt/SCAPE604/aireas/aireas-hist/tmp/aireas-hist6_cal.txt >>$LOGFILE
/usr/local/bin/node index.js aireas-hist2json.js /opt/SCAPE604/aireas/aireas-hist/tmp/aireas-hist7_cal.txt >>$LOGFILE
/usr/local/bin/node index.js aireas-hist2json.js /opt/SCAPE604/aireas/aireas-hist/tmp/aireas-hist8_cal.txt >>$LOGFILE
/usr/local/bin/node index.js aireas-hist2json.js /opt/SCAPE604/aireas/aireas-hist/tmp/aireas-hist9_cal.txt >>$LOGFILE
/usr/local/bin/node index.js aireas-hist2json.js /opt/SCAPE604/aireas/aireas-hist/tmp/aireas-hist10_cal.txt >>$LOGFILE
/usr/local/bin/node index.js aireas-hist2json.js /opt/SCAPE604/aireas/aireas-hist/tmp/aireas-hist11_cal.txt >>$LOGFILE
/usr/local/bin/node index.js aireas-hist2json.js /opt/SCAPE604/aireas/aireas-hist/tmp/aireas-hist12_cal.txt >>$LOGFILE
/usr/local/bin/node index.js aireas-hist2json.js /opt/SCAPE604/aireas/aireas-hist/tmp/aireas-hist13_cal.txt >>$LOGFILE
/usr/local/bin/node index.js aireas-hist2json.js /opt/SCAPE604/aireas/aireas-hist/tmp/aireas-hist14_cal.txt >>$LOGFILE
/usr/local/bin/node index.js aireas-hist2json.js /opt/SCAPE604/aireas/aireas-hist/tmp/aireas-hist15_cal.txt >>$LOGFILE
/usr/local/bin/node index.js aireas-hist2json.js /opt/SCAPE604/aireas/aireas-hist/tmp/aireas-hist16_cal.txt >>$LOGFILE
/usr/local/bin/node index.js aireas-hist2json.js /opt/SCAPE604/aireas/aireas-hist/tmp/aireas-hist17_cal.txt >>$LOGFILE
/usr/local/bin/node index.js aireas-hist2json.js /opt/SCAPE604/aireas/aireas-hist/tmp/aireas-hist18_cal.txt >>$LOGFILE
/usr/local/bin/node index.js aireas-hist2json.js /opt/SCAPE604/aireas/aireas-hist/tmp/aireas-hist19_cal.txt >>$LOGFILE
/usr/local/bin/node index.js aireas-hist2json.js /opt/SCAPE604/aireas/aireas-hist/tmp/aireas-hist20_cal.txt >>$LOGFILE
/usr/local/bin/node index.js aireas-hist2json.js /opt/SCAPE604/aireas/aireas-hist/tmp/aireas-hist21_cal.txt >>$LOGFILE
/usr/local/bin/node index.js aireas-hist2json.js /opt/SCAPE604/aireas/aireas-hist/tmp/aireas-hist22_cal.txt >>$LOGFILE
/usr/local/bin/node index.js aireas-hist2json.js /opt/SCAPE604/aireas/aireas-hist/tmp/aireas-hist23_cal.txt >>$LOGFILE
/usr/local/bin/node index.js aireas-hist2json.js /opt/SCAPE604/aireas/aireas-hist/tmp/aireas-hist24_cal.txt >>$LOGFILE
/usr/local/bin/node index.js aireas-hist2json.js /opt/SCAPE604/aireas/aireas-hist/tmp/aireas-hist25_cal.txt >>$LOGFILE
/usr/local/bin/node index.js aireas-hist2json.js /opt/SCAPE604/aireas/aireas-hist/tmp/aireas-hist26_cal.txt >>$LOGFILE
/usr/local/bin/node index.js aireas-hist2json.js /opt/SCAPE604/aireas/aireas-hist/tmp/aireas-hist27_cal.txt >>$LOGFILE
/usr/local/bin/node index.js aireas-hist2json.js /opt/SCAPE604/aireas/aireas-hist/tmp/aireas-hist28_cal.txt >>$LOGFILE
/usr/local/bin/node index.js aireas-hist2json.js /opt/SCAPE604/aireas/aireas-hist/tmp/aireas-hist29_cal.txt >>$LOGFILE
/usr/local/bin/node index.js aireas-hist2json.js /opt/SCAPE604/aireas/aireas-hist/tmp/aireas-hist30_cal.txt >>$LOGFILE
/usr/local/bin/node index.js aireas-hist2json.js /opt/SCAPE604/aireas/aireas-hist/tmp/aireas-hist31_cal.txt >>$LOGFILE
/usr/local/bin/node index.js aireas-hist2json.js /opt/SCAPE604/aireas/aireas-hist/tmp/aireas-hist32_cal.txt >>$LOGFILE
/usr/local/bin/node index.js aireas-hist2json.js /opt/SCAPE604/aireas/aireas-hist/tmp/aireas-hist33_cal.txt >>$LOGFILE
/usr/local/bin/node index.js aireas-hist2json.js /opt/SCAPE604/aireas/aireas-hist/tmp/aireas-hist34_cal.txt >>$LOGFILE
/usr/local/bin/node index.js aireas-hist2json.js /opt/SCAPE604/aireas/aireas-hist/tmp/aireas-hist35_cal.txt >>$LOGFILE
/usr/local/bin/node index.js aireas-hist2json.js /opt/SCAPE604/aireas/aireas-hist/tmp/aireas-hist36_cal.txt >>$LOGFILE
/usr/local/bin/node index.js aireas-hist2json.js /opt/SCAPE604/aireas/aireas-hist/tmp/aireas-hist37_cal.txt >>$LOGFILE
/usr/local/bin/node index.js aireas-hist2json.js /opt/SCAPE604/aireas/aireas-hist/tmp/aireas-hist38_cal.txt >>$LOGFILE
/usr/local/bin/node index.js aireas-hist2json.js /opt/SCAPE604/aireas/aireas-hist/tmp/aireas-hist39_cal.txt >>$LOGFILE
/usr/local/bin/node index.js aireas-hist2json.js /opt/SCAPE604/aireas/aireas-hist/tmp/aireas-hist40_cal.txt >>$LOGFILE


#/usr/local/bin/node index.js aireas2sql.js >>$LOGFILE
#/usr/local/bin/node index.js aireas2grid.js >>$LOGFILE
#/usr/local/bin/node index.js aireas-signal.js >>$LOGFILE

echo "End   procedure on: " `date` >>$LOGFILE
