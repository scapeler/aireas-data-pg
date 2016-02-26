/*
** Module: aireas-histecn2json
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
var airboxName;	
var dataRecords;

// **********************************************************************************

 module.exports = {

	init: function (options) {
	
		var inSubFolder = process.argv[3];
	
		sqlConnString = options.configParameter.databaseType + '://' + 
			options.configParameter.databaseAccount + ':' + 
			options.configParameter.databasePassword + '@' + 
			options.configParameter.databaseServer + '/' +
			options.systemCode + '_' + options.configParameter.databaseName;
			

		aireasLocalPathRoot = options.systemFolderParent +'/../ECNaireasdata' + '/aireas/';
//		aireasLocalPathRoot = options.systemFolderParent+'/aireas/';
		fileFolderName 		= 'aireas-histecn';
		tmpFolderName 		= 'tmp_2014/' + inSubFolder;
		resultsFolderName 	= 'results';

		//aireasFileName 		= 'aireas.txt';
//		aireasFileNameOutput= 'aireas.json';

		aireasFolder 		= aireasLocalPathRoot 	+ fileFolderName 	+ "/";
		tmpFolder 			= aireasFolder 			+ tmpFolderName 	+ "/";
		resultsFolder 		= aireasFolder 			+ resultsFolderName + "/";

		// create subfolders
		try {fs.mkdirSync(resultsFolder );} catch (e) {};//console.log('ERROR: no tmp folder found, batch run aborted.'); return } ;

		var executeFile = this.executeFile;
		
		console.log(tmpFolder);
		
		fs.readdir(tmpFolder, function (err, files) {
    		if (err) {
        		throw err;
    		}
//			console.log(files);
    		files.map(function (file) {
				console.log(file);
        		return path.join(tmpFolder, file);
    		}).filter(function (file) {
				if (file == '/Users/awiel/projects/ECNaireasdata/aireas/aireas-histecn/tmp/.DS_Store') return false;
        		return fs.statSync(file).isFile();
    		}).forEach(function (file) {
				//if (file == inFile) {
        		console.log("%s (%s)", file, path.extname(file));
				executeFile(file, path.extname(file))
				//}
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
//			var outputFileJson;

//			filePath = resultsFolder + year + "/" + monthStr + "/" + dayStr + "/" + hourStr + "/" + minuteStr;
			filePath = resultsFolder;


//			try {fs.mkdirSync(resultsFolder + year + "/" );} catch (e) {} ;
//			try {fs.mkdirSync(resultsFolder + year + "/" + monthStr + "/");} catch (e) {} ;
//			try {fs.mkdirSync(resultsFolder + year + "/" + monthStr + "/" + dayStr + "/" );} catch (e) {} ;
//			try {fs.mkdirSync(resultsFolder + year + "/" + monthStr + "/" + dayStr + "/"  + hourStr + "/");} catch (e) {} ;
//			try {fs.mkdirSync(resultsFolder + year + "/" + monthStr + "/" + dayStr + "/" + hourStr + "/" + minuteStr);} catch (e) {} ;


//			console.log("- creating: " , aireasFileNameOutput);
//			outputFileJson = JSON.stringify(dataRecords);
//			this.writeFile (filePath, aireasFileNameOutput, outputFileJson );
			//writeFile (filePath, aireasFileNameOutput, outputFileJson );
			
			//console.log('createSqlAireas:start');
			createSqlAireas(dataRecords, filePath);

		}


		var writeFile = function(path, fileName, content ) {
			var _path = path;
			try {
				fs.mkdirSync(_path);
			} catch (e) {} ;
			fs.writeFileSync(_path + "/" + fileName, content);
		};
		
		
		var createSqlAireas = function(inputFileJson , outputFilePath) {
		
			var i;
			console.log( ' \n\n ');

// 			var inputFile = JSON.parse(inputFileJson);
 			var inputFile = inputFileJson;
			var outputFile = "";
			
			var _parseFloat = function(input) {
				if (input) return parseFloat(input.replace(',', '.'));
				return null;
			}

	        var executeSql = function  (query, callback) {
        	        console.log('sql start: ');
                	var client = new pg.Client(sqlConnString);
                	client.connect(function(err) {
                        	if(err) {
                            	return console.error('could not connect to postgres', err);
                        	}
                        	client.query(query, function(err, result) {
                                	if(err) {
										console.log('error running query ' + err + ' : ' + result);
										console.error('error running query', err);
										client.end();
                                		return;
                        			}
                        			//console.log('sql result: ' + result);
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
   
   
   			var toprecord1 = inputFile[0];
			var toprecord2 = inputFile[1];
			var toprecord3 = inputFile[2];
			
			var recordType = 0;
			
			var toprecord1Cols = toprecord1.split(';');
			
			var airboxId = '';
			if (toprecord1Cols.length > 5) { //not an empty record
				airboxId = toprecord1Cols[2].replace(/\"/g,'');
			};
			
			
			if (toprecord2 == '"Tijd";"Tijd";"Temperatuur";"Luchtvochtigheid";"Lat";"Lon";"PM1";"PM2.5";"PM10";"Ozon"') {
				if (toprecord3 == '"UTC";"Lokaal";"°C";"%";"°";"°";"μg/m³";"μg/m³";"μg/m³";"μg/m³"') {
					recordType = 1; //default
				}
			};
				
			if (toprecord2 == '"Tijd";"Tijd";"UFP";"Temperatuur";"Luchtvochtigheid";"Lat";"Lon";"PM1";"PM2.5";"PM10"') {
				if (toprecord3 == '"UTC";"Lokaal";"Counts/cm³";"°C";"%";"°";"°";"μg/m³";"μg/m³";"μg/m³"') {
					recordType = 2; //default
				}
			};	

			if (toprecord2 == '"Tijd";"Tijd";"UFP";"Temperatuur ext";"Temperatuur";"Luchtvochtigheid ext";"Luchtvochtigheid";"Lat";"Lon";"PM1";"PM2.5";"PM10";"Ozon"') {
				if (toprecord3 == '"UTC";"Lokaal";"Counts/cm³";"°C";"°C";"%";"%";"°";"°";"μg/m³";"μg/m³";"μg/m³";"μg/m³"') {
					recordType = 3; //default
				}
			};
				
			if (toprecord2 == '"Tijd";"Tijd";"UFP";"Temperatuur";"Luchtvochtigheid";"Lat";"Lon";"PM1";"PM2.5";"PM10";"Ozon"') {
				if (toprecord3 == '"UTC";"Lokaal";"Counts/cm³";"°C";"%";"°";"°";"μg/m³";"μg/m³";"μg/m³";"μg/m³"') {
					recordType = 4; //default
				}
			};
							
			if (toprecord2 == '"Tijd";"Tijd";"Temperatuur ext";"Temperatuur";"Luchtvochtigheid ext";"Luchtvochtigheid";"Lat";"Lon";"PM1";"PM2.5";"PM10";"Ozon"') {
				if (toprecord3 == '"UTC";"Lokaal";"°C";"°C";"%";"%";"°";"°";"μg/m³";"μg/m³";"μg/m³";"μg/m³"') {
					recordType = 5; //default
				}
			};	
			
			if (toprecord2 == '"Tijd";"Tijd";"Temperatuur ext";"Temperatuur";"Luchtvochtigheid ext";"Luchtvochtigheid";"Lat";"Lon";"PM1";"PM2.5";"PM10"') {
				if (toprecord3 == '"UTC";"Lokaal";"°C";"°C";"%";"%";"°";"°";"μg/m³";"μg/m³";"μg/m³"') {
					recordType = 6; //default
				}
			};
				
			if (toprecord2 == '"Tijd";"Tijd";"UFP";"Temperatuur ext";"Temperatuur";"Luchtvochtigheid ext";"Luchtvochtigheid";"Lat";"Lon";"PM1";"PM2.5";"PM10"') {
				if (toprecord3 == '"UTC";"Lokaal";"Counts/cm³";"°C";"°C";"%";"%";"°";"°";"μg/m³";"μg/m³";"μg/m³"') {
					recordType = 7; //default
				}
			};	

			if (toprecord2 == '"Tijd";"Tijd";"Temperatuur ext";"Temperatuur";"Luchtvochtigheid ext";"Luchtvochtigheid";"Lat";"Lon";"PM1";"PM2.5";"PM10";"Ozon";"NO2"') {
				if (toprecord3 == '"UTC";"Lokaal";"°C";"°C";"%";"%";"°";"°";"μg/m³";"μg/m³";"μg/m³";"μg/m³";"μg/m³"') {
					recordType = 8; //default
				}
			};
				
			if (toprecord2 == '"Tijd";"Tijd";"UFP";"Temperatuur ext";"Temperatuur";"Luchtvochtigheid ext";"Luchtvochtigheid";"Lat";"Lon";"PM1";"PM2.5";"PM10";"Ozon";"NO2"') {
				if (toprecord3 == '"UTC";"Lokaal";"Counts/cm³";"°C";"°C";"%";"%";"°";"°";"μg/m³";"μg/m³";"μg/m³";"μg/m³";"μg/m³"') {
					recordType = 9; //default
				}
			};	
			if (toprecord2 == '"Tijd";"Tijd";"UFP";"Temperatuur";"Luchtvochtigheid";"Lat";"Lon";"PM1";"PM2.5";"PM10";"Ozon";"NO2"') {
				if (toprecord3 == '"UTC";"Lokaal";"Counts/cm³";"°C";"%";"°";"°";"μg/m³";"μg/m³";"μg/m³";"μg/m³";"μg/m³"') {
					recordType = 10; //default
				}
			};

			if (toprecord2 == '"Tijd";"Tijd";"UFP";"Temperatuur ext";"Temperatuur";"Luchtvochtigheid ext";"Luchtvochtigheid";"Lat";"Lon";"PM1";"PM2.5";"PM10";"NO2"') {
				if (toprecord3 == '"UTC";"Lokaal";"Counts/cm³";"°C";"°C";"%";"%";"°";"°";"μg/m³";"μg/m³";"μg/m³";"μg/m³"') {
					recordType = 11; //default
				}
			};	

			if (toprecord2 == '"Tijd";"Tijd";"UFP";"Temperatuur";"Luchtvochtigheid";"Lat";"Lon";"PM1";"PM2.5";"PM10";"NO2"') {
				if (toprecord3 == '"UTC";"Lokaal";"Counts/cm³";"°C";"%";"°";"°";"μg/m³";"μg/m³";"μg/m³";"μg/m³"') {
					recordType = 12; //default
				}
			};	
			if (toprecord2 == '"Tijd";"Tijd";"Temperatuur";"Luchtvochtigheid";"Lat";"Lon";"PM1";"PM2.5";"PM10";"Ozon";"NO2"') {
				if (toprecord3 == '"UTC";"Lokaal";"°C";"%";"°";"°";"μg/m³";"μg/m³";"μg/m³";"μg/m³";"μg/m³"') {
					recordType = 13; //default
				}
			};
			if (toprecord2 == '"Tijd";"Tijd";"Temperatuur ext";"Temperatuur";"Luchtvochtigheid ext";"Luchtvochtigheid";"Lat";"Lon";"PM1";"PM2.5";"PM10";"NO2"') {
				if (toprecord3 == '"UTC";"Lokaal";"°C";"°C";"%";"%";"°";"°";"μg/m³";"μg/m³";"μg/m³";"μg/m³"') {
					recordType = 14; //default
				}
			};
			if (toprecord2 == '"Tijd";"Tijd";"Temperatuur";"Luchtvochtigheid";"Lat";"Lon";"PM1";"PM2.5";"PM10"') {
				if (toprecord3 == '"UTC";"Lokaal";"°C";"%";"°";"°";"μg/m³";"μg/m³";"μg/m³"') {
					recordType = 15; //default
				}
			};



			console.log('Airbox: %s', airboxId);
			console.log(' Aantal records: %d', inputFile.length-4);
										
			if (recordType == 0 ) {
				console.log('ERROR: unknown recordtype airbox %s ', airboxId );
				console.log(toprecord1);
				console.log(toprecord2);
				console.log(toprecord3);
				return
			}

			
			

			for (i=3;i<inputFile.length;i++) {

				var inputRecord = inputFile[i];
				var inputRecordCols = inputRecord.split(';');
				var outputRecord = "";
				if (inputRecordCols.length <2) continue; //empty record
				//var _measureDate		 			= inputRecord.measureDate==""?"null":"'"+inputRecord.measureDate + "', ";


				//var _gpsLat = _parseFloat(inputRecordCols[4]);
				//var _gpsLng = _parseFloat(inputRecordCols[5]);
				//var _lat = convertGPS2LatLng(_gpsLat);
				//var _lng = convertGPS2LatLng(_gpsLng);
				var _utc, _temp, _tempext, _rhum, _rhumext, _lat, _lng, _ufp, _pm1, _pm25, _pm10, _ozone, _no2 ;
				_utc 		= null;
				_temp 		= null;
				_tempext 	= null;
				_rhum 		= null;
				_rhumext 	= null;
				_lat 		= null;
				_lng 		= null;
				_ufp 		= null;
				_pm1 		= null;
				_pm25 		= null;
				_pm10 		= null;
				_ozone 		= null;
				_no2 		= null;

				_utc = inputRecordCols[0].replace(' ','T')+'Z';
				
//				var _date = new Date(_utc).getTime(); //+300000;
//				var _isodate = new Date(_date).toISOString();

				var _date = new Date(new Date(_utc).getTime()+60000);
				var minutes = Math.floor(_date.getUTCMinutes()/10)*10 ;
				_date.setUTCMinutes(minutes,0,0);
				_tick = new Date(_date).toISOString();
				
				//var minutesInput = parseInt(_isodate.slice(14,16));
				//var minutes = Math.floor(minutesInput/10)*10 ;
				//var minutesChar = "" + (minutes < 10?'0'+minutes:minutes); 
				//_tick = _utc.slice(0,14)+minutesChar+':00'+_utc.slice(19);
				
				//console.log(' %s %s %s %d %s %s', _utc,_date, _tick, minutes )

				if (recordType == 1 ) {
					//"Tijd";"Tijd";"Temperatuur";"Luchtvochtigheid";"Lat";"Lon";"PM1";"PM2.5";"PM10";"Ozon"
					_ufp 		= null;
					_temp 		= _parseFloat(inputRecordCols[2]);
					_tempext 	= null;
					_rhum 		= _parseFloat(inputRecordCols[3]);
					_rhumext 	= null;
					_lat 		= _parseFloat(inputRecordCols[4]);
					_lng 		= _parseFloat(inputRecordCols[5]);
					_pm1 		= _parseFloat(inputRecordCols[6]);
					_pm25 		= _parseFloat(inputRecordCols[7]);
					_pm10 		= _parseFloat(inputRecordCols[8]);
					_ozone 		= _parseFloat(inputRecordCols[9]);
					_no2 		= null;
				};	

				if (recordType == 2 ) {
					//"Tijd";"Tijd";"UFP";"Temperatuur";"Luchtvochtigheid";"Lat";"Lon";"PM1";"PM2.5";"PM10"
					_ufp 		= _parseFloat(inputRecordCols[2]);
					_temp 		= _parseFloat(inputRecordCols[3]);
					_tempext 	= null;
					_rhum 		= _parseFloat(inputRecordCols[4]);
					_rhumext 	= null;
					_lat 		= _parseFloat(inputRecordCols[5]);
					_lng 		= _parseFloat(inputRecordCols[6]);
					_pm1 		= _parseFloat(inputRecordCols[7]);
					_pm25 		= _parseFloat(inputRecordCols[8]);
					_pm10 		= _parseFloat(inputRecordCols[9]);
					_ozone 		= null;
					_no2 		= null;
				};	

				if (recordType == 3 ) {
					//"Tijd";"Tijd";"UFP";"Temperatuur ext";"Temperatuur";"Luchtvochtigheid ext";"Luchtvochtigheid";"Lat";"Lon";"PM1";"PM2.5";"PM10";"Ozon"
					_ufp 		= _parseFloat(inputRecordCols[2]);
					_tempext 	= _parseFloat(inputRecordCols[3]);
					_temp 		= _parseFloat(inputRecordCols[4]);
					_rhumext 	= _parseFloat(inputRecordCols[5]);
					_rhum 		= _parseFloat(inputRecordCols[6]);
					_lat 		= _parseFloat(inputRecordCols[7]);
					_lng 		= _parseFloat(inputRecordCols[8]);
					_pm1 		= _parseFloat(inputRecordCols[9]);
					_pm25 		= _parseFloat(inputRecordCols[10]);
					_pm10 		= _parseFloat(inputRecordCols[11]);
					_ozone 		= _parseFloat(inputRecordCols[12]);
					_no2 		= null;
				};	

				if (recordType == 4 ) {
					//"Tijd";"Tijd";"UFP";"Temperatuur";"Luchtvochtigheid";"Lat";"Lon";"PM1";"PM2.5";"PM10";"Ozon"
					_ufp 		= _parseFloat(inputRecordCols[2]);
					_tempext 	= null;
					_temp 		= _parseFloat(inputRecordCols[3]);
					_rhumext 	= null;
					_rhum 		= _parseFloat(inputRecordCols[4]);
					_lat 		= _parseFloat(inputRecordCols[5]);
					_lng 		= _parseFloat(inputRecordCols[6]);
					_pm1 		= _parseFloat(inputRecordCols[7]);
					_pm25 		= _parseFloat(inputRecordCols[8]);
					_pm10 		= _parseFloat(inputRecordCols[9]);
					_ozone 		= _parseFloat(inputRecordCols[10]);
					_no2 		= null;
				};
					
				if (recordType == 5 ) {
					//"Tijd";"Tijd";"Temperatuur ext";"Temperatuur";"Luchtvochtigheid ext";"Luchtvochtigheid";"Lat";"Lon";"PM1";"PM2.5";"PM10";"Ozon"
					_ufp 		= null;
					_tempext 	= _parseFloat(inputRecordCols[2]);
					_temp 		= _parseFloat(inputRecordCols[3]);
					_rhumext 	= _parseFloat(inputRecordCols[4]);
					_rhum 		= _parseFloat(inputRecordCols[5]);
					_lat 		= _parseFloat(inputRecordCols[6]);
					_lng 		= _parseFloat(inputRecordCols[7]);
					_pm1 		= _parseFloat(inputRecordCols[8]);
					_pm25 		= _parseFloat(inputRecordCols[9]);
					_pm10 		= _parseFloat(inputRecordCols[10]);
					_ozone 		= _parseFloat(inputRecordCols[11]);
					_no2 		= null;
				};	

				if (recordType == 6 ) {
					//"Tijd";"Tijd";"Temperatuur ext";"Temperatuur";"Luchtvochtigheid ext";"Luchtvochtigheid";"Lat";"Lon";"PM1";"PM2.5";"PM10"
					_ufp 		= null;
					_tempext 	= _parseFloat(inputRecordCols[2]);
					_temp 		= _parseFloat(inputRecordCols[3]);
					_rhumext 	= _parseFloat(inputRecordCols[4]);
					_rhum 		= _parseFloat(inputRecordCols[5]);
					_lat 		= _parseFloat(inputRecordCols[6]);
					_lng 		= _parseFloat(inputRecordCols[7]);
					_pm1 		= _parseFloat(inputRecordCols[8]);
					_pm25 		= _parseFloat(inputRecordCols[9]);
					_pm10 		= _parseFloat(inputRecordCols[10]);
					_ozone 		= null;
					_no2 		= null;
				};	

				if (recordType == 7 ) {
					//"Tijd";"Tijd";"UFP";"Temperatuur ext";"Temperatuur";"Luchtvochtigheid ext";"Luchtvochtigheid";"Lat";"Lon";"PM1";"PM2.5";"PM10"
					_ufp 		= _parseFloat(inputRecordCols[2]);
					_tempext 	= _parseFloat(inputRecordCols[3]);
					_temp 		= _parseFloat(inputRecordCols[4]);
					_rhumext 	= _parseFloat(inputRecordCols[5]);
					_rhum 		= _parseFloat(inputRecordCols[6]);
					_lat 		= _parseFloat(inputRecordCols[7]);
					_lng 		= _parseFloat(inputRecordCols[8]);
					_pm1 		= _parseFloat(inputRecordCols[9]);
					_pm25 		= _parseFloat(inputRecordCols[10]);
					_pm10 		= _parseFloat(inputRecordCols[11]);
					_ozone 		= null;
					_no2 		= null;
				};	

				if (recordType == 8 ) {
					//"Tijd";"Tijd";"Temperatuur ext";"Temperatuur";"Luchtvochtigheid ext";"Luchtvochtigheid";"Lat";"Lon";"PM1";"PM2.5";"PM10";"Ozon";"NO2"
					_ufp 		= null;
					_tempext 	= _parseFloat(inputRecordCols[2]);
					_temp 		= _parseFloat(inputRecordCols[3]);
					_rhumext 	= _parseFloat(inputRecordCols[4]);
					_rhum 		= _parseFloat(inputRecordCols[5]);
					_lat 		= _parseFloat(inputRecordCols[6]);
					_lng 		= _parseFloat(inputRecordCols[7]);
					_pm1 		= _parseFloat(inputRecordCols[8]);
					_pm25 		= _parseFloat(inputRecordCols[9]);
					_pm10 		= _parseFloat(inputRecordCols[10]);
					_ozone 		= _parseFloat(inputRecordCols[11]);
					_no2 		= _parseFloat(inputRecordCols[12]);;
				};	

				if (recordType == 9 ) {
					//"Tijd";"Tijd";"UFP";"Temperatuur ext";"Temperatuur";"Luchtvochtigheid ext";"Luchtvochtigheid";"Lat";"Lon";"PM1";"PM2.5";"PM10";"Ozon";"NO2"
					_ufp 		= _parseFloat(inputRecordCols[2]);
					_tempext 	= _parseFloat(inputRecordCols[3]);
					_temp 		= _parseFloat(inputRecordCols[4]);
					_rhumext 	= _parseFloat(inputRecordCols[5]);
					_rhum 		= _parseFloat(inputRecordCols[6]);
					_lat 		= _parseFloat(inputRecordCols[7]);
					_lng 		= _parseFloat(inputRecordCols[8]);
					_pm1 		= _parseFloat(inputRecordCols[9]);
					_pm25 		= _parseFloat(inputRecordCols[10]);
					_pm10 		= _parseFloat(inputRecordCols[11]);
					_ozone 		= _parseFloat(inputRecordCols[12]);
					_no2 		= _parseFloat(inputRecordCols[13]);;
				};	

				if (recordType == 10 ) {
					//"Tijd";"Tijd";"UFP";"Temperatuur";"Luchtvochtigheid";"Lat";"Lon";"PM1";"PM2.5";"PM10";"Ozon";"NO2"
					_ufp 		= _parseFloat(inputRecordCols[2]);
					_tempext 	= null;
					_temp 		= _parseFloat(inputRecordCols[3]);
					_rhumext 	= null;
					_rhum 		= _parseFloat(inputRecordCols[4]);
					_lat 		= _parseFloat(inputRecordCols[5]);
					_lng 		= _parseFloat(inputRecordCols[6]);
					_pm1 		= _parseFloat(inputRecordCols[7]);
					_pm25 		= _parseFloat(inputRecordCols[8]);
					_pm10 		= _parseFloat(inputRecordCols[9]);
					_ozone 		= _parseFloat(inputRecordCols[10]);
					_no2 		= _parseFloat(inputRecordCols[11]);
				};	

				if (recordType == 11 ) {
					//"Tijd";"Tijd";"UFP";"Temperatuur ext";"Temperatuur";"Luchtvochtigheid ext";"Luchtvochtigheid";"Lat";"Lon";"PM1";"PM2.5";"PM10";"NO2"
					_ufp 		= _parseFloat(inputRecordCols[2]);
					_tempext 	= _parseFloat(inputRecordCols[3]);
					_temp 		= _parseFloat(inputRecordCols[4]);
					_rhumext 	= _parseFloat(inputRecordCols[5]);
					_rhum 		= _parseFloat(inputRecordCols[6]);
					_lat 		= _parseFloat(inputRecordCols[7]);
					_lng 		= _parseFloat(inputRecordCols[8]);
					_pm1 		= _parseFloat(inputRecordCols[9]);
					_pm25 		= _parseFloat(inputRecordCols[10]);
					_pm10 		= _parseFloat(inputRecordCols[11]);
					_ozone 		= null;
					_no2 		= _parseFloat(inputRecordCols[12]);
				};	

				if (recordType == 12 ) {
					//"Tijd";"Tijd";"UFP";"Temperatuur";"Luchtvochtigheid";"Lat";"Lon";"PM1";"PM2.5";"PM10";"NO2"
					_ufp 		= _parseFloat(inputRecordCols[2]);
					_temp 		= _parseFloat(inputRecordCols[3]);
					_tempext 	= null;
					_rhum 		= _parseFloat(inputRecordCols[4]);
					_rhumext 	= null;
					_lat 		= _parseFloat(inputRecordCols[5]);
					_lng 		= _parseFloat(inputRecordCols[6]);
					_pm1 		= _parseFloat(inputRecordCols[7]);
					_pm25 		= _parseFloat(inputRecordCols[8]);
					_pm10 		= _parseFloat(inputRecordCols[9]);
					_ozone 		= null;
					_no2 		= _parseFloat(inputRecordCols[10]);
				};	
				if (recordType == 13 ) {
					//"Tijd";"Tijd";"Temperatuur";"Luchtvochtigheid";"Lat";"Lon";"PM1";"PM2.5";"PM10";"Ozon";"NO2"
					_temp 		= _parseFloat(inputRecordCols[2]);
					_tempext 	= null;
					_rhum 		= _parseFloat(inputRecordCols[3]);
					_rhumext 	= null;
					_ufp 		= null;
					_lat 		= _parseFloat(inputRecordCols[4]);
					_lng 		= _parseFloat(inputRecordCols[5]);
					_pm1 		= _parseFloat(inputRecordCols[6]);
					_pm25 		= _parseFloat(inputRecordCols[7]);
					_pm10 		= _parseFloat(inputRecordCols[8]);
					_ozone 		= _parseFloat(inputRecordCols[9]);
					_no2 		= _parseFloat(inputRecordCols[10]);
				};	
				if (recordType == 14 ) {
					//"Tijd";"Tijd";"Temperatuur ext";"Temperatuur";"Luchtvochtigheid ext";"Luchtvochtigheid";"Lat";"Lon";"PM1";"PM2.5";"PM10";"NO2"
					_ufp 		= null;
					_tempext 	= _parseFloat(inputRecordCols[2]);
					_temp 		= _parseFloat(inputRecordCols[3]);
					_rhumext 	= _parseFloat(inputRecordCols[4]);
					_rhum 		= _parseFloat(inputRecordCols[5]);
					_lat 		= _parseFloat(inputRecordCols[6]);
					_lng 		= _parseFloat(inputRecordCols[7]);
					_pm1 		= _parseFloat(inputRecordCols[8]);
					_pm25 		= _parseFloat(inputRecordCols[9]);
					_pm10 		= _parseFloat(inputRecordCols[10]);
					_ozone 		= null;
					_no2 		= _parseFloat(inputRecordCols[11]);
				};	

				if (recordType == 15 ) {
					//"Tijd";"Tijd";"Temperatuur";"Luchtvochtigheid";"Lat";"Lon";"PM1";"PM2.5";"PM10";"Ozon"
					_ufp 		= null;
					_temp 		= _parseFloat(inputRecordCols[2]);
					_tempext 	= null;
					_rhum 		= _parseFloat(inputRecordCols[3]);
					_rhumext 	= null;
					_lat 		= _parseFloat(inputRecordCols[4]);
					_lng 		= _parseFloat(inputRecordCols[5]);
					_pm1 		= _parseFloat(inputRecordCols[6]);
					_pm25 		= _parseFloat(inputRecordCols[7]);
					_pm10 		= _parseFloat(inputRecordCols[8]);
					_ozone 		= null;
					_no2 		= null;
				};	


				outputRecord = "\nINSERT INTO aireas_histecn ( airbox, tick_date, measure_date, " + 
						" lat, lng, ufp, rhumext, rhum, tempext, temp, pm1, pm25, pm10, " +
						" ozone, no2 " +
					//	" ,geom28992, geom " +
						" ) VALUES (" +
						"'" + 	airboxId 		+ "', " +
						"'" + 	_tick 			+ "', " +			// UTC timestamp floor at 10 minutes.
						"'" + 	_utc 			+ "', " +			// UTC timestamp
							_lat 				+ ", "  +
							_lng 				+ ", "  +
							_ufp 				+ ", "  +
							_rhumext 			+ ", "  +
							_rhum 				+ ", "  +
							_tempext 			+ ", "  +
							_temp 				+ ", "  +
							_pm1 				+ ", "  +
							_pm25 				+ ", "  +
							_pm10 				+ ", "  +
							_ozone 				+ ", "  +
							_no2 				+
						//	 ", "  +
						//	" ST_Transform(ST_SetSRID(ST_MakePoint(" + _lng + ", " + _lat + "), 4326), 28992 ), " +
						//	" ST_SetSRID(ST_MakePoint(" + _lng + ", " + _lat + "), 4326) " +
						" );  \n ";
						
				outputFile=outputFile.concat(outputRecord);
			
			}
			inputFile = null; // release memory
			
			outputFile=outputFile.concat("commit; \n ");
			
			console.log('Write: ' + outputFilePath+airboxId+'_test.sql');	
//		writeFile(outputFile, outputFilePath+'test.sql');
			fs.writeFileSync(outputFilePath+airboxId+'_test.sql', outputFile);

			executeSql(outputFile, sqlCallBack);
//			outputFile = null;  // clear memory

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
		

		
//		{"airbox": "39_cal", "retrievedDate": "2015-07-06T18:57:06.596Z", "content":

//		var firstRecParts = records2[0].split(',');
//		var firstRecJson = firstRecParts[0] + ', '+ firstRecParts[1] + '} ';
//		console.log(firstRecJson);
//		var firstRec = JSON.parse(firstRecJson);
//		console.log('Verwerk airbox %s van retrievedate %s', firstRec.airbox, firstRec.retrievedDate );
		
//		airboxName = firstRec.airbox;

//		console.log(inRecord);
//		console.log(inRecord.airboxes);
//		console.log(inRecord.airboxes[0]);
		
		
//		tmpArray = inRecord.content.airboxes;
		tmpArray = records2;
		dataRecords = records2;

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
/*
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
			
			_waardeDataRecord[_waardeDataRecord.length-1] = _waardeDataRecord[_waardeDataRecord.length-1].replace(/\r/, '');  // dos->unix
			
			if (_waardeDataRecord.length == 11) {
				console.log('record met 11 kolommen!: ' + firstRec.airbox + ' ' + _waardeDataRecord[9] + ' wordt overgeslagen.');
				continue;
			}
			
			//console.log(_waardeDataRecord.length);
			
			if (_waardeDataRecord.length>10) { 
			
				_dataRecord.retrievedDate 	= '' + firstRec.retrievedDate;
				_dataRecord.measureDate 	= '' + _waardeDataRecord[9];
				_dataRecord.gpsLat 	= _waardeDataRecord[11];
				_dataRecord.gpsLng 	= _waardeDataRecord[12];
				_dataRecord.lat 	= convertGPS2LatLng(_waardeDataRecord[11]);
				_dataRecord.lng 	= convertGPS2LatLng(_waardeDataRecord[12]);
				_dataRecord.OZON 	= _waardeDataRecord[3];
				_dataRecord.PM10 	= _waardeDataRecord[4];
				_dataRecord.PM1 	= _waardeDataRecord[5];
				_dataRecord.PM25 	= _waardeDataRecord[6];
				_dataRecord.HUM 	= _waardeDataRecord[7];
				_dataRecord.CELC 	= _waardeDataRecord[8];
				_dataRecord.UFP 	= _waardeDataRecord[2];
				_dataRecord.NO2 	= _waardeDataRecord[1]; //_waardeDataRecord[9];

				_dataRecord.gpsLatFloat = parseFloat(_waardeDataRecord[11]);
				_dataRecord.gpsLngFloat	= parseFloat(_waardeDataRecord[12]);
				_dataRecord.OZONFloat 	= parseFloat(_waardeDataRecord[3]);
				_dataRecord.PM10Float 	= parseFloat(_waardeDataRecord[4]);
				_dataRecord.PM1Float 	= parseFloat(_waardeDataRecord[5]);
				_dataRecord.PM25Float 	= parseFloat(_waardeDataRecord[6]);
				_dataRecord.HUMFloat 	= parseFloat(_waardeDataRecord[7]);
				_dataRecord.CELCFloat 	= parseFloat(_waardeDataRecord[8]);
				_dataRecord.UFPFloat 	= parseFloat(_waardeDataRecord[2]);
				if (_dataRecord.UFPFloat > 0) _dataRecord.UFPFloat = Math.round(_dataRecord.UFPFloat / 1000); // in units of 1000
				_dataRecord.NO2Float 	= parseFloat(_waardeDataRecord[1]);; //parseFloat(_waardeDataRecord[9]);

				dataRecords.push(_dataRecord);
				continue;
			}
			
			
		if (firstRec.airbox == '26.cal' || firstRec.airbox == '35.cal') {  // andere recordindeling
			_dataRecord.retrievedDate 	= '' + firstRec.retrievedDate;
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
			_dataRecord.retrievedDate 	= '' + firstRec.retrievedDate;
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
*/
	
		createExportFile();


	
	},




 } // end of module.exports




