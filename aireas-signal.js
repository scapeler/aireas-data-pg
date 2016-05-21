/*
** Module: node-apri-aireas-signal
**
**
**
**
*/

// **********************************************************************************
"use strict"; // This is for your code to comply with the ECMAScript 5 standard.
// activate init process config-main
var path = require('path');
var startFolder 			= __dirname;
var startFolderParent		= path.resolve(__dirname,'..');
var configServerModulePath	= startFolderParent + '/apri-server-config/apri-server-config';
console.log("Start of Config Main ", configServerModulePath);
var apriConfig = require(configServerModulePath)

var systemFolder 			= __dirname;
var systemFolderParent		= path.resolve(__dirname,'..');
var systemFolderRoot		= path.resolve(systemFolderParent,'..');
var systemModuleFolderName 	= path.basename(systemFolder);
var systemModuleName 		= path.basename(__filename);
var systemBaseCode 			= path.basename(systemFolderParent);

//console.log('systemFolder', systemFolder);  				// systemFolder /opt/TSCAP-550/node-apri
//console.log('systemFolderParent', systemFolderParent);  	// systemFolderParent /opt/TSCAP-550
//console.log('systemFolderRoot', systemFolderRoot);  	// systemFolderRoot   /opt

var initResult = apriConfig.init(systemModuleFolderName+"/"+systemModuleName);

// **********************************************************************************


var handlebarsx 	= require('handlebars');
var moment 			= require('moment');

var fs 				= require('fs');
var pg 				= require('pg');
var nodemailer 		= require('nodemailer');

var sqlConnString;
var transporter, emails, apps, templateWijkSource, templateWijk, sql;
var checkSignalValues, sendMail;

// **********************************************************************************

module.exports = {

	init: function (options) {
	
		console.log('execute init');
	
		sqlConnString = options.configParameter.databaseType + '://' + 
			options.configParameter.databaseAccount + ':' + 
			options.configParameter.databasePassword + '@' + 
			options.configParameter.databaseServer + '/' +
			options.systemCode + '_' + options.configParameter.databaseName;
			
		transporter 		= nodemailer.createTransport();
		checkSignalValues 	= this.checkSignalValues;
		sendMail 			= this.sendMail;

		emails = [
			{emailAddress: 'awiel@scapeler.com', municipals: [ {municipal_code: 'GM0772', areas: ['Wijk 11 Stadsdeel Centrum', 'Wijk 12 Stadsdeel Stratum', 'Wijk 13 Stadsdeel Tongelre', 'Wijk 14 Stadsdeel Woensel-Zuid', 'Wijk 15 Stadsdeel Woensel-Noord', 'Wijk 16 Stadsdeel Strijp', 'Wijk 17 Stadsdeel Gestel'], signalValues: [ 15, 20, 25, 30] } ] }
		]

		apps = [
			{app: 'humansensor', messageType: 'aireassignal', municipals: [ {municipal_code: 'GM0772', areas: ['Wijk 11 Stadsdeel Centrum', 'Wijk 12 Stadsdeel Stratum', 'Wijk 13 Stadsdeel Tongelre', 'Wijk 14 Stadsdeel Woensel-Zuid', 'Wijk 15 Stadsdeel Woensel-Noord', 'Wijk 16 Stadsdeel Strijp', 'Wijk 17 Stadsdeel Gestel'], signalValues: [ 15, 20, 25, 30] } ], signalDiffGt: 1 }
		]

		templateWijkSource	= "<h1>Informatie over daling of stijging meetwaarde luchtkwaliteit</h1><p>Datum: {{data.signalDateTimeStr}}</p> \
    {{#each data}}<h2>Signaal voor wijk '{{wk_naam}}'</h2><p>{{message}}</p> \
	Gemeente: {{gm_naam}} ({{gm_code}})<BR/> \
	Wijk: {{wk_naam}}<BR/> \
	Inwoners wijk: {{aant_inw_wijk}}<BR/> \
	Buurt: {{bu_naam}}<BR/> \
	Inwoners buurt: {{aant_inw_buurt}}<BR/> \
	Vorige waarde: {{scaqi_prev}}<BR/> \
	Actuele waarde: <B>{{scaqi}}</B><BR/> \
	{{/each}}</div><BR/>";
	
		templateWijk		= handlebarsx.compile(templateWijkSource);				

		sql = "select max(wijk.gm_naam) gm_naam, max(wijk.gm_code) gm_code, max(wijk.wk_naam) wk_naam, max(buurt.bu_code) bu_code, max(buurt.bu_naam) bu_naam, \
  max(avg.avg_avg) ScAQI, \
  max(avg_prev.avg_avg) ScAQI_prev, \
  max(avg.retrieveddate) retrieveddate, \
  max(wijk.aant_inw) aant_inw_wijk, \
  max(buurt.aant_inw) aant_inw_buurt \
from  grid_gem_cell cell \
, grid_gem_cell_avg avg \
, grid_gem_cell_avg avg_prev \
, cbswijk2012 wijk \
, cbsbuurt2012 buurt \
where 1=1 \
and cell.gid = avg.grid_gem_cell_gid \
and cell.gid = avg_prev.grid_gem_cell_gid \
and avg.retrieveddate >= current_timestamp - interval '10 minutes'  \
and avg_prev.retrieveddate >= current_timestamp - interval '20 minutes' \
and avg_prev.retrieveddate < current_timestamp - interval '10 minutes' \
and avg.avg_type = 'SPMI' \
and avg_prev.avg_type = 'SPMI' \
and wijk.gm_code  = 'GM0772' \
and wijk.wk_code  = cell.wk_code \
and buurt.gm_code = wijk.gm_code \
and buurt.bu_code = cell.bu_code \
group by wijk.gm_naam, buurt.bu_naam \
order by wijk.gm_naam, buurt.bu_naam ";

/*
		sql = "select gm_naam, max(wijk.gm_code) gm_code, max(wijk.wk_naam) wk_naam, \
  max(avg.avg_avg) ScAQI, \
  max(avg_prev.avg_avg) ScAQI_prev, \
  max(avg.retrieveddate) retrieveddate, \
  max(aant_inw) aant_inw \
from  grid_gem_cell cell \
, grid_gem_cell_avg avg \
, grid_gem_cell_avg avg_prev \
, cbswijk2012 wijk \
where 1=1 \
and cell.gid = avg.grid_gem_cell_gid \
and cell.gid = avg_prev.grid_gem_cell_gid \
and avg.retrieveddate >= current_timestamp - interval '10 minutes'  \
and avg_prev.retrieveddate >= current_timestamp - interval '20 minutes' \
and avg_prev.retrieveddate < current_timestamp - interval '10 minutes' \
and avg.avg_type = 'SPMI' \
and avg_prev.avg_type = 'SPMI' \
and wijk.gm_code='GM0772' \
and wijk.wk_code = cell.wk_code \
group by wijk.gm_naam, wijk.wk_code \
order by wijk.gm_naam, wijk.wk_code ";

*/







/*  test if airbox is defect?
select 
  aireas.airbox,
  max(aireas.pm1float) pm1float, 
  max(aireas_prev.pm1float) pm1float_prev, 
  max(aireas.pm25float) pm25float, 
  max(aireas_prev.pm25float) pm25float_prev, 
  max(aireas.pm10float) pm10float, 
  max(aireas_prev.pm10float) pm10float_prev, 
  max(aireas.retrieveddate) aireas_retrieveddate
from  
  aireas  
, aireas aireas_prev 
where 1=1 
and aireas.airbox = aireas_prev.airbox 
and aireas.retrieveddate >= current_timestamp - interval '10 minutes'  
and aireas_prev.retrieveddate >= current_timestamp - interval '20 minutes' 
and aireas_prev.retrieveddate < current_timestamp - interval '10 minutes' 
and aireas.pm1float = aireas_prev.pm1float
and aireas.pm25float = aireas_prev.pm25float
and aireas.pm10float = aireas_prev.pm10float
group by aireas.airbox 
order by aireas.airbox

*/


	this.executeSql(sql, function(err, result) {
		var i,j;
		var signal;	
		var _outRecords;
		
		//var socket = require('socket.io-client')('https://openiod.org',{path: '/SCAPE604/socket.io'});
		var socket = require('socket.io-client')('http://149.210.208.157:3010',{path: '/SCAPE604/socket.io'});
		// emit web-socket for notification to apps
		socket.on('connect', function () {
			console.log('connected ');
		});	
		socket.on( 'info', function (data) {
			console.log('info '+data.nrOfConnections);
		});

	
		var _result = result.rows; //JSON.parse(result);

		// mailing notifications / signals
		for (i =0;i< emails.length;i++) {
			var email = emails[i];
			console.log('Signal function started for emailaddress: ' + email.emailAddress);
			var municipal = email.municipals[0];
		
			var _outRecords = [];
			_outRecords.signalDateTime = new Date();
			_outRecords.signalDateTimeStr = moment(_outRecords.signalDateTime).format("DD-MM-YYYY, HH:mm");
				
			for (j=0;j<_result.length;j++) {
				var _record 	= _result[j];
				var _scaqi 		= parseFloat(_record.scaqi);
				var _scaqi_prev = parseFloat(_record.scaqi_prev);
				console.log('process record ' + (j+1) + ' ' + _scaqi_prev + ' -> ' + _scaqi + ' for ' + _record.wk_naam);
			
				if (_scaqi == _scaqi_prev) continue;
							
				var outRecord = {};
				
				var signalResult = checkSignalValues(municipal.signalValues, _scaqi_prev, _scaqi);
					
				if (signalResult.signalValue) { 
					if (signalResult.direction == 'up') {
						outRecord.message = " Index voor luchtkwaliteit is gestegen boven grenswaarde " + signalResult.signalValue;	
					}
					if (signalResult.direction == 'down') {
						outRecord.message = " Index voor luchtkwaliteit is gedaald onder grenswaarde " + signalResult.signalValue;					
					}
					outRecord.gm_code 			= _record.gm_code;
					outRecord.gm_naam 			= _record.gm_naam; 
					outRecord.wk_naam 			= _record.wk_naam; 
					outRecord.wk_code 			= _record.wk_code; 
					outRecord.bu_naam 			= _record.bu_naam; 
					outRecord.bu_code 			= _record.bu_code; 
					outRecord.aant_inw_wijk		= parseInt(_record.aant_inw_wijk);
					outRecord.aant_inw_buurt	= parseInt(_record.aant_inw_buurt);
					outRecord.scaqi 			= _scaqi;
					outRecord.scaqi_prev 		= _scaqi_prev;
					outRecord.signalDateTime	= _outRecords.signalDateTime;
					outRecord.signalDateTimeStr	= _outRecords.signalDateTimeStr;
					if (outRecord.message) _outRecords.push(outRecord);
					
					socket.emit('aireassignal', {'signal': outRecord});
					
				}

			}

			
			if (_outRecords.length>0) {
				sendMail(email.emailAddress, 'AiREAS Signaal from system: ' + options.systemCode , _outRecords );
			}
		}
		
		
		for (i =0;i< apps.length;i++) {
			var app = apps[i];
			
			console.log('Signal function started for app: ' + app.app);
			var municipal = app.municipals[0];
			
			var _outRecords = [];
			_outRecords.signalDateTime = new Date();
			_outRecords.signalDateTimeStr = moment(_outRecords.signalDateTime).format("DD-MM-YYYY, HH:mm");
					
			for (j=0;j<_result.length;j++) {
				var _record 	= _result[j];
				var _scaqi 		= parseFloat(_record.scaqi);
				var _scaqi_prev = parseFloat(_record.scaqi_prev);
				console.log('process record ' + (j+1) + ' ' + _scaqi_prev + ' -> ' + _scaqi + ' for ' + _record.wk_naam);
				
				if (_scaqi == _scaqi_prev) continue;
								
				var outRecord = {};
				outRecord.gm_code 			= _record.gm_code;
				outRecord.gm_naam 			= _record.gm_naam; 
				outRecord.wk_naam 			= _record.wk_naam; 
				outRecord.wk_code 			= _record.wk_code; 
				outRecord.bu_naam 			= _record.bu_naam; 
				outRecord.bu_code 			= _record.bu_code; 
				outRecord.aant_inw_wijk		= parseInt(_record.aant_inw_wijk);
				outRecord.aant_inw_buurt	= parseInt(_record.aant_inw_buurt);
				outRecord.scaqi 			= _scaqi;
				outRecord.scaqi_prev 		= _scaqi_prev;
				outRecord.signalDateTime	= _outRecords.signalDateTime;
				outRecord.signalDateTimeStr	= _outRecords.signalDateTimeStr;
					
				var signalResult = checkSignalValues(municipal.signalValues, _scaqi_prev, _scaqi);
						
				if (signalResult.signalValue) { 
					if (signalResult.direction == 'up') {
						outRecord.message = "Index voor luchtkwaliteit is gestegen boven grenswaarde " + signalResult.signalValue+ "";	
					}
					if (signalResult.direction == 'down') {
						outRecord.message = "Index voor luchtkwaliteit is gedaald onder grenswaarde " + signalResult.signalValue+ "";					
					}
					socket.emit(app.messageType, {'signal': outRecord});
				}
				
				var _scaciDiff			= Math.round((_scaqi - _scaqi_prev)*10)/10;
				var _scaciDiffDirection	= _scaciDiff<0?'down':'up';
				//console.log(_scaciDiffDirection);
				_scaciDiff				= _scaciDiff<0?_scaciDiff*-1:_scaciDiff;
				//console.log(_scaciDiff);
				//console.log(app.signalDiffGt);
				if (_scaciDiff >= app.signalDiffGt) {
					if (_scaciDiffDirection == 'up') {
						outRecord.message = "Index voor luchtkwaliteit is gestegen met " + _scaciDiff + "";					
					}
					if (_scaciDiffDirection == 'down') {
						outRecord.message = "Index voor luchtkwaliteit is gedaald met " + _scaciDiff + "";	
					}
					socket.emit(app.messageType, {'signal': outRecord});
					console.log('websocket signal sent: '+ app.messageType);
				}
			}

		}
		setTimeout(function(e) {
			console.log('disconnect socket client');
			socket.disconnect();
			setTimeout(function(e) {
				console.log('end of process after disconnect socket client');
				return true;			
			},1000);
			return true;
		},1000);
		

	}); // end of inner function
		
	},
	
	executeSql: function(query, callback) {
		console.log('sql start: ');
		var client = new pg.Client(sqlConnString);
		client.connect(function(err) {
  			if(err) {
  	 	 		return console.error('could not connect to postgres', err);
  			}
  			client.query(query, function(err, result) {
    			client.end();
   		 		if(err) {
      				return console.error('error running query', err);
    			}
		//    		console.log('sql result: ' + result);
				callback(err, result);
  			});
		});
	},

	sendMail: function(to_email, subject, data) { 
		console.log('Sending mail to: ' + to_email + ' Subject: ' +
			subject + ' Date: ' + data.signalDateTimeStr );
	
		var templateResultHtml = templateWijk({
	  		data: data
		});

		transporter.sendMail({
    		from: 'awiel@scapeler.com',
    		to: to_email,
    		subject: subject,
    		html: templateResultHtml
		});
	},

	checkSignalValues: function(signalValues, scaqi_prev, scaqi) { 
		var result = {};
		if (signalValues == null || signalValues == [] ) {
			signalValues = [ 10 ];  //default signalValue
		}
	
		for (var i=0; i<signalValues.length;i++) {
			var _signalValue = signalValues[i];
			if (scaqi_prev < _signalValue && _signalValue <= scaqi ) {   // prev  signal  act
				result.direction = 'up';
				result.signalValue = _signalValue;
				console.log(' up found for signal ' + _signalValue );
				break;
			}
			if (scaqi < _signalValue && _signalValue <= scaqi_prev ) {   //  act   signal  prev
				result.direction = 'down';
				result.signalValue = _signalValue;
				console.log(' down found for signal ' + _signalValue );
				break;
			}
		}
		return result;
	}

} // end of module.exports



