/*
** Module: aireas-aqi-signal
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

var http 			= require('http');
var https 			= require('https');

var sqlConnString;
var transporter, emails, servers, apps, templateWijkSource, templateWijk, sql;
var checkSignalValues, sendMail, sendServer;

var testSession		= true;

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
		sendServer			= this.sendServer;

		emails = [
			{emailAddress: 'awiel@scapeler.com', aqiAreas: [ {area_code: 'EHV20141104:1', foi: [], signalValues: [] } ] }
			//,{emailAddress: 'john@schmeitz-advies.nl', aqiAreas: [ {area_code: 'EHV20141104:1', foi: [], signalValues: [] } ] }
		]

//// http://146.48.99.107:8080/gbwesense-service-webapp/webapi/alerts/new
//// oud: wesense.smart-applications.area.pi.cnr.it
//// http://wesense.smart-applications.area.pi.cnr.it:8080/gbwesense-service-webapp/webapi/alerts/new
// https://wesense.smart-applications.area.pi.cnr.it:8453/gbwesense-service-webapp/webapi/alerts/new

		servers = [ 
			{name: 'wesense', url: {protocol:'https', domain: 'wesense.smart-applications.area.pi.cnr.it', port: '8453', path: '/gbwesense-service-webapp/webapi/alerts/new'}, methode: 'POST', aqiAreas: [ {area_code: 'EHV20141104:1', foi: [], signalValues: [] } ], message: 'The air quality in this area is OVER the threshold! Have you any information on what is happening here? You can directly contribute to the monitoring through WeSense!', token:'K0689ka6s7p96j7NoVeY6ACT5Df01o9tOO1SW34849W3160LX357R4vva768UP8eZPIu1a21o1r8Gf4OutjCQi0ACq0GqD93' }
			//,{emailAddress: 'john@schmeitz-advies.nl', aqiAreas: [ {area_code: 'EHV20141104:1', foi: [], signalValues: [] } ] }
		]

		apps = [
			{app: 'humansensor', messageType: 'aireasaqisignal', aqiAreas: [ {area_code: 'EHV20141104:1', foi: [], signalValues: [] } ], signalDiffGt: 3 }
		]
		
		
		if (process.argv[3] == 'testserver') {
			emails 	= [];
			apps	= [];
			var _testserver = process.argv[4];
			var _servers = [];
			for (var i=0;i<servers.length;i++) {
				if (servers[i].name == _testserver) {
					_servers.push(servers[i]);
				}
			}
			servers = _servers;
			console.log('Test server: ' +  servers[0].name);
		};

		templateWijkSource	= "<h1>AiREAS AQI update</h1><p>Datum: {{data.signalDateTimeStr}}</p> \
    {{#each data}}<h2>AiREAS AQI Signal for area '{{gm_naam}}, airbox: {{feature_of_interest}}'</h2><p>{{message}}</p> \
	Area: {{gm_naam}} ({{grid_code}})<BR/> \
	Sensor: {{avg_type}}<BR/> \
	Previous AQI: {{avg_aqi_prev}}<BR/> \
	{{/each}}</div><BR/>";
	
		templateWijk		= handlebarsx.compile(templateWijkSource);				

		sql = " SELECT act.grid_code, gg.grid_desc, gg.gm_naam, act.feature_of_interest, act.avg_aqi_type, act.avg_type, act.avg_aqi, prev.avg_aqi avg_aqi_prev, act.retrieveddate, prev.retrieveddate retrieveddate_prev, to_char(act.retrieveddate, 'YYYY-MM-DD') || 'T' || to_char(act.retrieveddate, 'HH24:MI:SS') || to_char(extract('timezone_hour' from act.retrieveddate),'S00') ||':' || to_char(extract('timezone_minute' from act.retrieveddate),'FM00') as isodatetime, actlvl.aqi_class, prevlvl.aqi_class aqi_class_prev, actmainclass.aqi_color, prevmainclass.aqi_color aqi_color_prev, ab.airbox_location, ab.airbox_location_desc, ab.airbox_location_type, ab.airbox_postcode, ab.lat, ab.lng, '4326' as srid, ab.region, ab.identifier  \
FROM public.grid_gem_foi_aqi act \
, public.airbox ab \
, public.grid_gem_foi_aqi prev \
, public.aireas_aqi_level actlvl \
, public.aireas_aqi_level prevlvl \
, public.aireas_aqi_class actmainclass \
, public.aireas_aqi_class prevmainclass \
, public.grid_gem gg \
, (select max(retrieveddate) retrieveddate from public.grid_gem_foi_aqi) max  \
WHERE 1=1 \
AND act.avg_aqi_type = 'AiREAS_NL' \
AND act.avg_period = '1hr' \
AND act.avg_type = 'overall' \
AND act.feature_of_interest = ab.airbox \
AND gg.grid_code = act.grid_code \
AND act.retrieveddate = max.retrieveddate \
AND act.retrieveddate >= current_timestamp - interval '65 minutes' \
AND date_part('minute', act.retrieveddate) = 1 \
AND prev.retrieveddate >= act.retrieveddate - interval '65 minutes'  \
AND prev.retrieveddate < act.retrieveddate - interval '55 minutes'  \
AND act.grid_code = prev.grid_code \
AND act.feature_of_interest = prev.feature_of_interest \
AND act.avg_aqi_type = prev.avg_aqi_type \
AND act.avg_type = prev.avg_type \
AND act.avg_aqi > prev.avg_aqi \
AND actlvl.aqi_type = act.avg_aqi_type \
AND actlvl.sensor_type = act.avg_type \
AND act.avg_aqi >= actlvl.i_low \
AND act.avg_aqi < actlvl.i_high \
AND prev.avg_aqi >= prevlvl.i_low \
AND prev.avg_aqi < prevlvl.i_high \
AND actlvl.i_low <> prevlvl.i_low \
AND actlvl.aqi_type = prevlvl.aqi_type \
AND actlvl.sensor_type = prevlvl.sensor_type \
AND actlvl.aqi_class = actmainclass.aqi_class \
AND actmainclass.aqi_sub_class is null \
AND prevlvl.aqi_class = prevmainclass.aqi_class \
AND prevmainclass.aqi_sub_class is null \
AND actlvl.aqi_type = actmainclass.aqi_type \
AND prevlvl.aqi_type = prevmainclass.aqi_type \
 ";

/*
		
		
		"select max(wijk.gm_naam) gm_naam, max(wijk.gm_code) gm_code, max(wijk.wk_naam) wk_naam, max(buurt.bu_code) bu_code, max(buurt.bu_naam) bu_naam, \
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
*/

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
		
	
		var _result = result.rows; //JSON.parse(result);
		
		// mailing notifications / signals
		for (i =0;i< emails.length;i++) {
			var email = emails[i];
			console.log('AQI Signal function started for emailaddress: ' + email.emailAddress);
			var aqiArea = email.aqiAreas[0];
		
			var _outRecords = [];
			_outRecords.signalDateTime = new Date();
			_outRecords.signalDateTimeStr = moment(_outRecords.signalDateTime).format("DD-MM-YYYY, HH:mm");
				
			for (j=0;j<_result.length;j++) {
				var _record 		= _result[j];
				var _avg_aqi 		= parseFloat(_record.avg_aqi);
				var _avg_aqi_prev	= parseFloat(_record.avg_aqi_prev);
				console.log('process record ' + (j+1) + ' ' + _avg_aqi_prev + ' -> ' + _avg_aqi + ' for ' + _record.gm_naam + ' is ' + _record.aqi_class + ' was ' + _record.aqi_class_prev );
			
				var outRecord = {};
				
				if (_record.aqi_class != _record.aqi_class_prev) {
				
//				var signalResult = checkSignalValues(aqiArea.signalValues, _avg_aqi_prev, _avg_aqi);
					
//				if (signalResult.signalValue) { 
//					if (signalResult.direction == 'up') {
//						outRecord.message = " AQI increase to " + signalResult.signalValue;	
//					}
//					if (signalResult.direction == 'down') {
//						outRecord.message = " AQI decrease to " + signalResult.signalValue;					
//					}
					outRecord.grid_code 			= _record.grid_code;
					outRecord.grid_desc 			= _record.grid_desc;
					outRecord.gm_naam 				= _record.gm_naam; 
					outRecord.feature_of_interest	= _record.feature_of_interest; 
					outRecord.avg_aqi_type			= _record.avg_aqi_type; 
					outRecord.avg_type 				= _record.avg_type; 
					outRecord.avg_aqi 				= _avg_aqi;
					outRecord.avg_aqi_prev 			= _avg_aqi_prev;
					outRecord.aqi_class 			= _record.aqi_class;
					outRecord.aqi_class_prev 		= _record.aqi_class_prev;
					outRecord.aqi_color		 		= _record.aqi_color;
					outRecord.aqi_color_prev 		= _record.aqi_color_prev;
					outRecord.aqi_datetime			= _outRecords.signalDateTime;
					outRecord.signalDateTimeStr		= _outRecords.signalDateTimeStr;
	
					outRecord.message = "AQI " + outRecord.avg_aqi_type + ": " + _avg_aqi;

					if (outRecord.message) _outRecords.push(outRecord);
									
//				}

				}

			}

			
			if (_outRecords.length>0) {
				sendMail(email.emailAddress, 'AiREAS AQI Signal from system: ' + options.systemCode , _outRecords );
			}
		}
		

		// push notifications / signals / alerts / events to server
		for (i =0;i< servers.length;i++) {
			var server = servers[i];
			console.log('AQI Signal function started for server: ' + server.name);
			var aqiArea = server.aqiAreas[0];
		
			var _outRecords = [];
			_outRecords.signalDateTime = new Date();
			_outRecords.signalDateTimeStr = moment(_outRecords.signalDateTime).format("DD-MM-YYYY, HH:mm");
			
			if (process.argv[4] == server.name && process.argv[3] == 'testserver' ) {
				testSession = true;
			} else {
				testSession = false; 
			}
				
			for (j=0;j<_result.length;j++) {
				var _record 		= _result[j];
				var _avg_aqi 		= parseFloat(_record.avg_aqi);
				var _avg_aqi_prev	= parseFloat(_record.avg_aqi_prev);
				console.log('process record ' + (j+1) + ' ' + _avg_aqi_prev + ' -> ' + _avg_aqi + ' for ' + _record.gm_naam + ' is ' + _record.aqi_class + ' was ' + _record.aqi_class_prev );

				if (server.name == 'wesense' && _record.feature_of_interest == 'overall' ) continue;  // skip overall signals like city signal. only airbox for wesense!
				//if (server.name == 'wesense' && _record.feature_of_interest == 'overall' ) continue;  // skip overall signals like city signal. only airbox for wesense!
			
				var outRecord = {};

				if (testSession == true || _record.aqi_class != _record.aqi_class_prev) {
				
//				var signalResult = checkSignalValues(aqiArea.signalValues, _avg_aqi_prev, _avg_aqi);
					
//				if (signalResult.signalValue) { 
//					if (signalResult.direction == 'up') {
//						outRecord.message = " AQI increase to " + signalResult.signalValue;	
//					}
//					if (signalResult.direction == 'down') {
//						outRecord.message = " AQI decrease to " + signalResult.signalValue;					
//					}

					outRecord.event_type; 'treshold exceeded';

					outRecord.grid_code 			= _record.grid_code;
					outRecord.grid_desc 			= _record.grid_desc;
					outRecord.gm_naam 				= _record.gm_naam; 
					outRecord.feature_of_interest	= _record.feature_of_interest; 
					outRecord.avg_aqi_type			= _record.avg_aqi_type; 
					outRecord.avg_type 				= _record.avg_type; 
					outRecord.avg_aqi 				= _avg_aqi;
					outRecord.avg_aqi_prev 			= _avg_aqi_prev;
					outRecord.aqi_class 			= _record.aqi_class;
					outRecord.aqi_class_prev 		= _record.aqi_class_prev;
					outRecord.aqi_color		 		= _record.aqi_color;
					outRecord.aqi_color_prev 		= _record.aqi_color_prev;
					outRecord.aqi_isodatetime		= _record.isodatetime;
					outRecord.foiLocation			= _record.airbox_location;
					outRecord.foiLocationDesc		= _record.airbox_location_desc;
					outRecord.foiLocationType		= _record.airbox_location_type;
					outRecord.zipCode				= _record.airbox_postcode;
					outRecord.lat					= _record.lat;
					outRecord.lng					= _record.lng;
					outRecord.srid					= _record.srid;
					outRecord.foiRegion				= _record.region;
					outRecord.foiIdentifier			= _record.identifier;
					outRecord.countryCode			= 'NL';
					outRecord.aqi_datetime			= _outRecords.signalDateTime;
					outRecord.signalDateTimeStr		= _outRecords.signalDateTimeStr;
					
					if (servers[i].message != undefined) {
						outRecord.message = servers[i].message;
					} else {
						outRecord.message = "AQI " + outRecord.avg_aqi_type + ": " + _avg_aqi;
					}
					
					_outRecords.push(outRecord);									
//				}
				}
			}

			if (_outRecords.length>0 || process.argv[3] == 'testserver' ) {
				sendServer(server, 'AiREAS AQI Signal from system: ' + options.systemCode , _outRecords );
			}
		}






		
		//var socket = require('socket.io-client')('https://openiod.org',{path: '/SCAPE604/socket.io'});
		var socket = require('socket.io-client')('http://149.210.208.157:3010',{path: '/SCAPE604/socket.io'});
		// emit web-socket for notification to apps
		socket.on('connect', function () {
			console.log('connected ');
		});	
		socket.on( 'info', function (data) {
			console.log('info '+data.nrOfConnections);
		});

		
		for (i =0;i< apps.length;i++) {
			var app = apps[i];
			
			console.log('AQI Signal function started for app: ' + app.app);
			var aqiArea = app.aqiAreas[0];
			
			var _outRecords = [];
			_outRecords.signalDateTime = new Date();
			_outRecords.signalDateTimeStr = moment(_outRecords.signalDateTime).format("DD-MM-YYYY, HH:mm");
					
			for (j=0;j<_result.length;j++) {
				var _record 	= _result[j];
				var _avg_aqi 		= parseFloat(_record.avg_aqi);
				var _avg_aqi_prev	= parseFloat(_record.avg_aqi_prev);
				console.log('process record ' + (j+1) + ' ' + _avg_aqi_prev + ' -> ' + _avg_aqi + ' for ' + _record.gm_naam + ' is ' + _record.aqi_class + ' was ' + _record.aqi_class_prev );
				
				var outRecord = {};
				
				if (_record.aqi_class != _record.aqi_class_prev) {

				outRecord.grid_code 			= _record.grid_code;
				outRecord.grid_desc 			= _record.grid_desc;
				outRecord.gm_naam 				= _record.gm_naam; 
				outRecord.feature_of_interest	= _record.feature_of_interest; 
				outRecord.avg_aqi_type			= _record.avg_aqi_type; 
				outRecord.avg_type 				= _record.avg_type; 
				outRecord.avg_aqi 				= _avg_aqi;
				outRecord.avg_aqi_prev 			= _avg_aqi_prev;
				outRecord.aqi_class 			= _record.aqi_class;
				outRecord.aqi_class_prev 		= _record.aqi_class_prev;
				outRecord.aqi_color		 		= _record.aqi_color;
				outRecord.aqi_color_prev 		= _record.aqi_color_prev;
				outRecord.aqi_datetime			= _outRecords.signalDateTime;
				outRecord.signalDateTimeStr		= _outRecords.signalDateTimeStr;
					
//				var signalResult = checkSignalValues(aqiArea.signalValues, _avg_aqi_prev, _avg_aqi);
						
//				if (signalResult.signalValue) { 
//					if (signalResult.direction == 'up') {
//						outRecord.message = " AQI increase to " + signalResult.signalValue;	
//					}
//					if (signalResult.direction == 'down') {
//						outRecord.message = " AQI decrease to " + signalResult.signalValue;					
//					}
//					socket.emit(app.messageType, {'signal': outRecord});
//				}

				outRecord.message = "AQI " + outRecord.avg_aqi_type + ": " + _avg_aqi;	
				socket.emit(app.messageType, {'signal': outRecord});
				
/*
				var _scaciDiff			= Math.round((_avgAqi - _avgAqi_prev)*10)/10;
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
*/

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
		//console.log(query);
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
    		from: 'info@scapeler.com',
    		to: to_email,
    		subject: subject,
    		html: templateResultHtml
		});
	},

	sendServer: function(server, subject, data) {
		console.log('Sending push message to: ' + server.name + ' Subject: ' +
			subject + ' Date: ' + data.signalDateTimeStr );
		//todo
		
		//create JSON
		var eventObject 				= {};
		eventObject.source 				= {};
		eventObject.source.server		= 'test';
		eventObject.source.status		= 'test';  
		eventObject.source.name			= 'AiREAS';
		eventObject.source.desc			= 'AiREAS AQI events';
		eventObject.source.version		= '0.2';
		eventObject.source.dateTime		= data[0]!=undefined?data[0].aqi_isodatetime:'test';
		eventObject.source.identifier	= 'http://wiki.aireas.com/index.php/aireas_aqi_events';
		if (process.argv[3] == 'testserver') {
			eventObject.source.status		= 'test';
		}

		
		
		eventObject.events 				= [];
		
		for (var i=0;i<data.length;i++) {
			var _dataRec 				= data[i];
			var event 					= {};
			event.foi 					= {};
			event.foi.identifier 		= _dataRec.foiIdentifier;
			event.foi.code 				= _dataRec.feature_of_interest;
			event.foi.address 			= _dataRec.foiLocation;
			event.foi.zipCode 			= _dataRec.zipCode;
			event.foi.city	 			= _dataRec.gm_naam;
			event.foi.locationDesc 		= _dataRec.foiLocationDesc;
			event.foi.locationType 		= _dataRec.foiLocationType;
			event.foi.region 			= _dataRec.foiRegion;
			event.foi.countryCode 		= _dataRec.countryCode;
			event.foi.lat 				= _dataRec.lat;
			event.foi.lon 				= _dataRec.lng;
			event.foi.srid 				= _dataRec.srid;
			event.aqiType 				= _dataRec.avg_aqi_type;
			event.observedProp			= _dataRec.avg_type;
			event.event					= {};
			event.event.type			= _dataRec.event_type; 'treshold exceeded';
			event.event.value			= _dataRec.avg_aqi;
			event.event.valuePrev		= _dataRec.avg_aqi_prev;
			event.event.evClass			= _dataRec.aqi_class;
			event.event.evClassPrev		= _dataRec.aqi_class_prev;
			event.event.color			= _dataRec.aqi_color;
			event.event.colorPrev		= _dataRec.aqi_color_prev;
			event.event.isoDateTime		= _dataRec.aqi_isodatetime;
			event.event.message			= _dataRec.message;
			event.area					= {};
			event.area.code				= _dataRec.grid_code;
			event.area.desc				= _dataRec.grid_desc;
			event.area.name				= _dataRec.gm_naam;
			eventObject.events.push(event);
			console.log(' Event treshold: ' + event.foi.code + ' is: ' + event.event.value +' ' + event.event.evClass + ' was: ' + event.event.valuePrev +' ' + event.event.evClassPrev );
		}
		
		
		if (data.length == 0 && process.argv[3] == 'testserver') {
			var event 					= {};
			event.foi 					= {};
			event.foi.identifier 		= 'http://wiki.aireas.com/index.php/airbox_0019';
			event.foi.code 				= '19.cal';
			event.foi.address 			= 'Finisterelaan 45';
			event.foi.zipCode 			= '5627TE';
			event.foi.city	 			= 'Eindhoven';
			event.foi.locationDesc 		= 'Rand van woonwijk, nabij A2/A50 (meest nabijgelegen rijbaan 104 m tot straatlantaarn (woningen en wal ertussen))';
			event.foi.locationType 		= 'woonwijk';
			event.foi.region 			= 'EHV';
			event.foi.countryCode 		= 'NL';
			event.foi.lat 				= 51.4914155166667;
			event.foi.lon 				= 5.43919825;
			event.foi.srid 				= '4326';
			event.aqiType 				= 'AiREAS_NL';
			event.observedProp			= 'overall';
			event.event					= {};
			event.event.type			= 'treshold exceeded';
			event.event.value			= 52;
			event.event.valuePrev		= 43;
			event.event.evClass			= 'Moderate';
			event.event.evClassPrev		= 'Good';
			event.event.color			= '#ffff04';
			event.event.colorPrev		= '#00b0f0';
			event.event.isoDateTime		= '2016-11-09T17:01:01+01:00';
			event.event.message			= 'The air quality in this area is OVER the threshold! Have you any information on what is happening here? You can directly contribute to the monitoring through WeSense!';
			event.area					= {};
			event.area.code				= 'EHV20141104:1';
			event.area.desc				= 'Grid Eindhoven 2014-11-05 variant 1';
			event.area.name				= 'Eindhoven';
			eventObject.events.push(event);
		}
		
		

				
		
		var post_data = JSON.stringify({
			data : eventObject
		});
		
		var post_options = {
			host: server.url.domain,
			port: server.url.port,
			path: server.url.path,
			method: server.methode,
			headers: {
				'Content-Type': 'application/json',
				'Content-Length': Buffer.byteLength(post_data),
				'Token': server.token
			}
		};
		//POST message
		// Set up the request
		console.log('Request for ' + server.url.protocol + '://' + server.url.domain + ':' + server.url.port + '/' + server.url.path);
		
		var post_req;
		if (server.url.protocol == 'https') {
			post_req = https.request(post_options, function(res) {
				res.setEncoding('utf8');
				res.on('data', function (chunk) {
					console.log('Response: ' + res.statusCode + ' ' + chunk);
				});
			});
		} else {
			post_req = http.request(post_options, function(res) {
				res.setEncoding('utf8');
				res.on('data', function (chunk) {
					console.log('Response: ' + res.statusCode + ' ' + chunk);
				});
			});
		}

		post_req.on('error', function (err) {
			console.log('ERROR: ' + err);
		});
		
		// post the data
		console.log('Post options: ' + post_options);
		console.log('Post data: ' + post_data);
		post_req.write(post_data);
		post_req.end();
	
	},


	checkSignalValues: function(signalValues, avgAqi_prev, avgAqi) { 
		var result = {};
		if (signalValues == null || signalValues == [] ) {
			signalValues = [ 10 ];  //default signalValue
		}
	
		for (var i=0; i<signalValues.length;i++) {
			var _signalValue = signalValues[i];
			if (avgAqi_prev < _signalValue && _signalValue <= avgAqi ) {   // prev  signal  act
				result.direction = 'up';
				result.signalValue = _signalValue;
				console.log(' increase found for signal ' + _signalValue );
				break;
			}
			if (avgAqi < _signalValue && _signalValue <= avgAqi_prev ) {   //  act   signal  prev
				result.direction = 'down';
				result.signalValue = _signalValue;
				console.log(' decrease found for signal ' + _signalValue );
				break;
			}
		}
		return result;
	}

} // end of module.exports



