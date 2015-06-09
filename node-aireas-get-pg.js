
/*jslint devel: true,  undef: true, newcap: true, white: true, maxerr: 50 */ 
/*global */
/**
 * The module is for retrieving AiREAS measure data from the Postgres database. 
 * @module node-get-aireas-pg
 */
 
var pg = require('pg');

var sqlConnString;

function executeSql (query, callback) {
	console.log('sql start: ');
	var client = new pg.Client(sqlConnString);
	client.connect(function(err) {
  		if(err) {
    		console.error('could not connect to postgres', err);
			callback(err);
			return;
  		}
  		client.query(query, function(err, result) {
    		if(err) {
      			console.error('error running query', err);
				callback(err, result);
				return;
    		}
    		//console.log('sql result: ' + result);
			callback(err, result);
    		client.end();
  		});
	});
};

 

module.exports = {

	init: function (options) {

		sqlConnString = options.configParameter.databaseType + '://' + 
			options.configParameter.databaseAccount + ':' + 
			options.configParameter.databasePassword + '@' + 
			options.configParameter.databaseServer + '/' +
			options.systemCode + '_' + options.configParameter.databaseName;
	},

    portletCache: [],


    getBuurtRookRisicoInfo: function (param, callback) {
		var _airbox = "";

		// zonder gemiddelde meetwaarde
		var querySelect = " select bu.bu_code, bu.gm_code, bu.bu_naam, \
  ST_AsGeoJSON(bu.geom4326) geom, count(srm.gid) aantal_markers ";

		var queryFrom = 
				" from cbsbuurt2012 bu LEFT OUTER JOIN smoke_risc_marker srm on ST_Contains(bu.geom4326, srm.geom) and srm.marker_date >= current_timestamp - INTERVAL '04:00:00' ";
		var queryWhere = //" WHERE 1400 > ST_Distance( GEOGRAPHY(wk.geom4326), GEOGRAPHY(ST_GeomFromText('POINT( 5.4526519775390625 51.448658120386)', 4326) ) ) "; 
				" where bu.gm_naam = 'Eindhoven' "; 
		var queryGroupBy = " group by bu.bu_code, bu.gm_code, bu.geom4326, bu.bu_naam ; ";
		//var queryOrderBy = " order by bu_naam ; ";

		console.log('Postgres sql start execute');

		var query = querySelect + queryFrom + queryWhere + queryGroupBy;
			//_airbox +
			//queryOrderBy;
		console.log('Query: ' + query);
		executeSql(query, callback);

        return;
	},

    setBuurtRookRisicoMarker: function (param, callback) {

		// zonder gemiddelde meetwaarde
		var query = " INSERT INTO smoke_risc_marker (marker_date, geom, creation_date) VALUES (" + 
			//param.markerDate +
			" current_timestamp " + 
			", ST_GeomFromText( 'POINT("+ param.lng + " " + param.lat + " )', 4326), current_timestamp );"; 

		console.log('Postgres sql start execute');
		console.log('Query: ' + query);
		executeSql(query, callback);

        return;
	},



    getBuurtInfo: function (param, callback) {
		var _airbox = "";

		// zonder gemiddelde meetwaarde
		var querySelect = " select bu.bu_naam, bu.wk_code, bu.gm_naam, bu.p_00_14_jr, bu.p_15_24_jr, bu.p_25_44_jr, bu.p_45_64_jr, bu.p_65_eo_jr, \
  ST_AsGeoJSON(geom4326) geom ";



/*		
" select '{ properties: { ' || \
  '  bu_naam: ' || bu.bu_naam || \
  ', wk_naam: ' || bu.wk_code || \
  ', gm_naam: ' || bu.gm_naam ||\
  ', p_00_14_jr: ' || bu.p_00_14_jr ||\
  ', p_15_24_jr: ' || bu.p_15_24_jr ||\
  ', p_25_44_jr: ' || bu.p_25_44_jr ||\
  ', p_45_64_jr: ' || bu.p_45_64_jr ||\
  ', p_65_eo_jr: ' || bu.p_65_eo_jr ||\
  '} ,geodata:' || \
  ST_AsGeoJSON(geom) ||\
'}' record ";
*/
		var queryFrom = 
				" from cbsbuurt2012 bu ";
		var queryWhere = 
				"where bu.gm_naam = 'Eindhoven' ";
		var queryOrderBy = " order by bu_naam ; ";

		console.log('Postgres sql start execute');
		if (param && param.airbox && param.airbox != '*') {
			_airbox = " and airbox = '" + param.airbox + "' ";			
		}
		var query = querySelect + queryFrom + queryWhere + _airbox + queryOrderBy;
		console.log('Query: ' + query);
		executeSql(query, callback);

        return;
	},

	getGemInfo: function (param, callback) {

		var querySelect = " select gm.gm_naam, gm.gm_code,  \
  			ST_AsGeoJSON(ST_Envelope(ST_Transform(gm.geom,4326))) AS envelope_geom, \
			ST_AsGeoJSON(ST_Transform(gm.geom,4326)) AS geom ";

		var queryFrom 		=	" from cbsgem2012 gm ";
//		var queryWhere 		= " where gm.gm_naam = 'Eindhoven' ";
		var queryWhere 		= " where gm.gm_naam = '" + param.gm_naam + "' ";
		
		var queryOrderBy 	= " order by gm_naam ; ";

		console.log('Postgres sql start execute');

		var query = querySelect + queryFrom + queryWhere + queryOrderBy;
		console.log('Query: ' + query);
		executeSql(query, callback);

        return;

	},

	getCbsGemeenten: function (param, callback) {

		var querySelect 	= " select gm.gm_naam, gm.gm_code ";
		var queryFrom 		= " from cbsgem2012 gm ";
		var queryWhere 		= " where gm.gm_naam is not null ";
		var queryOrderBy 	= " order by gm_naam ; ";

		console.log('Postgres sql start execute');

		var query = querySelect + queryFrom + queryWhere + queryOrderBy;
		console.log('Query: ' + query);
		executeSql(query, callback);

        return;
	},


    getGridGemAireasInfo: function (param, req_query, callback) {
		var _airbox = "";
		
		if (req_query.avgType == undefined) {
			req_query.avgType = 'SPMI';
		}

		var querySelect = " select grid.gm_code, grid.gm_naam, to_char(cellunion.retrieveddate AT TIME ZONE 'UTC', 'YYYY-MM-DDT')||to_char(cellunion.retrieveddate AT TIME ZONE 'UTC','HH24:MI:SS.MSZ') AS retrieveddate, \
  			ST_AsGeoJSON(ST_Transform(cellunion.union_geom, 4326)) geom, \
			ST_AsGeoJSON(ST_Transform(ST_Centroid(cellunion.union_geom), 4326)) centroid, \
			cell.cell_x, cell.cell_y, \
			cellunion.avg_type, cellunion.avg_avg ";
//			cellunion.avg_pm1_hr, cellunion.avg_pm25_hr, cellunion.avg_pm10_hr, cellunion.avg_pm_all_hr ";
			

		retrieveddateMaxConstraintStr = "";  // 2014-11-09T09:30:01.376Z

		if ( req_query.retrieveddatemax) {  //todo
			console.log('req_query: ' + req_query );
			retrieveddateMaxConstraintStr = " and cellunion2.retrieveddate AT TIME ZONE 'UTC' <= timestamp '" + req_query.retrieveddatemax + "' ";  //'2014-11-09T06:00:01.376Z' ";

		}

		var queryFrom = " from grid_gem grid, grid_gem_cell cell, grid_gem_cell_union cellunion  ";
		var queryWhere = " where grid.gm_naam = 'Eindhoven' and grid.grid_code = 'EHV20141104:1' and grid.grid_code = cell.grid_code and cell.gid = cellunion.grid_gem_cell_gid ";
			queryWhere += " and cellunion.avg_type = '" + req_query.avgType + "' ";
			queryWhere += " and cellunion.retrieveddate = (select max(retrieveddate) from grid_gem_cell_union cellunion2 where 1=1 " + retrieveddateMaxConstraintStr + ")";

		//	queryWhere += " and ST_Intersects(grid.cell_geom, a1.geom) ";
		//	queryWhere += " and a1.retrieveddate >= current_timestamp - interval '1 hour' ";
		var queryGroupBy = ""; // group by grid.gm_code, grid.gm_naam, grid.cell_geom"; //, grid.centroid_geom ";
		var queryOrderBy = ""; //" order by bu_naam ; ";

		console.log('Postgres sql start execute');
		var query = querySelect + queryFrom + queryWhere + queryGroupBy + queryOrderBy;
		console.log('Query: ' + query);
		executeSql(query, callback);

        return;
	},

    getBuurtAireasInfo: function (param, callback) {
		var _airbox = "";

		// plus met gemiddelde meetwaarde per buurt van afgelopen uur
		var querySelect = " select bu.gm_code, bu.bu_code, bu.bu_naam, max(bu.wk_code) wk_code, max(bu.gm_naam) gm_naam, \
			max(a1.retrieveddate) retrieveddatemax, min(a1.retrieveddate) retrieveddatemin, \
			max(bu.p_00_14_jr) p_00_14_jr, max(bu.p_15_24_jr) p_15_24_jr, max(bu.p_25_44_jr) p_25_44_jr, max(bu.p_45_64_jr) p_45_64_jr, max(bu.p_65_eo_jr) p_65_eo_jr, \
  			ST_AsGeoJSON(ST_Transform(bu.geom, 4326)) geom, \
			avg(a1.pm1float) pm1_avg_hr, avg(a1.pm25float) pm25_avg_hr, avg(a1.pm10float) pm10_avg_hr, \
			ST_AsGeoJSON(ST_Transform(ST_Centroid(bu.geom), 4326)) centroid ";

		var queryFrom = " from cbsbuurt2012 bu, public.aireas a1 ";
		var queryWhere = " where bu.gm_naam = 'Eindhoven' ";
			queryWhere += " and ST_Intersects(bu.geom, a1.geom28992) ";
			queryWhere += " and a1.retrieveddate >= current_timestamp - interval '1 hour' ";
		var queryGroupBy = " group by bu.gm_code, bu.bu_code, bu_naam, bu.geom  ";
		var queryOrderBy = " order by bu_naam ; ";

		console.log('Postgres sql start execute');
		if (param && param.airbox && param.airbox != '*') {
			_airbox = " and airbox = '" + param.airbox + "' ";			
		}
		var query = querySelect + queryFrom + queryWhere + queryGroupBy + queryOrderBy;
		console.log('Query: ' + query);
		executeSql(query, callback);

        return;
	},


    getMeasures: function (param, callback) {
		var _airbox = "";
		var _period = "";
		var _attributes = " gid, airbox.airbox,  retrieveddate, gpslatfloat, gpslngfloat, pm1float, pm25float, pm10float, ufpfloat, ozonfloat, humfloat, celcfloat, no2float, geom ";
		var _from = " (select distinct(airbox) airbox from aireas) airbox, public.aireas a1 "
		
		if (param && param.airbox && param.airbox != '*') {
			_airbox = " and airbox.airbox = '" + param.airbox + "' ";			
		}
		if (param && param.getFunction == 'getLastWeekMeasures') {
			_period = " and retrieveddate >= current_timestamp - interval '7 days' ";		//and a1.retrieveddate >= current_timestamp - interval '1 hour'
		}
		if (param && param.getFunction == 'getActualMeasures') {
			_attributes = _attributes + " , ST_AsGeoJSON(ST_Transform(a1.geom28992, 4326)) geom4326 "; 
			_period = " and a1.retrieveddate = (select max(retrieveddate) from public.aireas a2 where a2.airbox = airbox.airbox)";		//and a1.retrieveddate >= current_timestamp - interval '1 hour'
		}
		var query = 'select ' + _attributes + ' from ' + _from + ' where 1=1 and a1.airbox = airbox.airbox ' + _airbox + _period + ' order by airbox.airbox, retrieveddate ;';
		console.log('Postgres sql start execute: ' + query);
		executeSql(query, callback);

        return;

    },

    getMeasureStatistics: function (param, callback) {
		var _attribute, _and;
		if (param.getFunction == 'getMeasureStatisticsStddev' ) {
			_attribute = " stddev_pm_all ";
			_and = ' AND stddev_pm_all > 0 ';
		} else {
			_attribute = " avg_pm_all ";
			_and = ' AND avg_pm_all > 0 ';
		}
		var _from = " grid_gem_cell_statistics statistics, grid_gem_cell cell "
		
		var query = 'select ' + _attribute + ' pm_all_statistic, ST_AsGeoJSON(ST_Union(cell.cell_geom)) geom from ' + _from + ' where statistics.grid_gem_cell_gid = cell.gid ' +
		 _and + ' group by ' + _attribute + ' ;';
		console.log('Postgres sql start execute: ' + query);
		executeSql(query, callback);

        return;

    }

};

    
