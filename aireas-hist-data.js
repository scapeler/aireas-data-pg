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

var airboxes = ['1.cal', '2.cal', '3.cal', '4.cal', '5.cal', '6.cal', '7.cal', '8.cal', '9.cal', '10.cal', 
'11.cal', '12.cal', '13.cal', '14.cal', '15.cal', '16.cal', '17.cal', '18.cal', '19.cal', '20.cal', 
'21.cal', '22.cal', '23.cal', '24.cal', '25.cal', '26.cal', '27.cal', '28.cal', '29.cal', '30.cal', 
'31.cal', '32.cal', '33.cal', '34.cal', '35.cal', '36.cal', '37.cal', '38.cal', '39.cal', '40.cal' ];
// **********************************************************************************


module.exports = {

	init: function (options) {
		//aireasUrl 			= 'http://82.201.127.232/api?airboxid=*';
		aireasUrl 			= 'http://82.201.127.232:8080/csv/';
		aireasFileName 		= 'aireas-hist';

		aireasLocalPathRoot = options.systemFolderParent + '/aireas/';
		fileFolder 			= 'aireas';
		tmpFolder 			= aireasLocalPathRoot + fileFolder + "/" + 'tmp/';

		// create subfolders
		try {fs.mkdirSync(tmpFolder );} catch (e) {};//console.log('ERROR: no tmp folder found, batch run aborted.'); return } ;

		// 10-minuten reeksen met actuele AiREAS luchtmetingen. Verversing elke 10 minuten.
	
		for (var i=0;i<airboxes.length;i++) {
			this.reqFile (aireasUrl+airboxes[i], aireasFileName+airboxes[i]+'.txt',	false, 'aireasdata');
		}	

		console.log('All retrieve actions are activated.');

	},

	reqFile: function (url, fileName, unzip, desc) {
	
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

  	new StreamBuffer(request.get( { url: url }, function(error, response) {
		console.log("Request completed: " + desc + " " );
		var currDate = new Date();
		var iso8601 = currDate.toISOString();

		writeFile(tmpFolder, fileName, '{"retrievedDate": "' + iso8601 + '", "content":' + 
			_wfsResult + ' }');
		})
  	);

	} // end of reqFile

}  // end of module.exports
