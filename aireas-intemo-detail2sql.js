/*
** Module: aireas-intemo-detail2sql
**
**
**
**
*/

// **********************************************************************************

var fs 		= require('fs'),
	path 	= require("path");
var pg = require('pg');	

var intemoFolder, intemoUrl, intemoFileName, intemoLocalPathRoot, fileFolder, 
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
			
		intemoLocalPathRoot = options.systemFolderParent +'/aireas/';
//		intemoLocalPathRoot = options.systemFolderParent+'/intemo/';
		fileFolderName 		= 'intemo';
		tmpFolderName 		= '' + inSubFolder;
		resultsFolderName 	= 'results';

		intemoFolder 		= intemoLocalPathRoot 	+ fileFolderName 	+ "/";
		tmpFolder 			= intemoFolder 			+ tmpFolderName 	+ "/";
		resultsFolder 		= intemoFolder 			+ resultsFolderName + "/";

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
				if (file.search(/.\/\.DS_Store/) >=0 ) return false;
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

			filePath = resultsFolder;
			
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
				//console.log('SQL connect:', sqlConnString);
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
//			var toprecord2 = inputFile[1];
//			var toprecord3 = inputFile[2];
			
			var recordType = 0;
			
			var toprecord1Cols = toprecord1.split(',');
			
/*
			var airboxId = '';
			if (toprecord1Cols.length > 5) { //not an empty record
				airboxId = toprecord1Cols[2].replace(/\"/g,'');
			};
*/
			
			var _tmpTopRecord1 = "Id,Time,S.O3Resistance,S.No2Resistance,S.COResistance,S.CO2,S.RGBColor,S.LightsensorBlue,S.LightsensorGreen,S.LightsensorRed,S.AcceleroZ,S.AcceleroY,S.AcceleroX,S.Barometer,S.LightsensorBottom,S.LightsensorTop,S.Humidity,S.TemperatureAmbient,V.AudioPlus9,U.AudioPlus9,T.AudioPlus9,V.AudioPlus8,U.AudioPlus8,T.AudioPlus8,V.AudioPlus7,U.AudioPlus7,T.AudioPlus7,V.AudioPlus6,U.AudioPlus6,T.AudioPlus6,V.AudioPlus5,U.AudioPlus5,T.AudioPlus5,V.AudioPlus4,U.AudioPlus4,T.AudioPlus4,V.AudioPlus3,U.AudioPlus3,T.AudioPlus3,V.AudioPlus2,U.AudioPlus2,T.AudioPlus2,V.AudioPlus1,U.AudioPlus1,T.AudioPlus1,V.Audio0,U.Audio0,T.Audio0";
			
			//if (toprecord1 == _tmpTopRecord1) {
//				if (toprecord3 == '"UTC";"Lokaal";"°C";"%";"°";"°";"μg/m³";"μg/m³";"μg/m³";"μg/m³"') {
					recordType = 1; //default
//				}
			//};
				


			//console.log('Airbox: %s', airboxId);
			console.log(' Aantal records: %d', inputFile.length-2);  //- header and last (empty) record 
										

			if (recordType == 0 ) {
				console.log('ERROR: unknown recordtype intemo %s ', process.argv[3] );
				console.log(toprecord1);
				console.log(_tmpTopRecord1);
				//console.log(toprecord3);
				return
			}



			for (i=1;i<inputFile.length-1;i++) {

				var inputRecord = inputFile[i];
				var inputRecordCols = inputRecord.split(',');
				var outputRecord = "";
				if (inputRecordCols.length <2) continue; //empty record
				//var _measureDate		 			= inputRecord.measureDate==""?"null":"'"+inputRecord.measureDate + "', ";


				//var _gpsLat = _parseFloat(inputRecordCols[4]);
				//var _gpsLng = _parseFloat(inputRecordCols[5]);
				//var _lat = convertGPS2LatLng(_gpsLat);
				//var _lng = convertGPS2LatLng(_gpsLng);
				var _deviceId
					, _measurementDateIso
					, _VAudio0
					, _UAudio0
					, _TAudio0
					, _VAudio1
					, _UAudio1
					, _TAudio1
					, _VAudio2
					, _UAudio2
					, _TAudio2
					, _VAudio3
					, _UAudio3
					, _TAudio3
					, _VAudio4
					, _UAudio4
					, _TAudio4
					, _VAudio5
					, _UAudio5
					, _TAudio5
					, _VAudio6
					, _UAudio6
					, _TAudio6
					, _VAudio7
					, _UAudio7
					, _TAudio7
					, _VAudio8
					, _UAudio8
					, _TAudio8
					, _VAudio9
					, _UAudio9
					, _TAudio9
					//, _sensorName, _sensorLabel, _sensorUnit, _measurementDateIso, _measureDay, _measurementHour, _valueMin, _valueMax, _valueRaw, _sensorValue, _sampleCount, _altitude, _point, _lat, _lng
					;
				_deviceId 				= null;
				_measurementDateIso 			= null;
				_VAudio0				= null;
				_UAudio0				= null;
				_TAudio0				= null;
				_VAudio1				= null;
				_UAudio1				= null;
				_TAudio1				= null;
				_VAudio2				= null;
				_UAudio2				= null;
				_TAudio2				= null;
				_VAudio3				= null;
				_UAudio3				= null;
				_TAudio3				= null;
				_VAudio4				= null;
				_UAudio4				= null;
				_TAudio4				= null;
				_VAudio5				= null;
				_UAudio5				= null;
				_TAudio5				= null;
				_VAudio6				= null;
				_UAudio6				= null;
				_TAudio6				= null;
				_VAudio7				= null;
				_UAudio7				= null;
				_TAudio7				= null;
				_VAudio8				= null;
				_UAudio8				= null;
				_TAudio8				= null;
				_VAudio9				= null;
				_UAudio9				= null;
				_TAudio9				= null;

/*

				_sensorName 			= null;
				_sensorLabel 			= null;
				_sensorUnit 			= null;
				_measurementDateIso 	= null;
				_measureDay 			= null;
				_measurementHour 		= null;
				_valueMin 				= null;
				_valueMax 				= null;
				_valueRaw 				= null;
				_sensorValue 			= null;
				_sampleCount 			= null;
				_altitude 				= null;
				_point 					= null;
				_lat 					= null;
				_lng 					= null;
*/

				if (recordType == 1 ) {
					_deviceId 			= inputRecordCols[0]; 
					var dateStr			= inputRecordCols[1];
					var dateStrSliced	= dateStr.split(' ');
					var dateStrDateSliced	= dateStrSliced[0].split('/');
					var dateStrYear		= dateStrDateSliced[2];
					var dateStrMonth	= dateStrDateSliced[0];
					var dateStrDay		= dateStrDateSliced[1];
					var dateStrTimeSliced	= dateStrSliced[1].split(':');
					var dateStrHour		= dateStrTimeSliced[0];
					var dateStrMinute	= dateStrTimeSliced[1];
					var dateStrSeconds	= dateStrTimeSliced[2];
					var tmpDate = new Date(dateStrYear, dateStrMonth-1, dateStrDay, dateStrHour, dateStrMinute, dateStrSeconds );
					
					//console.log(dateStr);
					//console.log(dateStrSliced);
					
					//console.log('%s %s %s %s %s %s ',dateStrYear, dateStrMonth-1, dateStrDay, dateStrHour, dateStrMinute, dateStrSeconds)
					//console.log(dateStrSliced[2] );
					if (dateStrSliced[2] == 'PM') {
						if (dateStrHour!='12') {
							tmpDate = new Date(tmpDate.getTime() + 43200000); // +12 hours
							//	console.log(tmpDate);
						}	
					}  else { // AM			
						if (dateStrHour=='12') {
							tmpDate = new Date(tmpDate.getTime() - 43200000); // -12 hours
							//	console.log(tmpDate);
						}	
					}  	
					
					console.log(tmpDate, inputRecordCols[47]);
					_measurementDateIso	= tmpDate.toISOString();


					_VAudio9			= _parseFloat(inputRecordCols[18]);
					_UAudio9			= _parseFloat(inputRecordCols[19]);
					_TAudio9			= _parseFloat(inputRecordCols[20]);
					_VAudio8			= _parseFloat(inputRecordCols[21]);
					_UAudio8			= _parseFloat(inputRecordCols[22]);
					_TAudio8			= _parseFloat(inputRecordCols[23]);
					_VAudio7			= _parseFloat(inputRecordCols[24]);
					_UAudio7			= _parseFloat(inputRecordCols[25]);
					_TAudio7			= _parseFloat(inputRecordCols[26]);
					_VAudio6			= _parseFloat(inputRecordCols[27]);
					_UAudio6			= _parseFloat(inputRecordCols[28]);
					_TAudio6			= _parseFloat(inputRecordCols[29]);
					_VAudio5			= _parseFloat(inputRecordCols[30]);
					_UAudio5			= _parseFloat(inputRecordCols[31]);
					_TAudio5			= _parseFloat(inputRecordCols[32]);
					_VAudio4			= _parseFloat(inputRecordCols[33]);
					_UAudio4			= _parseFloat(inputRecordCols[34]);
					_TAudio4			= _parseFloat(inputRecordCols[35]);
					_VAudio3			= _parseFloat(inputRecordCols[36]);
					_UAudio3			= _parseFloat(inputRecordCols[37]);
					_TAudio3			= _parseFloat(inputRecordCols[38]);
					_VAudio2			= _parseFloat(inputRecordCols[39]);
					_UAudio2			= _parseFloat(inputRecordCols[40]);
					_TAudio2			= _parseFloat(inputRecordCols[41]);
					_VAudio1			= _parseFloat(inputRecordCols[42]);
					_UAudio1			= _parseFloat(inputRecordCols[43]);
					_TAudio1			= _parseFloat(inputRecordCols[44]);
					_VAudio0			= _parseFloat(inputRecordCols[45]);
					_UAudio0			= _parseFloat(inputRecordCols[46]);
					_TAudio0			= inputRecordCols[47]=='\r'?null:_parseFloat(inputRecordCols[47]);
					
					if (inputRecordCols[46]=='\r'||inputRecordCols[46]==undefined|inputRecordCols[46]==null) console.log(inputRecordCols[47]); 

/*					_sensorName 		= inputRecordCols[4];
					_sensorLabel 		= inputRecordCols[5];
					_sensorUnit 		= inputRecordCols[6];
					_measurementDateIso = inputRecordCols[7];
					_measureDay 		= inputRecordCols[8];
					_measurementHour 	= inputRecordCols[9];
					_valueMin 			= _parseFloat(inputRecordCols[10]);
					_valueMax 			= _parseFloat(inputRecordCols[11]);
					_valueRaw 			= _parseFloat(inputRecordCols[12]);
					_sensorValue 		= _parseFloat(inputRecordCols[13]);
					_sampleCount 		= _parseFloat(inputRecordCols[14]);
					_altitude 			= _parseFloat(inputRecordCols[15]);
					_point				= inputRecordCols[16];
*/
					
/*
					//POINT (51.496625 5.371825)
					//console.log(_point, _point.search(/^POINT./));
					if (_point.search(/^POINT./) ==0 ) {
						var tmp1 	= _point.substring(7);
						tmp2		= tmp1.replace(')','');
						var tmp3	= tmp2.split(' ');
						_lat			= _parseFloat(tmp3[0]);
						_lng			= _parseFloat(tmp3[1]);
					}
*/

						
				};	


				outputRecord = "\nINSERT INTO intemo_detail_import ( device_id, measurement_date,  " + 
						" v_audio_9, u_audio_9, t_audio_9, " +
						" v_audio_8, u_audio_8, t_audio_8, " +
						" v_audio_7, u_audio_7, t_audio_7, " +
						" v_audio_6, u_audio_6, t_audio_6, " +
						" v_audio_5, u_audio_5, t_audio_5, " +
						" v_audio_4, u_audio_4, t_audio_4, " +
						" v_audio_3, u_audio_3, t_audio_3, " +
						" v_audio_2, u_audio_2, t_audio_2, " +
						" v_audio_1, u_audio_1, t_audio_1, " +
						" v_audio_0, u_audio_0, t_audio_0 " +
						" ) VALUES (" +
						"'" + 	_deviceId			+ "', " +			
						"'" + 	_measurementDateIso		+ "', " +			
							_VAudio9 				+ ", "  +
							_UAudio9 				+ ", "  +
							_TAudio9 				+ ", "  +
							_VAudio8 				+ ", "  +
							_UAudio8 				+ ", "  +
							_TAudio8 				+ ", "  +
							_VAudio7 				+ ", "  +
							_UAudio7 				+ ", "  +
							_TAudio7 				+ ", "  +
							_VAudio6 				+ ", "  +
							_UAudio6 				+ ", "  +
							_TAudio6 				+ ", "  +
							_VAudio5 				+ ", "  +
							_UAudio5 				+ ", "  +
							_TAudio5 				+ ", "  +
							_VAudio4 				+ ", "  +
							_UAudio4 				+ ", "  +
							_TAudio4 				+ ", "  +
							_VAudio3 				+ ", "  +
							_UAudio3 				+ ", "  +
							_TAudio3 				+ ", "  +
							_VAudio2 				+ ", "  +
							_UAudio2 				+ ", "  +
							_TAudio2 				+ ", "  +
							_VAudio1 				+ ", "  +
							_UAudio1 				+ ", "  +
							_TAudio1 				+ ", "  +
							_VAudio0 				+ ", "  +
							_UAudio0 				+ ", "  +
							_TAudio0 				+ 
						//	 ", "  +
						//	" ST_Transform(ST_SetSRID(ST_MakePoint(" + _lng + ", " + _lat + "), 4326), 28992 ), " +
						//	" ST_SetSRID(ST_MakePoint(" + _lng + ", " + _lat + "), 4326) " +
						" );  \n ";
						
				outputFile=outputFile.concat(outputRecord);
			
			}
			inputFile = null; // release memory
			
			outputFile=outputFile.concat("commit; \n ");
			
			console.log('Write: ' + outputFilePath+_deviceId+'_test.sql');	
//		writeFile(outputFile, outputFilePath+'test.sql');
			fs.writeFileSync(outputFilePath+_deviceId+'_test.sql', outputFile);

			executeSql(outputFile, sqlCallBack);
//			outputFile = null;  // clear memory

		};

	

		
//		localPath 		= tmpFolder + intemoFileName;
		var localPath 		= file;
    	console.log("Local intemo data: " + localPath );

    	var _datFile	= fs.readFileSync(localPath);


		var i, j, _dataRecord, _waardeDataRecord, inpRecordArray,
			inpRecordPM1, inpRecordPM25, inpRecordPM10, 
			inpRecordUFP, inpRecordOZON, inpRecordHUM, inpRecordCELC;

		
//		var inRecord1 = "" + _datFile.toString();
//		var inRecord2 = inRecord1.replace(/\'/g,'"');
//		var inRecord = JSON.parse(inRecord2);
		
		var records1 = ""+_datFile;	
		var records2 = records1.split('\n');
		
		
//		tmpArray = inRecord.content.airboxes;
		tmpArray = records2;
		dataRecords = records2;


	
		createExportFile();


	
	},




 } // end of module.exports




