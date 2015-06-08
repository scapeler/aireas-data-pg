/*
** Module: aireas2sql
**
**
**
**
*/

// **********************************************************************************
"use strict"; // This is for your code to comply with the ECMAScript 5 standard.

var fs = require('fs');
var pg = require('pg');

var aireasFolder, aireasUrl, aireasFileName, aireasLocalPathRoot, fileFolder, 
	tmpFolder, tmpFolderName, localPath, fileFolderName, 
	resultsFolder, resultsFolderName, sqlFolder, sqlFolderName;
var nrOfMeasures, maxMeasures, nextFolders, sqlConnString; 

// **********************************************************************************


module.exports = {

	init: function (options) {

		sqlConnString = options.configParameter.databaseType + '://' + 
			options.configParameter.databaseAccount + ':' + 
			options.configParameter.databasePassword + '@' + 
			options.configParameter.databaseServer + '/' +
			options.systemCode + '_' + options.configParameter.databaseName;
					
		aireasLocalPathRoot = options.systemFolderParent+'/aireas/';
		fileFolderName 		= 'aireas';
		tmpFolderName 		= 'tmp';
		resultsFolderName 	= 'results';
		sqlFolderName		= 'sql';

		aireasFolder 		= aireasLocalPathRoot 	+ fileFolderName 	+ "/";
		tmpFolder 			= aireasFolder 			+ tmpFolderName 	+ "/";
		resultsFolder 		= aireasFolder 			+ resultsFolderName + "/";
		sqlFolder 			= aireasFolder 			+ sqlFolderName  	+ "/";

		// create subfolders
		try {fs.mkdirSync(sqlFolder );} catch (e) {};//console.log('ERROR: no sql folder found, batch run aborted.'); return } ;

		var inputLocalIndex = -1;
		var inputLocalFiles = [];
		var rootFolderType = 'year';
		var outputPrefix="";
		nextFolders = {'year':'month','month':'day','day':'hour','hour':'minute','minute':'leafs','leafs':'files'} ;

		maxMeasures = 10;  // stop processing when maxMeasures are processed; restart process for continueing.
		nrOfMeasures = 0;
		
		this.exploreResultFolders(rootFolderType, resultsFolder, outputPrefix);

	},

	exploreResultFolders: function ( folderType ,path, outputPrefix) {
		var _resultsFolder;
		var nextFolderType;
		var tmpOutputPrefix;
		var i;
		var files;
		var folderContent;
		var fileName;
		var nodeName;
		var aireasFile;
		var createSqlAireas = this.createSqlAireas;

		if (nrOfMeasures>=maxMeasures) {
			console.log('WARNING:','Max number of processed measures reached, restart job to continue.')
			return;
		}

		folderContent = fs.readdirSync(path);
		folderContent.sort();

		if (folderContent) {

			if (folderType == 'leafs') {

				var filesProcessed = true;
				var folderHierarchy = path.split('\/');

				//check if allready processed
                                fileName = 'aireas';
				var file = sqlFolder+outputPrefix+"_"+fileName+ '.sql';
				fs.exists( file, function(exists) {
					if ( exists == false ) {
                                		//files
                                		aireasFile = fs.readFileSync(path+fileName + '.json');
                               			if (aireasFile) {
                                        		console.log(path, fileName + '.json');
                                		} else {
                                        		console.log('ERROR: not found:', path, fileName + '.json');
                                		}
                                		createSqlAireas (aireasFile, sqlFolder+outputPrefix+"_"+ fileName + '.sql');
                                		aireasFile =  null;

                                		nrOfMeasures++;	
					}
				});

				return;				

			} else {
				nextFolderType = nextFolders[folderType];
				for (i=0;i<folderContent.length;i++) {
					nodeName = folderContent[i];
					tmpOutputPrefix = setPrefix( outputPrefix, folderType, nodeName);
					if (nodeName != '.DS_Store') {  // ignore mac-file
						this.exploreResultFolders(nextFolderType, path + nodeName + '/', tmpOutputPrefix);
					}
				}
			}
		};
		
		function submitJson() {

		};

		function setPrefix(prefix, folderType, nodeName) {
			var _prefix = "";
			switch (folderType) {
				case "year":{
					_prefix = prefix + nodeName;
				}
				case "month": case "day": case "hour": case "minute": {
					if (nodeName.length<2) {
						_prefix = prefix + "0" + nodeName;
					} else {
						_prefix = prefix + nodeName;
					}
				}
				default: {
				}
			}
			return _prefix; 
		};

	},

	createSqlAireas: function(inputFileJson , outputFilePath) {
		var i;

 		var inputFile = JSON.parse(inputFileJson);
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

        	var writeFile = function(fileContent, filepath ) {
                	var _path = filepath;
                	fs.writeFileSync(_path, fileContent);
        	};


		for (i=0;i<inputFile.length;i++) {

			var inputRecord = inputFile[i];
			var outputRecord = "";

			var _measureDate		 			= inputRecord.measureDate==""?"null":"'"+inputRecord.measureDate + "', ";


			outputRecord = "\nINSERT INTO aireas ( airbox, retrieveddatechar, measuredatechar, retrieveddate, measuredate, " + 
				" gpslat, gpslng, lat, lng, pm1, pm25, pm10, ufp, ozon, hum, celc, " + 
				" gpslatfloat, gpslngfloat, pm1float, pm25float, pm10float, ufpfloat, ozonfloat, humfloat, celcfloat," + 
				" geom28992, geom ) VALUES (\n" +
					"'" + 	inputRecord.airbox 			+ "', " +
					"'" + 	inputRecord.retrievedDate 	+ "', " +
					"'" + 	inputRecord.measureDate 	+ "', " +
					"'" +	inputRecord.retrievedDate 	+ "', " + 	// timestamp with time zone,
					"'" + 	_measureDate			 	+ "', \n" +	// timestamp with time zone,
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
					"'" + 	inputRecord.NO2 			+ "', \n" +
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
							" ST_SetSRID(ST_MakePoint(" + inputRecord.lng + ", " + inputRecord.lat + "), 4326) ); ";

			outputFile=outputFile.concat(outputRecord);
		}
	console.log('Write: ' + outputFilePath);	
		writeFile(outputFile, outputFilePath);
		executeSql(outputFile, sqlCallBack);
		outputFile = null;  // clear memory

	},



} // end of mopdule.exports
