/*
** Module: node-aireas
**
**
**
**
*/

"use strict"; // This is for your code to comply with the ECMAScript 5 standard.

var main_module = 'node_aireas';
var moduleScapeAireasPath = require('path').resolve(__dirname, 'node_modules/scape-aireas/../..');
var apriConfig 	= require(moduleScapeAireasPath + '/apri-config');
apriConfig.init(main_module);

// **********************************************************************************

// add module specific requires
var request 		= require('request');
var express 		= require('express');
var cookieParser 	= require('cookie-parser');
var session 		= require('express-session');
var uid 			= require('uid-safe');
//var bodyParser 		= require('connect-busboy');
var fs 				= require('fs');
var _systemCode = apriConfig.getSystemCode();

var apriAireasGetPg 	= require('./node-aireas-get-pg');
apriAireasGetPg.init({
		systemFolderParent: apriConfig.getSystemFolderParent(),
		configParameter: apriConfig.getConfigParameter(),
		systemCode: apriConfig.getSystemCode()
	});
	

var app = express();


var sess = {
  	  secret: 'keyboscapelard cat'
  	, resave:true
	, saveUninitialized:true
  	, cookie: {
	// maxAge: 60000 
	}
}

if (app.get('env') === 'production') {
  	app.set('trust proxy', 1) // trust first proxy (app.enable('trust proxy');)
  	sess.cookie.secure = true // serve secure cookies
}

app.use(cookieParser());
app.use(session(sess));

app.use(function(req, res, next) {
//	console.log('Check for session info');
	if (req.session) {
  		var _sessionInfo = req.session;
		console.log('Session info found '+'req.cookies: ' + req.cookies['connect.sid'] + ' session.views ' + _sessionInfo.views);

  		if (_sessionInfo.views) {
			_sessionInfo.views++;
  		} else {
			_sessionInfo.views = 1;
			if(typeof req.cookies['connect.sid'] !== 'undefined'){
        		console.log('req.cookies: ' + req.cookies['connect.sid']);
    		}
			console.log('Session info init '+'req.session: ' + JSON.stringify(req.session) );
			console.log('Session info init '+'req.cookies: ' + JSON.stringify(req.cookies) +' ' + req.cookies['connect.sid'] + ' session.views ' + _sessionInfo.views);
  		}
		res.cookie('reqcount', _sessionInfo.views, { expires: new Date(Date.now() + 900000), httpOnly: true });
  	}

	next();
});


// **********************************************************************************


app.all('/*', function(req, res, next) {
  console.log("app.all/: " + req.url + " ; systemCode: " + _systemCode );
  next();
});



app.get('/'+_systemCode+'/data/aireas/:getFunction/:airbox', function(req, res) {
  console.log("data request: " + req.url );
  if (	req.params.getFunction == 'getAllMeasures' 		|| 
  		req.params.getFunction == 'getLastWeekMeasures') {
		apriAireasGetPg.getMeasures({airbox: req.params.airbox, getFunction: req.params.getFunction }, function(err, result) {
			res.contentType('application/json');
 			res.send(result.rows);
		});
		return;
  }
  
  if (	req.params.getFunction == 'getMeasureStatisticsStddev' || 
  		req.params.getFunction == 'getMeasureStatisticsAvg' ) {
		apriAireasGetPg.getMeasureStatistics({ getFunction: req.params.getFunction }, function(err, result) {
			var _outRecords = [];
			var _result = result.rows; 
			for (var i=0;i<_result.length;i++) {
				var outRecord = {};
				outRecord.geometry = JSON.parse(_result[i].geom);
				outRecord.type = 'Feature';

				outRecord.properties = {};

				outRecord.properties.pm_all_statistic 		= parseFloat(_result[i].pm_all_statistic);

				_outRecords.push(outRecord);
			}
			var outRecords = JSON.stringify(_outRecords);
			res.contentType('application/json');
 			res.send(outRecords);
		});
		return;
  }


  if (	req.params.getFunction == 'getActualMeasures' ) {
		apriAireasGetPg.getMeasures({airbox: req.params.airbox, getFunction: req.params.getFunction }, function(err, result) {
			var _outRecords = [];
			var _result = result.rows; 
			for (var i=0;i<_result.length;i++) {
				var outRecord = {};
				outRecord.geometry = JSON.parse(_result[i].geom4326);
				outRecord.type = 'Feature';

				outRecord.properties = {};
				outRecord.properties.gid 					= _result[i].gid;
				outRecord.properties.airbox 				= _result[i].airbox; 
				outRecord.properties.airbox_type 			= _result[i].airbox_type; 
				outRecord.properties.airbox_location 		= _result[i].airbox_location; 
				outRecord.properties.airbox_location_desc 	= _result[i].airbox_location_desc; 
				outRecord.properties.airbox_location_type 	= _result[i].airbox_location_type; 
				outRecord.properties.airbox_postcode 		= _result[i].airbox_postcode; 
				outRecord.properties.airbox_x 				= _result[i].airbox_x; 
				outRecord.properties.airbox_y 				= _result[i].airbox_y; 
				outRecord.properties.mutation_date 			= _result[i].mutation_date; 
				outRecord.properties.creation_date 			= _result[i].creation_date; 

				outRecord.properties.retrieveddate	= _result[i].retrieveddate;

				outRecord.properties.gpslat 	= parseFloat(_result[i].gpslatfloat);
				outRecord.properties.gpslng 	= parseFloat(_result[i].gpslngfloat);
				outRecord.properties.pm1 		= parseFloat(_result[i].pm1float);
				outRecord.properties.pm25 		= parseFloat(_result[i].pm25float);
				outRecord.properties.pm10 		= parseFloat(_result[i].pm10float);
				outRecord.properties.ufp 		= parseFloat(_result[i].ufpfloat);
				outRecord.properties.ozon 		= parseFloat(_result[i].ozonfloat);
				outRecord.properties.hum 		= parseFloat(_result[i].humfloat);
				outRecord.properties.celc 		= parseFloat(_result[i].celcfloat);
				outRecord.properties.no2 		= parseFloat(_result[i].no2float);

				_outRecords.push(outRecord);
			}
			var outRecords = JSON.stringify(_outRecords);
			res.contentType('application/json');
 			res.send(outRecords);
		});
		return;
  }

 
	if (req.params.getFunction == 'getAireasGridGemInfo') {
		apriAireasGetPg.getGridGemAireasInfo({airbox: req.params.airbox }, req.query, function(err, result) {
			var _outRecords = [];
			var _result = result.rows; //JSON.parse(result);
			for (var i=0;i<_result.length;i++) {
				var outRecord = {};
				outRecord.geometry = JSON.parse(_result[i].geom);
				outRecord.type = 'Feature';

				outRecord.properties = {};
				outRecord.properties.gm_code 		= _result[i].gm_code;
				outRecord.properties.gm_naam 		= _result[i].gm_naam; 
				outRecord.properties.retrieveddate	= _result[i].retrieveddate;

				outRecord.properties.avg_type 		= _result[i].avg_type;
				outRecord.properties.avg_avg		= parseFloat(_result[i].avg_avg);

				//outRecord.properties.avg_pm1_hr 	= parseFloat(_result[i].avg_pm1_hr);
				//outRecord.properties.avg_pm25_hr 	= parseFloat(_result[i].avg_pm25_hr);
				//outRecord.properties.avg_pm10_hr 	= parseFloat(_result[i].avg_pm10_hr);
				//outRecord.properties.avg_pm_all_hr 	= parseFloat(_result[i].avg_pm_all_hr);
				outRecord.properties.cell_x 		= parseFloat(_result[i].cell_x);
				outRecord.properties.cell_y 		= parseFloat(_result[i].cell_y);

				_outRecords.push(outRecord);
			}
			var outRecords = JSON.stringify(_outRecords);
			res.contentType('application/json');
 			res.send(outRecords);
		});
		return;
  }

	if (req.params.getFunction == 'getAireasHistGridGemInfo') {
		apriAireasGetPg.getGridGemAireasHistInfo({airbox: req.params.airbox }, req.query, function(err, result) {
			var _outRecords = [];
			var _result = result.rows; //JSON.parse(result);
			for (var i=0;i<_result.length;i++) {
				var outRecord = {};
				outRecord.geometry = JSON.parse(_result[i].geom);
				outRecord.type = 'Feature';

				outRecord.properties = {};
				outRecord.properties.gm_code 		= _result[i].gm_code;
				outRecord.properties.gm_naam 		= _result[i].gm_naam; 
				outRecord.properties.hist_year		= _result[i].hist_year;
				outRecord.properties.hist_month		= _result[i].hist_month;
				outRecord.properties.hist_day		= _result[i].hist_day;

				outRecord.properties.avg_type 		= _result[i].avg_type;
				outRecord.properties.avg_avg		= parseFloat(_result[i].avg_avg);

				//outRecord.properties.avg_pm1_hr 	= parseFloat(_result[i].avg_pm1_hr);
				//outRecord.properties.avg_pm25_hr 	= parseFloat(_result[i].avg_pm25_hr);
				//outRecord.properties.avg_pm10_hr 	= parseFloat(_result[i].avg_pm10_hr);
				//outRecord.properties.avg_pm_all_hr 	= parseFloat(_result[i].avg_pm_all_hr);
				outRecord.properties.cell_x 		= parseFloat(_result[i].cell_x);
				outRecord.properties.cell_y 		= parseFloat(_result[i].cell_y);

				_outRecords.push(outRecord);
			}
			var outRecords = JSON.stringify(_outRecords);
			res.contentType('application/json');
 			res.send(outRecords);
		});
		return;
  }



	if (req.params.getFunction == 'getCbsGemInfo') {
		apriAireasGetPg.getGemInfo({gm_naam: req.query.gm_naam, gm_code: req.query.gm_code }, function(err, result) {
			var _outRecords = [];
			var _result = result.rows; //JSON.parse(result);
			for (var i=0;i<_result.length;i++) {
				var outRecord = {};
				outRecord.geometry = JSON.parse(_result[i].geom);
				outRecord.type = 'Feature';
				outRecord.envelope = JSON.parse(_result[i].envelope_geom);
				outRecord.centroid = JSON.parse(_result[i].centroid);

				outRecord.properties = {};
				outRecord.properties.gm_code = _result[i].gm_code;
				outRecord.properties.gm_naam = _result[i].gm_naam; 

				_outRecords.push(outRecord);
			}
			var outRecords = JSON.stringify(_outRecords);
			res.contentType('application/json');
 			res.send(outRecords);
		});
		return;
  }
  
  if (req.params.getFunction == 'getCbsGemeenten') {
		apriAireasGetPg.getCbsGemeenten({}, function(err, result) {
			var _outRecords = {};
			var _result = result.rows; //JSON.parse(result);
			for (var i=0;i<_result.length;i++) {
				var _gm_naam 	= _result[i].gm_naam;
				_outRecords[_gm_naam] 		= {};
				_outRecords[_gm_naam].id 	= _result[i].gm_code;
				_outRecords[_gm_naam].name 	= _result[i].gm_naam; 
			}
			var outRecords = JSON.stringify(_outRecords);
			res.contentType('application/json');
 			res.send(outRecords);
		});
		return;
  }


  if (req.params.getFunction == 'getCbsBuurtRookRisicoInfo') {
		apriAireasGetPg.getBuurtRookRisicoInfo({gm_naam: req.params.gemeente //, lat:req.query.lat, lng:req.query.lng 
			}, function(err, result) {
			var _outRecords = [];
			var _result = result.rows;
			for (var i=0;i<_result.length;i++) {
				var outRecord = {};
				outRecord.geometry = JSON.parse(_result[i].geom);
				outRecord.type = 'Feature';

				outRecord.properties = {};
				outRecord.properties.objectId = _result[i].gm_code + _result[i].bu_code;
				outRecord.properties.bu_naam = _result[i].bu_naam; 
				outRecord.properties.aantal_markers = Math.round(parseInt(_result[i].aantal_markers)); 

				_outRecords.push(outRecord);
			}
			var outRecords = JSON.stringify(_outRecords);
			res.contentType('application/json');
 			res.send(outRecords);
		});
		return;
  }


  if (req.params.getFunction == 'setBuurtRookRisicoMarker') {
		apriAireasGetPg.setBuurtRookRisicoMarker({lat:req.query.lat, lng:req.query.lng, markerDate: req.query.markerDate
			}, function(err, result) {
			var _outRecord = {};
			if (err == null) {
				_outRecord.markerOk = true;
			} else {
				_outRecord.markerOk = false;
			}
			var outRecord = JSON.stringify(_outRecord);
			res.contentType('application/json');
 			res.send(outRecord);
		});
		return;
  }


  if (req.params.getFunction == 'getCbsBuurtInfo') {
		apriAireasGetPg.getBuurtInfo({gm_naam: req.params.gemeente }, function(err, result) {
			var _outRecords = [];
			var _result = result.rows; 
			for (var i=0;i<_result.length;i++) {
				var outRecord = {};
				outRecord.geometry = JSON.parse(_result[i].geom);
				outRecord.type = 'Feature';

				outRecord.properties = {};
				outRecord.properties.objectId = _result[i].gm_code + _result[i].bu_code;
				outRecord.properties.bu_naam = _result[i].bu_naam; 
				outRecord.properties.wk_code = _result[i].wk_code; 
				outRecord.properties.gm_naam = _result[i].gm_naam; 
				outRecord.properties.p_00_14_jr = Math.round(parseInt(_result[i].p_00_14_jr)); 
				outRecord.properties.p_15_24_jr = Math.round(parseInt(_result[i].p_15_24_jr)); 
				outRecord.properties.p_25_44_jr = Math.round(parseInt(_result[i].p_25_44_jr)); 
				outRecord.properties.p_45_64_jr = Math.round(parseInt(_result[i].p_45_64_jr)); 
				outRecord.properties.p_65_eo_jr = Math.round(parseInt(_result[i].p_65_eo_jr));
				outRecord.properties.p_00_14_jr = outRecord.properties.p_00_14_jr<=0?0:outRecord.properties.p_00_14_jr;
				outRecord.properties.p_15_24_jr = outRecord.properties.p_15_24_jr<=0?0:outRecord.properties.p_15_24_jr;
				outRecord.properties.p_25_44_jr = outRecord.properties.p_25_44_jr<=0?0:outRecord.properties.p_25_44_jr;
				outRecord.properties.p_45_64_jr = outRecord.properties.p_45_64_jr<=0?0:outRecord.properties.p_45_64_jr;
				outRecord.properties.p_65_eo_jr = outRecord.properties.p_65_eo_jr<=0?0:outRecord.properties.p_65_eo_jr;

				_outRecords.push(outRecord);
			}
			var outRecords = JSON.stringify(_outRecords);
			res.contentType('application/json');
 			res.send(outRecords);
		});
		return;
  }

  if (req.params.getFunction == 'getCbsBuurtAireasInfo') {
		apriAireasGetPg.getBuurtAireasInfo({gm_naam: req.params.gemeente }, function(err, result) {
			var _outRecords = [];
			var _result = result.rows; //JSON.parse(result);
			for (var i=0;i<_result.length;i++) {
				var outRecord = {};
				outRecord.geometry = JSON.parse(_result[i].geom);
				outRecord.type = 'Feature';
				outRecord.centroid = JSON.parse(_result[i].centroid);

				outRecord.properties = {};
				outRecord.properties.objectId = _result[i].gm_code + _result[i].bu_code;
				outRecord.properties.bu_naam = _result[i].bu_naam; 
				outRecord.properties.wk_code = _result[i].wk_code; 
				outRecord.properties.gm_naam = _result[i].gm_naam; 
				outRecord.properties.p_00_14_jr = Math.round(parseInt(_result[i].p_00_14_jr)); 
				outRecord.properties.p_15_24_jr = Math.round(parseInt(_result[i].p_15_24_jr)); 
				outRecord.properties.p_25_44_jr = Math.round(parseInt(_result[i].p_25_44_jr)); 
				outRecord.properties.p_45_64_jr = Math.round(parseInt(_result[i].p_45_64_jr)); 
				outRecord.properties.p_65_eo_jr = Math.round(parseInt(_result[i].p_65_eo_jr));
				outRecord.properties.p_00_14_jr = outRecord.properties.p_00_14_jr<=0?0:outRecord.properties.p_00_14_jr;
				outRecord.properties.p_15_24_jr = outRecord.properties.p_15_24_jr<=0?0:outRecord.properties.p_15_24_jr;
				outRecord.properties.p_25_44_jr = outRecord.properties.p_25_44_jr<=0?0:outRecord.properties.p_25_44_jr;
				outRecord.properties.p_45_64_jr = outRecord.properties.p_45_64_jr<=0?0:outRecord.properties.p_45_64_jr;
				outRecord.properties.p_65_eo_jr = outRecord.properties.p_65_eo_jr<=0?0:outRecord.properties.p_65_eo_jr;

				outRecord.properties.pm1_avg_hr 	= parseFloat(_result[i].pm1_avg_hr);
				outRecord.properties.pm25_avg_hr 	= parseFloat(_result[i].pm25_avg_hr);
				outRecord.properties.pm10_avg_hr 	= parseFloat(_result[i].pm10_avg_hr);



				_outRecords.push(outRecord);
			}
			var outRecords = JSON.stringify(_outRecords);
			res.contentType('application/json');
 			res.send(outRecords);
		});
		return;
  }

  res.contentType('text/plain');
  res.send('Wrong get function: ' + req.params.getFunction);
});


app.get('/'+_systemCode+'/data/nsl/:getFunction/:object', function(req, res) {
  	console.log("data request: " + req.url );

	// measures = maatregelen
  	if ( req.params.getFunction == 'getNslMeasuresInfo') {
		apriNslGetPg.getNslMeasuresInfo({getFunction: req.params.getFunction }, function(err, result) {
			var _outRecords = [];
			var _result = result.rows; //JSON.parse(result);
			for (var i=0;i<_result.length;i++) {
				var outRecord = {};
				outRecord.geometry = JSON.parse(_result[i].geom);
				outRecord.type = 'Feature';

				outRecord.properties = {};
				outRecord.properties.maatr_id 	= _result[i].maatr_id;
				outRecord.properties.naam 		= _result[i].naam; 
				outRecord.properties.overheid 	= _result[i].overheid; 
				outRecord.properties.gm_naam 	= _result[i].gm_naam; 
				outRecord.properties.categorie 	= _result[i].categorie; 
				outRecord.properties.stof 		= _result[i].stof; 
				outRecord.properties.factor 	= parseFloat(_result[i].factor); 
				outRecord.properties.generiek 	= _result[i].generiek; 
				outRecord.properties.voertuig 	= _result[i].voertuig; 
				outRecord.properties.snelheid 	= _result[i].snelheid; 
				outRecord.properties.actie 		= _result[i].actie; 
				outRecord.properties.gewijzigd 	= _result[i].gewijzigd; 

				_outRecords.push(outRecord);
			}
			var outRecords = JSON.stringify(_outRecords);
			res.contentType('application/json');
 			res.send(outRecords);
		});
		return;
  	}
  
	// result = volgens rekenmodel berekende waarden o.a voor pm10, pm25
  	if ( req.params.getFunction == 'getNslResultSpmiAvgInfo') {
		apriNslGetPg.getNslResultSpmiAvgInfo({getFunction: req.params.getFunction, rekenJaar: req.query.rekenjaar }, function(err, result) {
			var _outRecords = [];
			var _result = result.rows; //JSON.parse(result);
			for (var i=0;i<_result.length;i++) {
				var outRecord = {};
				outRecord.geometry = JSON.parse(_result[i].geom);
				outRecord.type = 'Feature';

				outRecord.properties = {};
				outRecord.properties.rekenjaar 	= _result[i].rekenjaar;
				outRecord.properties.spmi_avg 	= _result[i].spmi_avg;

				_outRecords.push(outRecord);
			}
			var outRecords = JSON.stringify(_outRecords);
			res.contentType('application/json');
 			res.send(outRecords);
		});
		return;
  	}
  
  
  	res.contentType('text/plain');
  	res.send('NSL Wrong get function: ' + req.params.getFunction);
});

app.get('/'+_systemCode+'/data/om/:getFunction/:object', function(req, res) {
  	console.log("data request: " + req.url );

	// measures = maatregelen
	if ( req.params.getFunction == 'getActualMeasures' ) {
	
		var _param 							= {};
		_param.name 						= 'Observation';
		_param.getFunction					= req.params.getFunction;
		_param.name 						= "test O&M";
		_param.description					= "This is a test for creating O&M";
		_param.timePeriodBeginPosition		= "periodBeginPos";
		_param.timePeriodEndPosition		= "periodEndPos";
		_param.timePosition					= "timePos";
		_param.omObservedProperty			= {};
		_param.omObservedProperty.xLinkHref = "urn:example:RelativeHumidity";
		
		_param.omFeatureOfInterestXLinkHref	= "http://my.example.org/wfs%26request=getFeature%26;featureid=789002";
		_param.omFeatureOfInterestXLinkRole	= "urn:ogc:def:featureType:NWS:station";
		
		_param.omResultXLinkHref			= "http://my.example.org/results%3f798002%26property=RH";
		_param.omResultXLinkRole			= "application/xmpp";
		
		iotOM.initObservation(_param, function(err, result) {
			var _outRecords = [];
			var _result = result.rows; 
			for (var i=0;i<_result.length;i++) {
				var outRecord = {};
				outRecord.geometry = JSON.parse(_result[i].geom4326);
				//outRecord.geometry.coordinates[0] = ""+outRecord.geometry.coordinates[0];
				//outRecord.geometry.coordinates[1] = ""+outRecord.geometry.coordinates[1];
				outRecord.type = 'Feature';

				outRecord.properties = {};
				outRecord.properties.gid 					= _result[i].gid;
				outRecord.properties.airbox 				= _result[i].airbox; 
								
				outRecord.properties.retrieveddate			= _result[i].retrieveddate;

				outRecord.properties.gpslat 	= parseFloat(_result[i].gpslatfloat);
				outRecord.properties.gpslng 	= parseFloat(_result[i].gpslngfloat);
				outRecord.properties.pm1 		= parseFloat(_result[i].pm1float);
				outRecord.properties.pm25 		= parseFloat(_result[i].pm25float);
				outRecord.properties.pm10 		= parseFloat(_result[i].pm10float);
				outRecord.properties.ufp 		= parseFloat(_result[i].ufpfloat);
				outRecord.properties.ozon 		= parseFloat(_result[i].ozonfloat);
				outRecord.properties.hum 		= parseFloat(_result[i].humfloat);
				outRecord.properties.celc 		= parseFloat(_result[i].celcfloat);
				outRecord.properties.no2 		= parseFloat(_result[i].no2float);

				_outRecords.push(outRecord);
			}
			var outRecords = JSON.stringify(_outRecords);
			res.contentType('application/json');
 			res.send(outRecords);
		});
		return;
	}
  
  
  	res.contentType('text/plain');
  	res.send('OM Wrong get function: ' + req.params.getFunction);
});



app.listen(apriConfig.getSystemListenPort() );
console.log('listening to http://proxyintern: ' + apriConfig.getSystemListenPort() );
 

