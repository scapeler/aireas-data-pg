/*
** Module: aera-aera2sql
**
**
**
**
*/

// **********************************************************************************

var fs 		= require('fs'),
	path = require("path");
var pg = require('pg');	

var aeraFolder, aeraUrl, aeraFileName, aeraLocalPathRoot, fileFolder, 
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
			
		aeraLocalPathRoot = options.systemFolderParent +'/aireas/';
//		aeraLocalPathRoot = options.systemFolderParent+'/aera/';
		fileFolderName 		= 'aera';
		tmpFolderName 		= '' + inSubFolder;
		resultsFolderName 	= 'results';

		aeraFolder 			= aeraLocalPathRoot 	+ fileFolderName 	+ "/";
		tmpFolder 			= aeraFolder 			+ tmpFolderName 	+ "/";
		resultsFolder 		= aeraFolder 			+ resultsFolderName + "/";

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
			
			var toprecord1Cols = toprecord1.split(';');
			
/*
			var airboxId = '';
			if (toprecord1Cols.length > 5) { //not an empty record
				airboxId = toprecord1Cols[2].replace(/\"/g,'');
			};
*/
			
			
			if (toprecord1 == '"FOICODE";"MEASUREMENTDATE";"MEASUREMENTTIME";"MEASUREMENTDATEISO";"LAT";"LNG";"UNKNOWN";"N";"DP_AV";"P";"FILENAME";"SEQNR";"SERIALDEVICE";"SERIALENGINE";"NANOTRACERVERSION"') {
//				if (toprecord3 == '"UTC";"Lokaal";"°C";"%";"°";"°";"μg/m³";"μg/m³";"μg/m³";"μg/m³"') {
					recordType = 1; //default
//				}
			};
				


			//console.log('Airbox: %s', airboxId);
			console.log(' Aantal records: %d', inputFile.length-2);  //- header and last (empty) record 
										
			if (recordType == 0 ) {
				console.log('ERROR: unknown recordtype aera %s ', airboxId );
				console.log(toprecord1);
				console.log(toprecord2);
				console.log(toprecord3);
				return
			}


			for (i=1;i<inputFile.length;i++) {

				var inputRecord = inputFile[i];
				var inputRecordCols = inputRecord.split(';');
				var outputRecord = "";
				if (inputRecordCols.length <2) continue; //empty record
				//var _measureDate		 			= inputRecord.measureDate==""?"null":"'"+inputRecord.measureDate + "', ";


				//var _gpsLat = _parseFloat(inputRecordCols[4]);
				//var _gpsLng = _parseFloat(inputRecordCols[5]);
				//var _lat = convertGPS2LatLng(_gpsLat);
				//var _lng = convertGPS2LatLng(_gpsLng);
				var _foiCode, _measurementDate, _measurementTime, _measurementDateIso, _lat, _lng, _unknown, _N, _dp_av, _p, _fileName, _seqnr ;
				_foiCode 			= null;
				_measurementDate 	= null;
				_measurementTime 	= null;
				_measurementDateIso = null;
				_lat 				= null;
				_lng 				= null;
				_unknown 			= null;
				_N 					= null;
				_dp_av 				= null;
				_p 					= null;
				_fileName 			= null;
				_seqnr 				= null;

				if (recordType == 1 ) {
					_foiCode 			= inputRecordCols[0].replace(/\"/g,'');
					_measurementDate 	= inputRecordCols[1];
					_measurementTime 	= inputRecordCols[2];
					_measurementDate 	= inputRecordCols[3]; //new Date(inputRecordCols[3]);
					_lat 				= _parseFloat(inputRecordCols[4]);
					_lng 				= _parseFloat(inputRecordCols[5]);
					_unknown 			= _parseFloat(inputRecordCols[6]);
					_N 					= inputRecordCols[7]=='NaN'?null:_parseFloat(inputRecordCols[7]);
					_dp_av 				= inputRecordCols[8]=='NaN'?null:_parseFloat(inputRecordCols[8]);
					_p 					= inputRecordCols[9]=='NaN'?null:_parseFloat(inputRecordCols[9]);
					_fileName 			= inputRecordCols[10].replace(/\"/g,'');
					_seqnr 				= inputRecordCols[11];
				};	


				outputRecord = "\nINSERT INTO aera_import ( foi_code, measurement_date, " + 
						" lat, lng, unknown, n, dpav, p, file_name, seqnr " +
						" ) VALUES (" +
						"'" + 	_foiCode 		+ "', " +
						"'" + 	_measurementDate+ "', " +			// UTC timestamp
							_lat 				+ ", "  +
							_lng 				+ ", "  +
							_unknown 			+ ", "  +
							_N 					+ ", "  +
							_dp_av 				+ ", "  +
							_p 					+ ", "  +
						"'" +	_fileName 		+ "', " +
							_seqnr 				+ 
						//	 ", "  +
						//	" ST_Transform(ST_SetSRID(ST_MakePoint(" + _lng + ", " + _lat + "), 4326), 28992 ), " +
						//	" ST_SetSRID(ST_MakePoint(" + _lng + ", " + _lat + "), 4326) " +
						" );  \n ";
						
				outputFile=outputFile.concat(outputRecord);
			
			}
			inputFile = null; // release memory
			
			outputFile=outputFile.concat("commit; \n ");
			
			console.log('Write: ' + outputFilePath+_foiCode+'_test.sql');	
//		writeFile(outputFile, outputFilePath+'test.sql');
			fs.writeFileSync(outputFilePath+_foiCode+'_test.sql', outputFile);

			executeSql(outputFile, sqlCallBack);
//			outputFile = null;  // clear memory

		};

	

		
//		localPath 		= tmpFolder + aeraFileName;
		var localPath 		= file;
    	console.log("Local aera data: " + localPath );

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




