/*
** Module: aireas2json
**
**
**
**
*/

/* This module accepts the API v1 from AiREAS

De API zal een nieuwe URL krijgen: http://82.201.127.232/api/v1/?airboxid=* (deze is nog niet actief). Hierdoor kunnen eindgebruikers zelf overstappen wanneer ze er klaar voor zijn, tot die tijd kunnen zij niet de hittestress ontvangen. Verder is de API ook omgebouwd naar een JSON string met de volgende inhoud. De volgorde kan afwijken, met JSON en het gebruik van keys (zoals utctimestamp) maakt deze volgorde namelijk niet meer uit:
 
Voor een enkele airbox:
{“name”: “15.cal”, “utctimestamp”: “2015-07-01 13:08:02”, “PM1”: 3.0, “PM25”: 4.0, “PM10”: 5.0, “UFP”: 6.0, “NO2”: 7.0, “OZON”: 8.0, “RELHUM”: 9.0, “TEMP”: 10.0, “AMBTEMP”: 11.0, “AMBHUM”: 12.0, “WBGT”: 13, “gps”: { “lat”: 5128.649943, “lon”: 539.407194}}
 
 
Voor alle airboxen:
[
{“name”: “1.cal”, “utctimestamp”: “2015-07-01 13:08:02”, “PM1”: 3.0, “PM25”: 4.0, “PM10”: 5.0, “UFP”: 6.0, “NO2”: 7.0, “OZON”: 8.0, “RELHUM”: 9.0, “TEMP”: 10.0, “AMBTEMP”: 11.0, “AMBHUM”: 12.0, “WBGT”: 13, “gps”: { “lat”: 5128.649943, “lon”: 539.407194}},
{“name”: “2.cal”, “utctimestamp”: “2015-07-01 13:08:02”, “PM1”: 3.0, “PM25”: 4.0, “PM10”: 5.0, “UFP”: 6.0, “NO2”: 7.0, “OZON”: 8.0, “RELHUM”: 9.0, “TEMP”: 10.0, “AMBTEMP”: 11.0, “AMBHUM”: 12.0, “WBGT”: 13, “gps”: { “lat”: 5128.649943, “lon”: 539.407194}},
…,
{“name”: “23.cal”, “utctimestamp”: “2015-07-01 13:08:02”, “PM1”: 3.0, “PM25”: 4.0, “PM10”: 5.0, “UFP”: 6.0, “NO2”: 7.0, “OZON”: 8.0, “RELHUM”: 9.0, “TEMP”: 10.0, “AMBTEMP”: 11.0, “AMBHUM”: 12.0, “WBGT”: 13, “gps”: { “lat”: 5128.649943, “lon”: 539.407194}}
]

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
		fileFolderName 		= 'aireas-v1';
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
//		var inRecord2 = inRecord1.replace(/\'/g,'"');
		var inRecord = JSON.parse(inRecord1);
//		console.log(inRecord);
//		console.log(inRecord.airboxes);
//		console.log(inRecord.airboxes[0]);
		
		
		tmpArray = inRecord.content;
		

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

		for(i=0;i<tmpArray.length-1;i++) {  

//			inpRecordArray 		= tmpArray[i].split(':(');
//			inpRecordArray 		= tmpArray[i].split('[');
			inpRecordArray 		= tmpArray[i];

//			console.log(inpRecordArray);

			_dataRecord			= {};
//			_dataRecord.airBox	= inpRecordArray[0];

//			inpMetingenArray 	= inpRecordArray[1].split(',');
			_waardeDataRecord	= inpRecordArray;	
//			_waardeDataRecord 	= [];
//			for(j=0;j<inpMetingenArray.length;j++) {
//				_waardeDataRecord[j] = inpRecordArray[j];// parseFloat(inpMetingenArray[j]);
//			}


// {"AMBHUM": 0.0, "PM1": 3.0, "utctimestamp": "2015-07-22 17:37:17", "TEMP": 21.97, "RELHUM": 41.73, "NO2": 0.0, "name": "22.cal", "PM10": 11.0, "OZON": 102.8, "UFP": 10290.0, "AMBTEMP": 0.0, "PM25": 5.0, "gps": {"lat": 5126.733562, "lon": 530.503508}}
						

			if (_waardeDataRecord.name == '4.cal') continue;  //temporary skip because of wrong measurements
			if (_waardeDataRecord.name == '6.cal') continue;  //temporary skip because of wrong measurements
			if (_waardeDataRecord.name == '23.cal') continue;  //temporary skip because of wrong measurements
			if (_waardeDataRecord.name == '29.cal') continue;  //temporary skip because of wrong measurements
			if (_waardeDataRecord.name == '37.cal') continue;  //temporary skip because of wrong measurements
			

			_dataRecord.airbox 	= _waardeDataRecord.name;
			
			_dataRecord.retrievedDate 	= inRecord.retrievedDate;
			_dataRecord.measureDate 	= _waardeDataRecord.utctimestamp;
			_dataRecord.gpsLat 	= _waardeDataRecord.gps.lat;
			_dataRecord.gpsLng 	= _waardeDataRecord.gps.lon;
			_dataRecord.lat 	= this.convertGPS2LatLng(_waardeDataRecord.gps.lat);
			_dataRecord.lng 	= this.convertGPS2LatLng(_waardeDataRecord.gps.lon);
			_dataRecord.PM1 	= _waardeDataRecord.PM1;
			_dataRecord.PM25 	= _waardeDataRecord.PM25;
			_dataRecord.PM10 	= _waardeDataRecord.PM10;
			_dataRecord.UFP 	= _waardeDataRecord.UFP;
//			if (_dataRecord.UFP > 0) _dataRecord.UFP = Math.round(_dataRecord.UFP / 1000); // in units of 1000
			_dataRecord.OZON 	= _waardeDataRecord.OZON;
			_dataRecord.HUM 	= _waardeDataRecord.RELHUM;
			_dataRecord.CELC 	= _waardeDataRecord.TEMP;
			_dataRecord.NO2 	= _waardeDataRecord.NO2;
			_dataRecord.AMBHUM 	= _waardeDataRecord.AMBHUM;
			_dataRecord.AMBTEMP = _waardeDataRecord.AMBTEMP;
			

			_dataRecord.gpsLatFloat = _waardeDataRecord.gps.lat;
			_dataRecord.gpsLngFloat	= _waardeDataRecord.gps.lon;
			_dataRecord.PM1Float 	= _waardeDataRecord.PM1;
			_dataRecord.PM25Float 	= _waardeDataRecord.PM25;
			_dataRecord.PM10Float 	= _waardeDataRecord.PM10;
			_dataRecord.UFPFloat 	= _waardeDataRecord.UFP;
			if (_dataRecord.UFPFloat > 0) _dataRecord.UFPFloat = Math.round(_dataRecord.UFPFloat / 1000); // in units of 1000
			_dataRecord.OZONFloat 	= _waardeDataRecord.OZON;
			_dataRecord.HUMFloat 	= _waardeDataRecord.RELHUM;
			_dataRecord.CELCFloat 	= _waardeDataRecord.TEMP;
			_dataRecord.NO2Float 	= _waardeDataRecord.NO2;
			_dataRecord.AMBHUMFloat = _waardeDataRecord.AMBHUM;
			_dataRecord.AMBTEMPFloat = _waardeDataRecord.AMBTEMP;

/*
			_dataRecord.airbox 	= _waardeDataRecord[0];
			
			_dataRecord.retrievedDate 	= inRecord.retrievedDate;
			_dataRecord.measureDate 	= _waardeDataRecord[1];
			_dataRecord.gpsLat 	= _waardeDataRecord[10];
			_dataRecord.gpsLng 	= _waardeDataRecord[11];
			_dataRecord.lat 	= this.convertGPS2LatLng(_waardeDataRecord[10]);
			_dataRecord.lng 	= this.convertGPS2LatLng(_waardeDataRecord[11]);
			_dataRecord.PM1 	= _waardeDataRecord[2];
			_dataRecord.PM25 	= _waardeDataRecord[3];
			_dataRecord.PM10 	= _waardeDataRecord[4];
			_dataRecord.UFP 	= _waardeDataRecord[5];
			_dataRecord.OZON 	= _waardeDataRecord[6];
			_dataRecord.HUM 	= _waardeDataRecord[7];
			_dataRecord.CELC 	= _waardeDataRecord[8];
			_dataRecord.NO2 	= _waardeDataRecord[9];

			_dataRecord.gpsLatFloat = parseFloat(_waardeDataRecord[10]);
			_dataRecord.gpsLngFloat	= parseFloat(_waardeDataRecord[11]);
			_dataRecord.PM1Float 	= parseFloat(_waardeDataRecord[2]);
			_dataRecord.PM25Float 	= parseFloat(_waardeDataRecord[3]);
			_dataRecord.PM10Float 	= parseFloat(_waardeDataRecord[4]);
			_dataRecord.UFPFloat 	= parseFloat(_waardeDataRecord[5]);
			if (_dataRecord.UFPFloat > 0) _dataRecord.UFPFloat = Math.round(_dataRecord.UFPFloat / 1000); // in units of 1000
			_dataRecord.OZONFloat 	= parseFloat(_waardeDataRecord[6]);
			_dataRecord.HUMFloat 	= parseFloat(_waardeDataRecord[7]);
			_dataRecord.CELCFloat 	= parseFloat(_waardeDataRecord[8]);
			_dataRecord.NO2Float 	= parseFloat(_waardeDataRecord[9]);
*/

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
