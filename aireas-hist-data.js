/*
** Module: aireas-hist-data
**
**
**
**
*/
// **********************************************************************************
"use strict"; // This is for your code to comply with the ECMAScript 5 standard.

var request = require('request');
var fs 		= require('fs');
var sys 	= require('sys');

var aireasUrl, aireasFileName, aireasLocalPathRoot, fileFolder, tmpFolder;

var airboxes = ['1_cal', '2_cal', '3_cal', '4_cal', '5_cal', '6_cal', '7_cal', '8_cal', '9_cal', '10_cal', 
'11_cal', '12_cal', '13_cal', '14_cal', '15_cal', '16_cal', '17_cal', '18_cal', '19_cal', '20_cal', 
'21_cal', '22_cal', '23_cal', '24_cal', '25_cal', '26_cal', '27_cal', '28_cal', '29_cal', '30_cal', 
'31_cal', '32_cal', '33_cal', '34_cal', '35_cal', '36_cal', '37_cal', '38_cal', '39_cal', '40_cal' ];

var fileImportIndex = 0;
// **********************************************************************************


module.exports = {

	init: function (options) {
		//aireasUrl 			= 'http://82.201.127.232/api?airboxid=*';
		aireasUrl 			= 'http://82.201.127.232:8080/csv/';
		aireasFileName 		= 'aireas-hist';

		aireasLocalPathRoot = options.systemFolderParent + '/aireas/';
		fileFolder 			= 'aireas-hist';
		tmpFolder 			= aireasLocalPathRoot + fileFolder + "/" + 'tmp/';

		// create subfolders
		try {fs.mkdirSync(tmpFolder );} catch (e) {};//console.log('ERROR: no tmp folder found, batch run aborted.'); return } ;

		// 10-minuten reeksen met actuele AiREAS luchtmetingen. Verversing elke 10 minuten.
	
		for (var i=0;i<airboxes.length;i++) {
			this.reqFile (aireasUrl+airboxes[i]+'.csv', airboxes[i], aireasFileName+airboxes[i]+'.txt',	false, 'aireasdata');
		}	

		console.log('All retrieve actions are activated.');

	},

	reqFile: function (url, airbox, fileName, unzip, desc) {
	
	var _wfsResult=null;
	console.log("Request start: " + desc + " (" + url + ")");


	function StreamBuffer(req) {
  		var self = this

  		var buffer = []
  		var ended  = false
  		var ondata = null
  		var onend  = null

  		self.ondata = function(f) {
    		console.log("self.ondata")
    		for(var i = 0; i < buffer.length; i++ ) {
      			f(buffer[i])
      			console.log(i);
    		}
    		console.log(f);
    		ondata = f
  		}

  		self.onend = function(f) {
    		onend = f
    		if( ended ) {
      			onend()
    		}
  		}

  		req.on('data', function(chunk) {
    		// console.log("req.on data: ");
    		if (_wfsResult) {
      			_wfsResult += chunk;
    		} else {
      			_wfsResult = chunk;
    		}

    		if( ondata ) {
      			ondata(chunk)
    		} else {
      			buffer.push(chunk)
    		}
  		})

  		req.on('end', function() {
    		//console.log("req.on end")
    		ended = true;

    		if( onend ) {
      			onend()
    		}
  		})        
 
  		req.streambuffer = self
	}

	function writeFile(path, fileName, content) {
  		fs.writeFile(path + fileName, content, function(err) {
    		if(err) {
      			console.log(err);
    		} else {
      			console.log("The file is saved! " + tmpFolder + fileName + ' (unzip:' + unzip + ')');
				if (unzip) {
					var exec = require('child_process').exec;
					var puts = function(error, stdout, stderr) { sys.puts(stdout) }
					exec(" cd " + tmpFolder + " ;  unzip -o " + tmpFolder + fileName + " ", puts);
				}
    		}
  		}); 
	}

  	new StreamBuffer(request.get( { url: url, airbox:airbox }, function(error, response) {
		console.log("Request completed: " + desc + " " );
		var currDate = new Date();
		var iso8601 = currDate.toISOString();

		writeFile(tmpFolder, fileName, '{"airbox": "' + airbox + '", retrievedDate": "' + iso8601 + '", "content":' + 
			_wfsResult + ' }');
		})
  	);

	} // end of reqFile

}  // end of module.exports
