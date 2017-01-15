/*
** Module: aireas2json-v2
**
**
**
**
*/

/* This module accepts the API v2 from AiREAS

*/

// **********************************************************************************

var fs 		= require('fs');

var aireasFolder, aireasUrl, aireasFileName, aireasLocalPathRoot, fileFolder, 
	tmpFolder, tmpFolderName, localPath, fileFolderName, resultsFolder, resultsFolderName;
var dataRecords;

// **********************************************************************************

module.exports = {

	init: function (options) {
		aireasLocalPathRoot = options.systemFolderParent+'/aireas/';
		fileFolderName 		= 'aireas-v2';
		tmpFolderName 		= 'tmp';
		resultsFolderName 	= 'results';

		aireasFileName 		= 'aireas.txt';
		aireasFileNameOutput= 'aireas.json';

		aireasFolder 		= aireasLocalPathRoot 	+ fileFolderName 	+ "/";
		tmpFolder 			= aireasFolder 			+ tmpFolderName 	+ "/";
		resultsFolder 		= aireasFolder 			+ resultsFolderName + "/";

		// create subfolders
		try {fs.mkdirSync(resultsFolder );} catch (e) {};//console.log('ERROR: no tmp folder found, batch run aborted.'); return } ;

	    localPath 		= tmpFolder + aireasFileName;
    	var _datFile	= fs.readFileSync(localPath);
    	console.log("Local AiREAS data: " + localPath );


		var i, j, _dataRecord, _waardeDataRecord, inpRecordArray,
			inpRecordPM1, inpRecordPM25, inpRecordPM10, 
			inpRecordUFP, inpRecordOZON, inpRecordHUM, inpRecordCELC;

		
		var inRecord1 = "" + _datFile.toString();
		var inRecord = JSON.parse(inRecord1);
		
		
		tmpArray = inRecord.content;
		
		dataRecords	= [];
		
		// find latest measured datetime, actual measurements can't be older than this datetime - 15 minutes. They maybe in maintenance or defect of ....
		var latestMeasureDate, tmpLatestMeasureDate, tmpLatestMeasureDateStr;
//		tmpLatestMeasureDateStr = tmpArray[0].utctimestamp+'Z';
//		tmpLatestMeasureDateStr = _waardeDataRecord.last_measurement.calibrated.when.$date
		latestMeasureDate = new Date(0);
		for(i=0;i<tmpArray.length-1;i++) { 
			if (tmpArray[i].last_measurement && tmpArray[i].last_measurement.calibrated && tmpArray[i].last_measurement.calibrated.when && tmpArray[i].last_measurement.calibrated.when.$date) {
				tmpLatestMeasureDate 	= new Date(tmpArray[i].last_measurement.calibrated.when.$date);
				if (latestMeasureDate.getTime() < tmpLatestMeasureDate.getTime()) {
					latestMeasureDate = tmpLatestMeasureDate;
				}

//				tmpLatestMeasureDateStr = tmpArray[i].utctimestamp+'Z';
//				tmpLatestMeasureDate 	= new Date(tmpLatestMeasureDateStr);
//				if (latestMeasureDate.getTime() < tmpLatestMeasureDate.getTime()) {
//					latestMeasureDate = tmpLatestMeasureDate;
//				}
			}
		}
		
		console.log('Actual measure datetime is '+latestMeasureDate.toISOString());
		
		for(i=0;i<tmpArray.length-1;i++) {  
		
			_waardeDataRecord	= tmpArray[i];	

			//skip if no measurements available
			if (_waardeDataRecord.last_measurement && _waardeDataRecord.last_measurement.calibrated && _waardeDataRecord.last_measurement.calibrated.readings && _waardeDataRecord.last_measurement.calibrated.when && _waardeDataRecord.last_measurement.calibrated.when.$date) {
				// measurement values available
			} else {
				console.log('No measurement values available for airbox '+_waardeDataRecord._id);
				continue;
			}
			
			if (_waardeDataRecord.state != 'H' ) {
				console.log('Airbox state not equal "H" (skipped) for airbox '+_waardeDataRecord._id+ ' ' + _waardeDataRecord.state);
				continue;
			}  

			// skip if measureddate < latest date - 15 minutes
			tmpLatestMeasureDate 	= new Date(_waardeDataRecord.last_measurement.calibrated.when.$date);
			if (tmpLatestMeasureDate.getTime() < latestMeasureDate.getTime()- 900000) {
			
				console.log('Measurement values too old for airbox '+_waardeDataRecord._id);
				continue;  // skip 'old' measurement
			}  


			_dataRecord			= {};


			//if (_waardeDataRecord.name == '6.cal') continue;  //temporary skip because of wrong measurements
			/* reactivated on 2015-10-20 
			if (_waardeDataRecord.name == '4.cal') continue;  //temporary skip because of wrong measurements
			
			if (_waardeDataRecord.name == '23.cal') continue;  //temporary skip because of wrong measurements
			if (_waardeDataRecord.name == '29.cal') continue;  //temporary skip because of wrong measurements
			if (_waardeDataRecord.name == '37.cal') continue;  //temporary skip because of wrong measurements
			*/
			if (_waardeDataRecord._id == 12) { _waardeDataRecord.last_measurement.calibrated.readings.UFP = '0'; };  //temporary skip UFP because of wrong measurements


			_dataRecord.airbox 	= _waardeDataRecord._id+'.cal';
			
			_dataRecord.retrievedDate 	= inRecord.retrievedDate;
			_dataRecord.measureDate 	= new Date(_waardeDataRecord.last_measurement.calibrated.when.$date).toISOString();
			_dataRecord.gpsLat 			= _waardeDataRecord.last_measurement.calibrated.readings.GPS.lat;
			_dataRecord.gpsLng 			= _waardeDataRecord.last_measurement.calibrated.readings.GPS.lon;
			_dataRecord.lat 			= this.convertGPS2LatLng(_waardeDataRecord.last_measurement.calibrated.readings.GPS.lat);
			_dataRecord.lng 			= this.convertGPS2LatLng(_waardeDataRecord.last_measurement.calibrated.readings.GPS.lon);
			_dataRecord.PM1 			= _waardeDataRecord.last_measurement.calibrated.readings.PM1;
			_dataRecord.PM25 			= _waardeDataRecord.last_measurement.calibrated.readings.PM25;
			_dataRecord.PM10 			= _waardeDataRecord.last_measurement.calibrated.readings.PM10;
			_dataRecord.UFP 			= _waardeDataRecord.last_measurement.calibrated.readings.UFP;
			_dataRecord.OZON 			= _waardeDataRecord.last_measurement.calibrated.readings.Ozon;
			_dataRecord.HUM 			= _waardeDataRecord.last_measurement.calibrated.readings.RelHum;
			_dataRecord.CELC 			= _waardeDataRecord.last_measurement.calibrated.readings.Temp;
			_dataRecord.NO2 			= _waardeDataRecord.last_measurement.calibrated.readings.NO2;
			_dataRecord.AMBHUM 			= _waardeDataRecord.last_measurement.calibrated.readings.AmbHum;
			_dataRecord.AMBTEMP 		= _waardeDataRecord.last_measurement.calibrated.readings.AmbTemp;
			

			_dataRecord.gpsLatFloat 	= _waardeDataRecord.last_measurement.calibrated.readings.GPS.lat;
			_dataRecord.gpsLngFloat		= _waardeDataRecord.last_measurement.calibrated.readings.GPS.lon;
			_dataRecord.PM1Float 		= _waardeDataRecord.last_measurement.calibrated.readings.PM1;
			_dataRecord.PM25Float 		= _waardeDataRecord.last_measurement.calibrated.readings.PM25;
			_dataRecord.PM10Float 		= _waardeDataRecord.last_measurement.calibrated.readings.PM10;
			_dataRecord.UFPFloat 		= _waardeDataRecord.last_measurement.calibrated.readings.UFP;
			if (_dataRecord.UFPFloat > 0) _dataRecord.UFPFloat = Math.round(_dataRecord.UFPFloat / 1000); // in units of 1000
			_dataRecord.OZONFloat 		= _waardeDataRecord.last_measurement.calibrated.readings.Ozon;
			_dataRecord.HUMFloat 		= _waardeDataRecord.last_measurement.calibrated.readings.RelHum;
			_dataRecord.CELCFloat 		= _waardeDataRecord.last_measurement.calibrated.readings.Temp;
			_dataRecord.NO2Float 		= _waardeDataRecord.last_measurement.calibrated.readings.NO2;
			_dataRecord.AMBHUMFloat 	= _waardeDataRecord.last_measurement.calibrated.readings.AmbHum;
			_dataRecord.AMBTEMPFloat 	= _waardeDataRecord.last_measurement.calibrated.readings.AmbTemp;

			dataRecords.push(_dataRecord);

		}
	
		this.createExportFile();

	}, // end of init

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

	convertGPS2LatLng: function(gpsValue){
		var degrees = Math.floor(gpsValue /100);
		var minutes = gpsValue - (degrees*100);
		var result  = degrees + (minutes /60);
		return result;
	},

	writeFile: function(path, fileName, content ) {
		var _path = path;
		try {
			fs.mkdirSync(_path);
		} catch (e) {} ;
		fs.writeFileSync(_path + "/" + fileName, content);
	}

} // end of module.exports
