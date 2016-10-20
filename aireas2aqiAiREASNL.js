/*
** Module: node-apri-aireas2aqi
** calculates AQI air quality index from aireas sensor measurement data
**
**
**
*/

// **********************************************************************************
"use strict"; // This is for your code to comply with the ECMAScript 5 standard.

//var fs = require('fs');
var pg = require('pg');

var aireasFolder, aireasUrl, aireasFileName, aireasLocalPathRoot, fileFolder, 
	tmpFolder, tmpFolderName, localPath, fileFolderName, 
	resultsFolder, resultsFolderName, sqlFolder, sqlFolderName;
var sqlConnString; 
	
// **********************************************************************************

module.exports = {

	init: function (options) {
		
		sqlConnString = options.configParameter.databaseType + '://' + 
			options.configParameter.databaseAccount + ':' + 
			options.configParameter.databasePassword + '@' + 
			options.configParameter.databaseServer + '/' +
			options.systemCode + '_' + options.configParameter.databaseName;
			
		aireasLocalPathRoot 	= options.systemFolderParent+'/aireas/';
		fileFolderName 		= 'aireas';
		tmpFolderName 		= 'tmp';
		resultsFolderName 	= 'results';
		sqlFolderName		= 'sql';

		aireasFolder 		= aireasLocalPathRoot 	+ fileFolderName 	+ "/";
		tmpFolder 			= aireasFolder 			+ tmpFolderName 	+ "/";
		resultsFolder 		= aireasFolder 			+ resultsFolderName + "/";
		sqlFolder 			= aireasFolder 			+ sqlFolderName  	+ "/";
		
		this.calculateAireasAqi();
	},

	calculateAireasAqi: function() {
		var _sql;
		_sql = "select get_aireas_aqi_area('GM0772', 'EHV20141104:1', 'AiREAS_NL');";
		this.executeSql(_sql, this.sqlCallBack);
	},

	sqlCallBack: function (err, result) {
		if (err) {
			console.log('ERROR:','sql error:', err, result);
		} else {
			//console.log('Query','sql result:', result);
		}
	},

	executeSql: function(query, callback) {
		console.log('sql start: ');
		var client = new pg.Client(sqlConnString);
		client.connect(function(err) {
  			if(err) {
				client.end();
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
	}

} // end of module.exports
