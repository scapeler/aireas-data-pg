/*
** Module: aireas-hist-data-v2
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



/**/ 
var airboxes = ['1', '2', '3', '4', '5', '6', '7', '8', '9', '10', 
'11', '12', '13', '14', '15', '16', '17', '18', '19', '20', 
'21', '22', '23', '24', '25', '26', '27', '28', '29', '30', 
'31', '32', '33', '34', '35', '36', '37', '38', '39', '40' ];
/**/
//var airboxes = ['33'];


var year = 2016;
var beginTime 	= new Date(year,0).getTime();  // set beginTime of selection to 1-1-YYYY,00:00:00
var endTime 	= new Date(year+1,0).getTime()-1000;  // set beginTime of selection to 31-12-YYYY,23:59:59

console.log('Begin time of selection is ' + new Date(beginTime).toISOString());


//var airboxes = ['26', '35' ];

var fileImportIndex = 0;
// **********************************************************************************


var transActionArray = [];
var transActionIndex = -1;

var processTransAction	= function() {
	transActionIndex++;
	if (transActionIndex < transActionArray.length) {
		console.log('Process transaction: ' + (transActionIndex+1) );
		getContent(transActionIndex)
		.then(function(result) {
			if (result != 'empty') {  
				console.log("Request completed: "+result.param.fileName);
				writeFile(tmpFolder, result.param.fileName, result.body );
			}	
			processTransAction();	
		})
		.catch(function(err) { 
			console.log(err)
			processTransAction();			
		})
		;
	}		
}



module.exports = {

	init: function (options) {
		//aireasUrl 			= 'http://82.201.127.232/api?airboxid=*';
		//aireasUrl 			= 'http://82.201.127.232:8080/csv/';
		//aireasUrl 			= 'http://ilm.scapeler.com:8080/csv/';
		aireasUrl 				= 'http://data.aireas.com/api/v2/airboxes/history/';
		aireasFileName 			= 'aireas-hist-v2_';

		aireasLocalPathRoot 	= options.systemFolderParent + '/aireas/';
		fileFolder 				= 'aireas-hist-v2';
		tmpFolder 				= aireasLocalPathRoot + fileFolder + "/" + 'tmp/';

		// create subfolders
		try {fs.mkdirSync(tmpFolder );} catch (e) {};//console.log('ERROR: no tmp folder found, batch run aborted.'); return } ;

		// 10-minuten reeksen met historische AiREAS luchtmetingen. 
	
		for (var i=0;i<airboxes.length;i++) {
			var airboxId = airboxes[i];
		
			var beginPeriodTime = new Date(year,0).getTime();
			for (var j=0;j<15;j++) {  // 15 periods of aprox 25 days builds a year in total
				//var beginMonthTime = new Date(year,j).getTime();
				var endPeriodTime = beginPeriodTime + (29*60*60*24*1000)-1000; // 29 days*24H*60m*60s*1000ms - 1sec
				if (endPeriodTime >=endTime) endPeriodTime = endTime; 
				console.log('Retrieve airbox '+airboxes[i]+ ' begin at ' + new Date(beginPeriodTime).toISOString() + ' till ' + new Date(endPeriodTime).toISOString() );
				var _url = aireasUrl+airboxes[i]+'/'+(beginPeriodTime/1000)+'/'+(endPeriodTime/1000);
				var fileName = aireasFileName+airboxes[i]+'_'+(j+1)+'.txt';

				console.log('url: '+_url);

		//		this.reqFile (_url, airboxId, fileName,	false, 'aireasdata');
		
				var transAction 		= {};
				transAction.url 		= _url;
				transAction.fileName 	= fileName;
				transAction.airboxId 	= airboxId;
				transActionArray.push(transAction);
							
				//setTimeout(function() {},5000)
				
				if (endPeriodTime >= endTime) {
					j=15;
				} else {
					beginPeriodTime 	= endPeriodTime+1000; // +1sec 
				}
			}
		}	
		processTransAction();
		console.log('Processing of transactions activated.');

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
   		 		console.log("self.ondata");
   		 		for(var i = 0; i < buffer.length; i++ ) {
      				f(buffer[i])
      				console.log(i);
    			}
    			console.log(f);
    			ondata = f
  			}

	  		self.onend = function(f) {
   		 		onend = f;
   		 		if( ended ) {
      				onend();
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
		};

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
	
			writeFile(tmpFolder, fileName, '{"airbox": "' + airbox + '", "retrievedDate": "' + iso8601 + '", "content":' + 
				_wfsResult + ' }');
			})
  		);

	} // end of reqFile

}  // end of module.exports

var getContent = function(transActionIndex) {
	var _transAction = transActionArray[transActionIndex];
	// return new pending promise
	return new Promise(function(resolve, reject) {
		// select http or https module, depending on reqested url
		//var lib = url.startsWith('https') ? require('https') : require('http');
		var lib = require('http');
	
		var request = lib.get(_transAction.url, function(response) {
			// handle http errors
			if (response.statusCode < 200 || response.statusCode > 299) {
				reject(new Error('Failed to load page, status code: ' + response.statusCode));
			}
			// temporary data holder
			var result = {};
			result.param	= { airboxId: _transAction.airboxId, fileName: _transAction.fileName};
			var body = [];

			// on every content chunk, push it to the data array
			response.on('data', function(chunk) { body.push(chunk)});
			// we are done, resolve promise with those joined chunks
			response.on('end', function() {
				console.log('Resolve '+ result.param.airboxId + ' ' + result.param.fileName);
				var currDate = new Date();
				var iso8601 = currDate.toISOString();
				var _body = body.join('');
				if (_body=='[]') {
					resolve('empty');
					//console.log(' Empty result: ' + body.length + ' ' + _body);	
				} else {	
					console.log(' test: ' + body.length);	
					result.body = '{"airbox": "' + _transAction.airboxId + '", "retrievedDate": "' + iso8601 + '", "content":' + _body + ' }';
			  		resolve(result);
				}	
			});
		});
	// handle connection errors of the request
	request.on('error', function(err) { reject(err) })
	})
};

var	writeFile =	function (path, fileName, content) {
  	fs.writeFile(path + fileName, content, function(err) {
  		if(err) {
  			console.log(err);
  		} else {
  			console.log("The file is saved! " + tmpFolder + fileName);
//      				console.log("The file is saved! " + tmpFolder + fileName + ' (unzip:' + unzip + ')');
//					if (unzip) {
//						var exec = require('child_process').exec;
//						var puts = function(error, stdout, stderr) { sys.puts(stdout) }
//						exec(" cd " + tmpFolder + " ;  unzip -o " + tmpFolder + fileName + " ", puts);
//					}
    	}
	}); 
}
