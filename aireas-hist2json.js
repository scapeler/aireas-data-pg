/*
** Module: aireas2json
**
**
**
**
*/

// **********************************************************************************

var fs 		= require('fs'),
	path = require("path");
var pg = require('pg');	

var aireasFolder, aireasUrl, aireasFileName, aireasLocalPathRoot, fileFolder, 
	tmpFolder, tmpFolderName, localPath, fileFolderName, resultsFolder, resultsFolderName;
var dataRecords;

// **********************************************************************************

module.exports = {

	init: function (options) {
	
		var inFile = process.argv[3];
	
		sqlConnString = options.configParameter.databaseType + '://' + 
			options.configParameter.databaseAccount + ':' + 
			options.configParameter.databasePassword + '@' + 
			options.configParameter.databaseServer + '/' +
			options.systemCode + '_' + options.configParameter.databaseName;
			
		aireasLocalPathRoot = options.systemFolderParent+'/aireas/';
		fileFolderName 		= 'aireas-hist';
		tmpFolderName 		= 'tmp';
		resultsFolderName 	= 'results';

		//aireasFileName 		= 'aireas.txt';
		aireasFileNameOutput= 'aireas.json';

		aireasFolder 		= aireasLocalPathRoot 	+ fileFolderName 	+ "/";
		tmpFolder 			= aireasFolder 			+ tmpFolderName 	+ "/";
		resultsFolder 		= aireasFolder 			+ resultsFolderName + "/";

		// create subfolders
		try {fs.mkdirSync(resultsFolder );} catch (e) {};//console.log('ERROR: no tmp folder found, batch run aborted.'); return } ;

		var executeFile = this.executeFile;
		
		fs.readdir(tmpFolder, function (err, files) {
    		if (err) {
        		throw err;
    		}

    		files.map(function (file) {
        		return path.join(tmpFolder, file);
    		}).filter(function (file) {
        		return fs.statSync(file).isFile();
    		}).forEach(function (file) {
				if (file == inFile) {
        		console.log("%s (%s)", file, path.extname(file));
				executeFile(file, path.extname(file))
				}
    		});
		});

	}, // end of init


	executeFile: function(file, extention) {
	

		var convertGPS2LatLng = function(gpsValue){
			var degrees = Math.floor(gpsValue /100);
			var minutes = gpsValue - (degrees*100);
			var result  = degrees + (minutes /60);
			return result;
		};
		
		var	createExportFile = function () {

		var outputArray;
		var outputRecord;
		var inputRecord;
		var filePath;
		var outputFileJson;

/*
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
*/


//		filePath = resultsFolder + year + "/" + monthStr + "/" + dayStr + "/" + hourStr + "/" + minuteStr;
		filePath = resultsFolder;


//		try {fs.mkdirSync(resultsFolder + year + "/" );} catch (e) {} ;
//		try {fs.mkdirSync(resultsFolder + year + "/" + monthStr + "/");} catch (e) {} ;
//		try {fs.mkdirSync(resultsFolder + year + "/" + monthStr + "/" + dayStr + "/" );} catch (e) {} ;
//		try {fs.mkdirSync(resultsFolder + year + "/" + monthStr + "/" + dayStr + "/"  + hourStr + "/");} catch (e) {} ;
//		try {fs.mkdirSync(resultsFolder + year + "/" + monthStr + "/" + dayStr + "/" + hourStr + "/" + minuteStr);} catch (e) {} ;


		console.log("- creating: " , aireasFileNameOutput);
		outputFileJson = JSON.stringify(dataRecords);
//		this.writeFile (filePath, aireasFileNameOutput, outputFileJson );
		//writeFile (filePath, aireasFileNameOutput, outputFileJson );
		createSqlAireas(dataRecords);

	}

//	convertGPS2LatLng: function(gpsValue){
//		var degrees = Math.floor(gpsValue /100);
//		var minutes = gpsValue - (degrees*100);
//		var result  = degrees + (minutes /60);
//		return result;
//	},

		var writeFile = function(path, fileName, content ) {
			var _path = path;
			try {
				fs.mkdirSync(_path);
			} catch (e) {} ;
			fs.writeFileSync(_path + "/" + fileName, content);
		};
		
		
		var createSqlAireas = function(inputFileJson , outputFilePath) {
		
		var i;

// 		var inputFile = JSON.parse(inputFileJson);
 		var inputFile = inputFileJson;
		var outputFile = "";

	        var executeSql = function  (query, callback) {
        	        console.log('sql start: ');
                	var client = new pg.Client(sqlConnString);
                	client.connect(function(err) {
                        	if(err) {
                                	return console.error('could not connect to postgres', err);
                        	}
                        	client.query(query, function(err, result) {
                                	if(err) {
										console.log('error running query ' + query);
                                	return console.error('error running query', err);
                        	}
                        	console.log('sql result: ' + result);
                        	client.end();
                        	});
                	});
        	};

		var sqlCallBack = function (err, result) {
			if (err) {
				console.log('ERROR:','sql error:', err, result);
			} else {
				//console.log('Query','sql result:', result);
			}
		};

  //      	var writeFile = function(fileContent, filepath ) {
   //             	var _path = filepath;
   //             	fs.writeFileSync(_path, fileContent);
   //     	};


		for (i=0;i<inputFile.length;i++) {

			var inputRecord = inputFile[i];
			var outputRecord = "";

			//var _measureDate		 			= inputRecord.measureDate==""?"null":"'"+inputRecord.measureDate + "', ";


			outputRecord = "\nINSERT INTO aireas_hist ( airbox, retrieveddatechar, measuredatechar, retrieveddate, measuredate, " + 
				" gpslat, gpslng, lat, lng, pm1, pm25, pm10, ufp, ozon, hum, celc, no2, " + 
				" gpslatfloat, gpslngfloat, pm1float, pm25float, pm10float, ufpfloat, ozonfloat, humfloat, celcfloat, no2float, " + 
				" geom28992, geom ) VALUES (" +
					"'" + 	inputRecord.airbox 			+ "', " +
					"'" + 	inputRecord.retrievedDate 	+ "', " +
					"'" + 	inputRecord.measureDate 	+ "', " +
					"'" +	inputRecord.retrievedDate 	+ "', " + 	// timestamp with time zone,
					"'" + 	inputRecord.measureDate		+ "', " +	// timestamp with time zone,
					"'" + 	inputRecord.gpsLat 			+ "', " +
					"'" + 	inputRecord.gpsLng 			+ "', " +
							inputRecord.lat 			+ ", "  +
							inputRecord.lng 			+ ", "  +
					"'" + 	inputRecord.PM1 			+ "', " +
					"'" + 	inputRecord.PM25 			+ "', " +
					"'" +	inputRecord.PM10 			+ "', " +
					"'" + 	inputRecord.UFP 			+ "', " +
					"'" + 	inputRecord.OZON 			+ "', " +
					"'" + 	inputRecord.HUM 			+ "', " +
					"'" + 	inputRecord.CELC 			+ "', " +
					"'" + 	inputRecord.NO2 			+ "', " +
							inputRecord.gpsLatFloat 	+ ", "  +
							inputRecord.gpsLngFloat 	+ ", "  +
							inputRecord.PM1Float 		+ ", "  +
							inputRecord.PM25Float 		+ ", "  +
							inputRecord.PM10Float 		+ ", "  +
							inputRecord.UFPFloat 		+ ", "  +
							inputRecord.OZONFloat 		+ ", "  +
							inputRecord.HUMFloat 		+ ", "  +
							inputRecord.CELCFloat 		+ ", "  +
							inputRecord.NO2Float 		+ ", "  +
							" ST_Transform(ST_SetSRID(ST_MakePoint(" + inputRecord.lng + ", " + inputRecord.lat + "), 4326), 28992 ), " +
							" ST_SetSRID(ST_MakePoint(" + inputRecord.lng + ", " + inputRecord.lat + "), 4326) );  \n ";
							
			//console.log('Output %s', outputRecord)				

			outputFile=outputFile.concat(outputRecord);
			
			console.log(outputRecord);
		}
	console.log('Write: ' + outputFilePath);	
		//writeFile(outputFile, outputFilePath);
		executeSql(outputFile, sqlCallBack);
		outputFile = null;  // clear memory

	};


		
		
		
		
		
		
		

		
//		localPath 		= tmpFolder + aireasFileName;
		var localPath 		= file;
    	console.log("Local AiREAS data: " + localPath );

    	var _datFile	= fs.readFileSync(localPath);


		var i, j, _dataRecord, _waardeDataRecord, inpRecordArray,
			inpRecordPM1, inpRecordPM25, inpRecordPM10, 
			inpRecordUFP, inpRecordOZON, inpRecordHUM, inpRecordCELC;

		
//		var inRecord1 = "" + _datFile.toString();
//		var inRecord2 = inRecord1.replace(/\'/g,'"');
//		var inRecord = JSON.parse(inRecord2);
		
		var records1 = ""+_datFile;	
		var records2 = records1.split('\n');
		
		console.log('Aantal records:' + records2.length)
		
//		{"airbox": "39_cal", "retrievedDate": "2015-07-06T18:57:06.596Z", "content":

		var firstRecParts = records2[0].split(',');
		var firstRecJson = firstRecParts[0] + ', '+ firstRecParts[1] + '} ';
		console.log(firstRecJson);
		var firstRec = JSON.parse(firstRecJson);
		console.log('Verwerk airbox %s van retrievedate %s', firstRec.airbox, firstRec.retrievedDate );
		

//		console.log(inRecord);
//		console.log(inRecord.airboxes);
//		console.log(inRecord.airboxes[0]);
		
		
//		tmpArray = inRecord.content.airboxes;
		tmpArray = records2;

/*
		var tmp0 = _datFile.toString();
		var dateRetrievedLength = tmp0.indexOf(' ');
		var dateRetrieved = tmp0.substring(0, dateRetrievedLength);
		var dateRetrievedDate = Date.parse(dateRetrieved);
		console.log('x'+dateRetrieved+'x');
		var tmp1 = tmp0.substr(dateRetrievedLength+1);
		//var tmp2 = tmp1.replace(/<p>/g,'');
		//var tmp3 = tmp2.replace(/<\/p>/g,'');
		//var tmpArray = tmp3.split(')');
		var tmp2 = tmp1.replace(/\[/,'');
		var tmpArray = tmp3.split('],');
*/		

		dataRecords	= [];

		// Let op skip first and last record(s) for now!
		console.log('Aantal records: ' + tmpArray.length);
		
		for ( i=1; i<tmpArray.length-2;i++) {
			if (i>tmpArray.length - 5) {
				console.log(' %n %s ', i, _waardeDataRecord[9] );
			}  
//			inpRecordArray 		= tmpArray[i].split(':(');
//			inpRecordArray 		= tmpArray[i].split('[');
			//inpRecordArray 		= tmpArray[i];
			inpRecordArray 		= tmpArray[i].split(',');
			
			
//			console.log(inpRecordArray);

			_dataRecord			= {};
//			_dataRecord.airBox	= inpRecordArray[0];
			_dataRecord.airbox	= firstRec.airbox;
			
//			inpMetingenArray 	= inpRecordArray[1].split(',');
			_waardeDataRecord	= inpRecordArray;	
			
//			_waardeDataRecord 	= [];
//			for(j=0;j<inpMetingenArray.length;j++) {
//				_waardeDataRecord[j] = inpRecordArray[j];// parseFloat(inpMetingenArray[j]);
//			}
						
			//_dataRecord.airbox 	= _waardeDataRecord[0];
			
//			console.log(_dataRecord.airbox);

			if (_waardeDataRecord[0] == 'EAST') continue;
			
			console.log(_waardeDataRecord.length);
			
			if (_waardeDataRecord.length>10) { 
			
				_dataRecord.retrievedDate 	= firstRec.retrievedDate;
				_dataRecord.measureDate 	= '' + _waardeDataRecord[9];
				_dataRecord.gpsLat 	= _waardeDataRecord[11];
				_dataRecord.gpsLng 	= _waardeDataRecord[12];
				_dataRecord.lat 	= convertGPS2LatLng(_waardeDataRecord[11]);
				_dataRecord.lng 	= convertGPS2LatLng(_waardeDataRecord[12]);
				_dataRecord.OZON 	= _waardeDataRecord[2];
				_dataRecord.PM10 	= _waardeDataRecord[3];
				_dataRecord.PM1 	= _waardeDataRecord[4];
				_dataRecord.PM25 	= _waardeDataRecord[5];
				_dataRecord.HUM 	= _waardeDataRecord[6];
				_dataRecord.CELC 	= _waardeDataRecord[7];
				_dataRecord.UFP 	= _waardeDataRecord[8];
				_dataRecord.NO2 	= _waardeDataRecord[10]; //_waardeDataRecord[9];

				_dataRecord.gpsLatFloat = parseFloat(_waardeDataRecord[11]);
				_dataRecord.gpsLngFloat	= parseFloat(_waardeDataRecord[12]);
				_dataRecord.OZONFloat 	= parseFloat(_waardeDataRecord[2]);
				_dataRecord.PM10Float 	= parseFloat(_waardeDataRecord[3]);
				_dataRecord.PM1Float 	= parseFloat(_waardeDataRecord[4]);
				_dataRecord.PM25Float 	= parseFloat(_waardeDataRecord[5]);
				_dataRecord.HUMFloat 	= parseFloat(_waardeDataRecord[6]);
				_dataRecord.CELCFloat 	= parseFloat(_waardeDataRecord[7]);
				_dataRecord.UFPFloat 	= parseFloat(_waardeDataRecord[8]);
				if (_dataRecord.UFPFloat > 0) _dataRecord.UFPFloat = Math.round(_dataRecord.UFPFloat / 1000); // in units of 1000
				_dataRecord.NO2Float 	= parseFloat(_waardeDataRecord[10]);; //parseFloat(_waardeDataRecord[9]);

				dataRecords.push(_dataRecord);
				continue;
			}
			
			
		if (firstRec.airbox == '26.cal' || firstRec.airbox == '35.cal') {  // andere recordindeling
			_dataRecord.retrievedDate 	= firstRec.retrievedDate;
			_dataRecord.measureDate 	= '' + _waardeDataRecord[9];
			_dataRecord.gpsLat 	= _waardeDataRecord[1];
			_dataRecord.gpsLng 	= _waardeDataRecord[0];
			_dataRecord.lat 	= convertGPS2LatLng(_waardeDataRecord[1]);
			_dataRecord.lng 	= convertGPS2LatLng(_waardeDataRecord[0]);
			_dataRecord.OZON 	= _waardeDataRecord[2];
			_dataRecord.PM10 	= _waardeDataRecord[3];
			_dataRecord.PM1 	= _waardeDataRecord[4];
			_dataRecord.PM25 	= _waardeDataRecord[5];
			_dataRecord.HUM 	= _waardeDataRecord[6];
			_dataRecord.CELC 	= _waardeDataRecord[7];
			_dataRecord.UFP 	= _waardeDataRecord[8];
			_dataRecord.NO2 	= 0; //_waardeDataRecord[9];

			_dataRecord.gpsLatFloat = parseFloat(_waardeDataRecord[1]);
			_dataRecord.gpsLngFloat	= parseFloat(_waardeDataRecord[0]);
			_dataRecord.OZONFloat 	= parseFloat(_waardeDataRecord[2]);
			_dataRecord.PM10Float 	= parseFloat(_waardeDataRecord[3]);
			_dataRecord.PM1Float 	= parseFloat(_waardeDataRecord[4]);
			_dataRecord.PM25Float 	= parseFloat(_waardeDataRecord[5]);
			_dataRecord.HUMFloat 	= parseFloat(_waardeDataRecord[6]);
			_dataRecord.CELCFloat 	= parseFloat(_waardeDataRecord[7]);
			_dataRecord.UFPFloat 	= parseFloat(_waardeDataRecord[8]);
			if (_dataRecord.UFPFloat > 0) _dataRecord.UFPFloat = Math.round(_dataRecord.UFPFloat / 1000); // in units of 1000
			_dataRecord.NO2Float 	= 0; //parseFloat(_waardeDataRecord[9]);

			dataRecords.push(_dataRecord);
			continue;
		}
		
//		 else {
			_dataRecord.retrievedDate 	= firstRec.retrievedDate;
			_dataRecord.measureDate 	= '' + _waardeDataRecord[9];
			_dataRecord.gpsLat 	= _waardeDataRecord[1];
			_dataRecord.gpsLng 	= _waardeDataRecord[0];
			_dataRecord.lat 	= convertGPS2LatLng(_waardeDataRecord[1]);
			_dataRecord.lng 	= convertGPS2LatLng(_waardeDataRecord[0]);
			_dataRecord.PM1 	= _waardeDataRecord[5];
			_dataRecord.PM25 	= _waardeDataRecord[6];
			_dataRecord.PM10 	= _waardeDataRecord[4];
			_dataRecord.UFP 	= _waardeDataRecord[2];
			_dataRecord.OZON 	= _waardeDataRecord[3];
			_dataRecord.HUM 	= _waardeDataRecord[7];
			_dataRecord.CELC 	= _waardeDataRecord[8];
			_dataRecord.NO2 	= 0; //_waardeDataRecord[9];

			_dataRecord.gpsLatFloat = parseFloat(_waardeDataRecord[1]);
			_dataRecord.gpsLngFloat	= parseFloat(_waardeDataRecord[0]);
			_dataRecord.PM1Float 	= parseFloat(_waardeDataRecord[5]);
			_dataRecord.PM25Float 	= parseFloat(_waardeDataRecord[6]);
			_dataRecord.PM10Float 	= parseFloat(_waardeDataRecord[4]);
			_dataRecord.UFPFloat 	= parseFloat(_waardeDataRecord[2]);
			if (_dataRecord.UFPFloat > 0) _dataRecord.UFPFloat = Math.round(_dataRecord.UFPFloat / 1000); // in units of 1000
			_dataRecord.OZONFloat 	= parseFloat(_waardeDataRecord[3]);
			_dataRecord.HUMFloat 	= parseFloat(_waardeDataRecord[7]);
			_dataRecord.CELCFloat 	= parseFloat(_waardeDataRecord[8]);
			_dataRecord.NO2Float 	= 0; //parseFloat(_waardeDataRecord[9]);
//		}

//			if (_waardeDataRecord[0] == 'EAST' || _waardeDataRecord[0] == '0.0') {  // header record or no lng value
				//console.log('skip record');
//			} else {
				dataRecords.push(_dataRecord);
//			}
		}
	
		createExportFile();
	
	},




} // end of module.exports
