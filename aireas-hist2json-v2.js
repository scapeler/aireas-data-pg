/*
** Module: aireas-hist2json-v2
**
**
**
**
*/

/* This module accepts the API v2 from AiREAS

*/

// **********************************************************************************

var fs 		= require('fs');
var	path 	= require('path');
var pg 		= require('pg');

var aireasFolder, aireasUrl, aireasFileName, aireasLocalPathRoot, fileFolder, 
	tmpFolder, tmpFolderName, localPath, fileFolderName, resultsFolder, resultsFolderName;
var dataRecords;
var _files =[];
var _fileIndex = 0;
var executeFile;
var _tmpFolder;
//var client;

// **********************************************************************************

module.exports = {

	init: function (options) {

		executeFile = this.executeFile;
	
		sqlConnString = options.configParameter.databaseType + '://' + 
			options.configParameter.databaseAccount + ':' + 
			options.configParameter.databasePassword + '@' + 
			options.configParameter.databaseServer + '/' +
			options.systemCode + '_' + options.configParameter.databaseName;
		
		aireasLocalPathRoot = options.systemFolderParent+'/aireas/';
		fileFolderName 		= 'aireas-hist-v2';
		tmpFolderName 		= 'tmp';
		resultsFolderName 	= 'results';

		aireasFileName 		= 'aireas-hist-v2_';
//		aireasFileNameOutput= 'aireas.json';

		aireasFolder 		= aireasLocalPathRoot 	+ fileFolderName 	+ "/";
		tmpFolder 			= aireasFolder 			+ tmpFolderName 	+ "/";
		resultsFolder 		= aireasFolder 			+ resultsFolderName + "/";

		_tmpFolder			= tmpFolder;
		// create subfolders
		try {fs.mkdirSync(resultsFolder );} catch (e) {};//console.log('ERROR: no tmp folder found, batch run aborted.'); return } ;

//	    localPath 		= tmpFolder + aireasFileName;
//    	var _datFile	= fs.readFileSync(localPath);
//    	console.log("Local AiREAS data: " + localPath );

		
		

		fs.readdir(tmpFolder, function (err, files) {
    		if (err) {
        		throw err;
    		}
			_files = files;
			_fileIndex = 0;
    		/*files.map(function (file) {
        		return path.join(tmpFolder, file);
    		}).filter(function (file) {
        		return fs.statSync(file).isFile();
    		}).forEach(function (file) {
				//if (file == inFile) {
        		console.log("%s (%s)", file, path.extname(file));
				
				if (path.extname(file)=='') {
					console.log('not executed');
				} else {
					executeFile(file, path.extname(file));
				}
				//}
    		});
    		*/

//			client = new pg.Client(sqlConnString);
//			client.connect(function(err) {
//               	if(err) {
//                   	return console.error('could not connect to postgres', err);
//               	}
//				console.error('postgres connected');	
	    		executeFile(_files[_fileIndex],path.extname(_files[_fileIndex]));
//           }); //end of connect sql client
    		
		});


	},  // end of init
	
	
	executeFile: function(file, extention) {
		console.log(file);
		console.log(extention);
		console.log(file.substring(0,14));
		if (file.substring(0,14) !="aireas-hist-v2") {
			console.log("skip file");
			_fileIndex++;		
			executeFile(_files[_fileIndex],path.extname(_files[_fileIndex]));
		}
		var i, j, _dataRecord, _waardeDataRecord, inpRecordArray,
			inpRecordPM1, inpRecordPM25, inpRecordPM10, 
			inpRecordUFP, inpRecordOZON, inpRecordHUM, inpRecordCELC;


		var _datFile	= fs.readFileSync(path.join(_tmpFolder,file));
		var inRecord1 = "" + _datFile; //.toString();
		var inRecord = JSON.parse(inRecord1);
		
		//console.dir(inRecord.content);
		tmpArray = inRecord.content;
		
		if (tmpArray==null) return;
		
		dataRecords	= [];
		var outputFile = "";
		
		var executeSql = function  (query, callback) {
			console.log('sql start: ');
            var client = new pg.Client(sqlConnString);
            client.connect(function(err) {
               	if(err) {
                   	return console.error('could not connect to postgres', err);
               	}
				//console.log(query);
				//console.dir(client);
               	client.query(query, function(err, result) {
               		console.log('query uitgevoerd');
                   	if(err) {
						console.log('error running query ' + err + ' : ' + result);
						console.error('error running query', err);
						client.end();
                   		return;
            		}
            		console.log('sql result: ' + result);
            		client.end();
					callback(err,result);
            	});
            });
        };
		
		var sqlCallBack = function (err, result) {
			if (err) {
				console.log('ERROR:','sql error:', err, result);
			} else {
				console.log('Query','sql result:', result);
			}
            		_fileIndex++;
            		if (_fileIndex < _files.length) executeFile(_files[_fileIndex],path.extname(_files[_fileIndex]));
		};
		
		var convertGPS2LatLng = function(gpsValue){
			var degrees = Math.floor(gpsValue /100);
			var minutes = gpsValue - (degrees*100);
			var result  = degrees + (minutes /60);
			return result;
		};

	var writeFile = function(path, fileName, content ) {
		var _path = path;
		try {
			fs.mkdirSync(_path);
		} catch (e) {} ;
		fs.writeFileSync(_path + "/" + fileName, content);
	};
						
		
/* not for history data
		// find latest measured datetime, actual measurements can't be older than this datetime - 15 minutes. They maybe in maintenance or defect of ....
		var latestMeasureDate, tmpLatestMeasureDate, tmpLatestMeasureDateStr;
		tmpLatestMeasureDateStr = tmpArray[0].utctimestamp+'Z';
		latestMeasureDate = new Date(tmpLatestMeasureDateStr);
		for(i=0;i<tmpArray.length-1;i++) {  
			tmpLatestMeasureDateStr = tmpArray[i].utctimestamp+'Z';
			tmpLatestMeasureDate 	= new Date(tmpLatestMeasureDateStr);
			if (latestMeasureDate.getTime() < tmpLatestMeasureDate.getTime()) {
				latestMeasureDate = tmpLatestMeasureDate;
			}
		}
*/
		console.log("verwerk "+tmpArray.length+" records");
		for(i=0;i<tmpArray.length-1;i++) {  
//		for(i=0;i<10-1;i++) {  
			console.log(i);
			_waardeDataRecord	= tmpArray[i];	

			//skip if no measurements available
			if (_waardeDataRecord.readings_calibrated && _waardeDataRecord.when && _waardeDataRecord.when.measured && _waardeDataRecord.when.measured.$date) {
				// measurement values available
			} else {
				console.log('No measurement values available for airbox '+_waardeDataRecord.airbox_id);
				continue;
			}

			if (_waardeDataRecord.readings_calibrated.GPS) {
				// measurement values available
			} else {
				console.log('No GPS values available for airbox '+_waardeDataRecord.airbox_id);
				continue;
			}

			
/* not used in history data
			if (_waardeDataRecord.state != 'H' ) {
				console.log('Airbox state not equal "H" (skipped) for airbox '+_waardeDataRecord._id+ ' ' + _waardeDataRecord.state);
				continue;
			}  
*/

/* not for history data
			// skip if measureddate < latest date - 15 minutes
			tmpLatestMeasureDate 	= new Date(_waardeDataRecord.last_measurement.calibrated.when.$date);
			if (tmpLatestMeasureDate.getTime() < latestMeasureDate.getTime()- 54000000) {
			
				console.log('Measurement values too old for airbox '+_waardeDataRecord._id);
				continue;  // skip 'old' measurement
			}  
*/


			_dataRecord			= {};


			//if (_waardeDataRecord.name == '6.cal') continue;  //temporary skip because of wrong measurements
			/* reactivated on 2015-10-20 
			if (_waardeDataRecord.name == '4.cal') continue;  //temporary skip because of wrong measurements
			
			if (_waardeDataRecord.name == '23.cal') continue;  //temporary skip because of wrong measurements
			if (_waardeDataRecord.name == '29.cal') continue;  //temporary skip because of wrong measurements
			if (_waardeDataRecord.name == '37.cal') continue;  //temporary skip because of wrong measurements
			*/

			_dataRecord.airbox 	= _waardeDataRecord.airbox_id+'.cal';
			
			_dataRecord.retrievedDate 	= inRecord.retrievedDate;
			_dataRecord.measureDate 	= new Date(_waardeDataRecord.when.measured.$date).toISOString();
			_dataRecord.gpsLat 			= _waardeDataRecord.readings_calibrated.GPS.lat;
			_dataRecord.gpsLng 			= _waardeDataRecord.readings_calibrated.GPS.lon;
			_dataRecord.lat 			= convertGPS2LatLng(_waardeDataRecord.readings_calibrated.GPS.lat);
			_dataRecord.lng 			= convertGPS2LatLng(_waardeDataRecord.readings_calibrated.GPS.lon);
			_dataRecord.PM1 			= _waardeDataRecord.readings_calibrated.PM1;
			_dataRecord.PM25 			= _waardeDataRecord.readings_calibrated.PM25;
			_dataRecord.PM10 			= _waardeDataRecord.readings_calibrated.PM10;
			_dataRecord.UFP 			= _waardeDataRecord.readings_calibrated.UFP;
			_dataRecord.OZON 			= _waardeDataRecord.readings_calibrated.Ozon;
			_dataRecord.HUM 			= _waardeDataRecord.readings_calibrated.RelHum;
			_dataRecord.CELC 			= _waardeDataRecord.readings_calibrated.Temp;
			_dataRecord.NO2 			= _waardeDataRecord.readings_calibrated.NO2;
			_dataRecord.AMBHUM 			= _waardeDataRecord.readings_calibrated.AmbHum;
			_dataRecord.AMBTEMP 		= _waardeDataRecord.readings_calibrated.AmbTemp;
			

			_dataRecord.gpsLatFloat 	= _waardeDataRecord.readings_calibrated.GPS.lat;
			_dataRecord.gpsLngFloat		= _waardeDataRecord.readings_calibrated.GPS.lon;
			_dataRecord.PM1Float 		= _waardeDataRecord.readings_calibrated.PM1;
			_dataRecord.PM25Float 		= _waardeDataRecord.readings_calibrated.PM25;
			_dataRecord.PM10Float 		= _waardeDataRecord.readings_calibrated.PM10;
			_dataRecord.UFPFloat 		= _waardeDataRecord.readings_calibrated.UFP;
			if (_dataRecord.UFPFloat > 0) _dataRecord.UFPFloat = Math.round(_dataRecord.UFPFloat / 1000); // in units of 1000
			_dataRecord.OZONFloat 		= _waardeDataRecord.readings_calibrated.Ozon;
			_dataRecord.HUMFloat 		= _waardeDataRecord.readings_calibrated.RelHum;
			_dataRecord.CELCFloat 		= _waardeDataRecord.readings_calibrated.Temp;
			_dataRecord.NO2Float 		= _waardeDataRecord.readings_calibrated.NO2;
			_dataRecord.AMBHUMFloat 	= _waardeDataRecord.readings_calibrated.AmbHum;
			_dataRecord.AMBTEMPFloat 	= _waardeDataRecord.readings_calibrated.AmbTemp;

			//dataRecords.push(_dataRecord);
			
			
			outputRecord = "\nINSERT INTO aireas_hist ( airbox, retrieveddatechar, measuredatechar, retrieveddate, measuredate, " + 
				" gpslat, gpslng, lat, lng, pm1, pm25, pm10, ufp, ozon, hum, celc, no2, " + 
				" gpslatfloat, gpslngfloat, pm1float, pm25float, pm10float, ufpfloat, ozonfloat, humfloat, celcfloat, no2float, " + 
				" geom28992, geom ) \n VALUES (" +
					"'" + 	_dataRecord.airbox 			+ "', " +
					"'" + 	_dataRecord.retrievedDate 	+ "', " +
					"'" + 	_dataRecord.measureDate 	+ "', " +
					"'" +	_dataRecord.retrievedDate 	+ "', " + 	// timestamp with time zone,
					"'" + 	_dataRecord.measureDate		+ "', " +	// timestamp with time zone,
					"'" + 	_dataRecord.gpsLat 			+ "', " +
					"'" + 	_dataRecord.gpsLng 			+ "', " +
							_dataRecord.lat 			+ ", "  +
							_dataRecord.lng 			+ ", "  +
					"'" + 	_dataRecord.PM1 			+ "', " +
					"'" + 	_dataRecord.PM25 			+ "', " +
					"'" +	_dataRecord.PM10 			+ "', " +
					"'" + 	_dataRecord.UFP 			+ "', " +
					"'" + 	_dataRecord.OZON 			+ "', " +
					"'" + 	_dataRecord.HUM 			+ "', " +
					"'" + 	_dataRecord.CELC 			+ "', " +
					"'" + 	_dataRecord.NO2 			+ "', " +
							_dataRecord.gpsLatFloat 	+ ", "  +
							_dataRecord.gpsLngFloat 	+ ", "  +
							_dataRecord.PM1Float 		+ ", "  +
							_dataRecord.PM25Float 		+ ", "  +
							_dataRecord.PM10Float 		+ ", "  +
							_dataRecord.UFPFloat 		+ ", "  +
							_dataRecord.OZONFloat 		+ ", "  +
							_dataRecord.HUMFloat 		+ ", "  +
							_dataRecord.CELCFloat 		+ ", "  +
							_dataRecord.NO2Float 		+ ", "  +
							" ST_Transform(ST_SetSRID(ST_MakePoint(" + _dataRecord.lng + ", " + _dataRecord.lat + "), 4326), 28992 ), " +
							" ST_SetSRID(ST_MakePoint(" + _dataRecord.lng + ", " + _dataRecord.lat + "), 4326) );  \n ";
							
			//console.log('Output %s', outputRecord)				

			outputFile=outputFile.concat(outputRecord);
			

		}
		tmpArray=[];
		console.log(outputFile);
		outputFile=outputFile.concat('commit;\n');
		
		//writeFile (_tmpFolder, 'test'+file, outputFile );
		
		executeSql(outputFile, sqlCallBack);
		//outputFile = '';  // clear memory
	
//		this.createExportFile();

	}, // end of init

/*
	createExportFile: function () {
		var outputArray;
		var outputRecord;
		var inputRecord;
		var filePath;
		var outputFileJson;

		var currDate = new Date();
		var year = (currDate.getYear()+1900);

		var month = (currDate.getMonth()+1);
		var monthStr = "";
		if (month<10) {
			monthStr = "0" + month;
		} else {
			monthStr = "" + month;
		}

		var day = currDate.getDate();
		var dayStr = "";
		if (day<10) {
			dayStr = "0" + day;
		} else {
			dayStr = "" + day;
		}

		var hour = currDate.getHours();
		var hourStr = "";
		if (hour<10) {
			hourStr = "0" + hour;
		} else {
			hourStr = "" + hour;
		}

		var minute = currDate.getMinutes();
		var minuteStr = "";
		if (minute<10) {
			minuteStr = "0" + minute;
		} else {
			minuteStr = "" + minute;
		}



		filePath = resultsFolder + year + "/" + monthStr + "/" + dayStr + "/" + hourStr + "/" + minuteStr;


		try {fs.mkdirSync(resultsFolder + year + "/" );} catch (e) {} ;
		try {fs.mkdirSync(resultsFolder + year + "/" + monthStr + "/");} catch (e) {} ;
		try {fs.mkdirSync(resultsFolder + year + "/" + monthStr + "/" + dayStr + "/" );} catch (e) {} ;
		try {fs.mkdirSync(resultsFolder + year + "/" + monthStr + "/" + dayStr + "/"  + hourStr + "/");} catch (e) {} ;
		try {fs.mkdirSync(resultsFolder + year + "/" + monthStr + "/" + dayStr + "/" + hourStr + "/" + minuteStr);} catch (e) {} ;


		console.log("- creating: " , aireasFileNameOutput);
		outputFileJson = JSON.stringify(dataRecords);
		this.writeFile (filePath, aireasFileNameOutput, outputFileJson );


	},
*/




} // end of module.exports
