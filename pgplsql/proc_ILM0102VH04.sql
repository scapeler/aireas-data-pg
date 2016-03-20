/*
 USE/TEST: 
 
 SELECT dblink_disconnect('sosdb');
 select proc_ILM0102VH04(2015, 1, cast('http://wiki.aireas.com/index.php/airbox_pm1'  as character varying), true);

 select proc_ILM0102VH04(2015, 1, cast('http://wiki.aireas.com/index.php/airbox_pm1'  as character varying), true );
 select proc_ILM0102VH04(2015, 1, cast('http://wiki.aireas.com/index.php/airbox_pm25' as character varying), true );
 select proc_ILM0102VH04(2015, 1, cast('http://wiki.aireas.com/index.php/airbox_pm10' as character varying), true );
 
 	SELECT dblink_close('sosdb', 'cursor_observableproperty');
	SELECT dblink_disconnect('sosdb');
 
 select * from ILM0102VH01_OUT_flag
 where flag_code = 'LowerThanAvg'
 OR flag_code = 'HigherThanAvg'
  limit 10;
  
 select o.feature_of_interest, o.observed_property, of.flag_code, count(*) 
from ILM0102VH01_OUT o
 , ILM0102VH01_OUT_flag of
where o.gid = of.ILM0102VH01_OUT_gid
AND (of.flag_code = 'LowerThanAvg'
     OR of.flag_code = 'HigherThanAvg')
group by o.feature_of_interest, o.observed_property, of.flag_code
order by o.feature_of_interest, o.observed_property, of.flag_code;
 
 
 --delete from ILM0102VH01_OUT_FLAG where flag_code = 'LowerThanAvg';
 --delete from ILM0102VH01_OUT_FLAG where flag_code = 'HigherThanAvg';
 
 select * 
 from ILM0102VH01_OUT o
 , ILM0102VH01_OUT_FLAG of
 WHERE o.gid = of.ILM0102VH01_OUT_gid
 AND of.flag_code = 'JumpUp'
 limit 1000;
 
 select extract(year from (phenomenon_tick_time - interval '1 hour')) observation_year, o.observed_property, of.flag_code flag, count(*)
 from ILM0102VH01_OUT o
 , ILM0102VH01_OUT_FLAG of
 WHERE o.gid = of.ILM0102VH01_OUT_gid
 GROUP BY observation_year, o.observed_property, of.flag_code
 ORDER BY observation_year, o.observed_property, of.flag_code
 ;

 
 select count(*) from ILM0102VH01_OUT;
 
 DROP FUNCTION proc_ILM0102VH04(hist_year INTEGER, hist_month INTEGER, observed_property varchar(250), init_tables BOOLEAN)
*/

CREATE OR REPLACE FUNCTION public.proc_ILM0102VH04(hist_year INTEGER, hist_month INTEGER, observed_property varchar(250), init_tables BOOLEAN)
  RETURNS  void AS
$BODY$
DECLARE

	/* parameters */
	_parm_hist_year 		INTEGER;
	_parm_hist_month 		INTEGER;
	_parm_observed_property varchar(250);
	_parm_init_tables 		BOOLEAN;
	
	    
	maincursor	cursor FOR SELECT * FROM ILM0102VH01_OUT o 
		WHERE 	extract(year from (phenomenon_tick_time - interval '1 hour')) 	= _parm_hist_year 
		AND		extract(month from (phenomenon_tick_time - interval '1 hour')) 	= _parm_hist_month
		--AND		o.foi_short = '11'
		--AND 	extract(month from (o.phenomenon_tick_time - interval '1 hour')) = 1
		AND 	o.observed_property = _parm_observed_property
		AND		o.quality > 50
		-- AND 	o.result_value > 40
		ORDER BY  o.feature_of_interest, o.observed_property, o.phenomenon_tick_time  
		--LIMIT 20
		;
		

  /*  ILM0102VH01_OUT */
  _feature_of_interest varchar(250);
  _foi_short varchar(50);
  _lat double precision;
  _lng double precision;
  _phenomenon_tick_time timestamp with time zone;
  _phenomenon_time timestamp with time zone;
  _observed_property varchar(250);
  _result_value double precision;
  _quality integer;
  _creation_date timestamp with time zone;
  
	_prev_feature_of_interest varchar;
	_prev_offeringidentifier varchar;
	_prev_procedureidentifier varchar;
  
	_prev_sos_featureofinterestid	bigint;
	_prev_sos_observablepropertyid	bigint;
	_prev_sos_procedureid			bigint;
  
  /* ILM0102VH01_OUT_FLAG */
  _flag_code varchar(25);
  _value_old 		double precision;
  _value_new 		double precision; 

	/* sos observableproperty */
	_sos_observablepropertyid 	bigint;
	_sos_featureofinterestid	bigint;
	_sos_offeringidentifier		varchar;
	_sos_offeringid				bigint;
	_sos_procedureidentifier	varchar;
	_sos_procedureid			bigint;
	_sos_seriesid				bigint;
	
  
  ILM0102VH01_OUT_rec 	record;
  
  new_unique_id bigint;
  batch_time_stamp 	timestamp with time zone;
  month integer;
  first_value BOOLEAN;
--  prev_value double precision;
--  prev_feature_of_interest varchar(250); 
  value_diff double precision;
  _foi_grid_cell integer;
  _avg_result_value double precision;
  _diff_result_value double precision;
  
	_dblink_query varchar;
	_dblink_result text;
	_loop_index bigint;
	_retrieve_series boolean;
	_observationidentifier varchar;
  
BEGIN
	_parm_hist_year 			:= $1;
	_parm_hist_month			:= $2;
	_parm_observed_property 	:= $3;
	_parm_init_tables			:= $4;
	
	batch_time_stamp	:= current_timestamp;
	first_value			:= true;
--	prev_value			:= 0;
	value_diff			:= 0;
	
	_sos_featureofinterestid 		:=0;
	_sos_observablepropertyid		:=0;
	_sos_procedureid				:=0;
	_prev_feature_of_interest		:=' ';
	_prev_procedureidentifier		:=' ';
	_prev_sos_featureofinterestid 	:=1;
	_prev_sos_observablepropertyid	:=1;
	_prev_sos_procedureid			:=1;
	
	SELECT extract(epoch from now())*100000 into new_unique_id;	
	
	_sos_offeringidentifier		:= 'http://wiki.aireas.com/index.php/Airbox_EHV_offering_initial';
	_sos_procedureidentifier 	:= 'http://wiki.aireas.com/index.php/Airbox_standard_procedure';
	


	IF (init_tables = true) THEN 
		EXECUTE 'DROP TABLE IF EXISTS ILM0102VH04_OUT';
	END IF;







--		_dblink_query := 'INSERT INTO observation ' || 
--			' (observationid, seriesid, phenomenontimestart, phenomenontimeend, resulttime, validtimestart, validtimeend, deleted, samplinggeometry, identifier, codespace, name, codespacename, description, unitid) ' ||
--			' VALUES (nextval(''observationid_seq''::regclass),'|| _sos_seriesid||','''|| ILM0102VH01_OUT_rec.phenomenon_time ||''' AT TIME ZONE ''UTC'' ,'''|| ILM0102VH01_OUT_rec.phenomenon_time||''' AT TIME ZONE ''UTC'' ,'''|| ILM0102VH01_OUT_rec.phenomenon_tick_time||''' AT TIME ZONE ''UTC'' , null, null, ''F'', null, ''Airbox_standard_procedure_obs_' || new_unique_id||'_'||_loop_index || ''', 34, null, 34, ''testobservation'', 13); ' ;


	
	IF (_parm_init_tables = true) THEN
		EXECUTE 'CREATE TABLE ILM0102VH04_OUT (
--			gid integer NOT NULL DEFAULT nextval(''ILM0102DH01_OUT_GID_SEQ''::regclass),
--			observationid 		bigint,
			seriesid	 		bigint,
			phenomenontime 		timestamp with time zone,
			phenomenonticktime 	timestamp with time zone,
			identifier			varchar(250),
			description			varchar(250),
			unitid				bigint,
			quality 			integer,
			result_value		double precision
--			creation_date timestamp with time zone
--			CONSTRAINT ILM0102VH01_OUT_pkey PRIMARY KEY (gid)		
		)';	
	END IF;

	
	
	/* connect to SOS database */
	SELECT dblink_connect('sosdb', 'hostaddr=149.210.234.239 port=5432 dbname=openiod_sos user=postgres password=OpenIoD@2015 ') into _dblink_result;
	
	/* get observablepropertyid from SOS */
	_dblink_query := 'select observablepropertyid FROM public.observableproperty WHERE identifier = ''' || _parm_observed_property || '''';
	SELECT dblink_open('sosdb', 'cursor_observableproperty', _dblink_query ) 
		into _dblink_result; --_sos_observablepropertyid;
	SELECT * --observablepropertyid 
		FROM dblink_fetch('sosdb', 'cursor_observableproperty', 1 ) 
		AS (observablepropertyid bigint) into _sos_observablepropertyid;
	SELECT dblink_close('sosdb', 'cursor_observableproperty') into _dblink_result;


/* 
	observation record:

	observationid		public.observationid_seq
	seriesid			..
	, phenomenontimestart, phenomenontimeend, 
       resulttime, validtimestart, validtimeend, deleted, samplinggeometry, 
       identifier, codespace, name, codespacename, description, unitid


	series record:
	
	seriesid			..
		, featureofinterestid, observablepropertyid, procedureid, 
       deleted, published, firsttimestamp, lasttimestamp, firstnumericvalue, 
       lastnumericvalue, unitid
*/

	
	_loop_index := 0;

	FOR ILM0102VH01_OUT_rec IN maincursor
	LOOP
	
		_loop_index := 	_loop_index + 1;

		/* get featureofinterestid from SOS */
		RAISE NOTICE 'feature_of_interest  %', ILM0102VH01_OUT_rec.feature_of_interest ;
		IF ILM0102VH01_OUT_rec.feature_of_interest <> _prev_feature_of_interest THEN 
			_dblink_query := 'select featureofinterestid FROM public.featureofinterest WHERE identifier = ''' || ILM0102VH01_OUT_rec.feature_of_interest || ''';';
			SELECT dblink_open('sosdb', 'cursor_featureofinterest', _dblink_query ) 
				into _dblink_result; 
			SELECT *  
				FROM dblink_fetch('sosdb', 'cursor_featureofinterest', 1 ) 
				AS (featureofinterestid bigint) into _sos_featureofinterestid;
			SELECT dblink_close('sosdb', 'cursor_featureofinterest') into _dblink_result;	
			_prev_feature_of_interest = ILM0102VH01_OUT_rec.feature_of_interest;
		END IF;


		/* get offeringid from SOS */
		IF _sos_offeringidentifier <> _prev_offeringidentifier THEN 
			_dblink_query := 'select offeringid FROM public.offering WHERE identifier = ''' || _sos_offeringidentifier || '''';
			SELECT dblink_open('sosdb', 'cursor_offering', _dblink_query ) 
				into _dblink_result; 
			SELECT *  
				FROM dblink_fetch('sosdb', 'cursor_offering', 1 ) 
				AS (offeringid bigint) into _sos_offeringid;
			SELECT dblink_close('sosdb', 'cursor_offering') into _dblink_result;	
			_prev_offeringidentifier = _sos_offeringidentifier;
		END IF;


		/* get procedureid from SOS */
		IF _sos_procedureidentifier <> _prev_procedureidentifier THEN 
			_dblink_query := 'select procedureid FROM public.procedure WHERE identifier = ''' || _sos_procedureidentifier || '''';
			SELECT dblink_open('sosdb', 'cursor_procedure', _dblink_query ) 
				into _dblink_result; 
			SELECT *  
				FROM dblink_fetch('sosdb', 'cursor_procedure', 1 ) 
				AS (procedureid bigint) into _sos_procedureid;
			SELECT dblink_close('sosdb', 'cursor_procedure') into _dblink_result;
			_prev_procedureidentifier = _sos_procedureidentifier;		
		END IF;
		
		
		
		
		RAISE NOTICE 'Loop index %', _loop_index;

		/* get seriesid from SOS */
		_retrieve_series = false;
		IF _sos_featureofinterestid <> _prev_sos_featureofinterestid THEN
			_retrieve_series = true;
		END IF;
		IF _sos_observablepropertyid <> _prev_sos_observablepropertyid THEN
			_retrieve_series = true;
		END IF;
		IF _sos_procedureid <> _prev_sos_procedureid  THEN
			_retrieve_series = true;
		END IF;
		
		RAISE NOTICE '_retrieve_series %', _retrieve_series;
		
		IF _retrieve_series = true THEN 
			RAISE NOTICE 'get series';
			_dblink_query := 'select seriesid FROM public.series ' || ' WHERE featureofinterestid 	= ''' || _sos_featureofinterestid || '''' || ' AND 	observablepropertyid 	= ''' || _sos_observablepropertyid || '''' ||' AND 	procedureid = ''' || _sos_procedureid ||''';';
			SELECT dblink_open('sosdb', 'cursor_series', _dblink_query ) into _dblink_result; 
			IF  _dblink_result = 'OK' THEN
				SELECT *  FROM dblink_fetch('sosdb', 'cursor_series', 1 ) AS (seriesid bigint) into _sos_seriesid;
--				SELECT dblink_close('sosdb', 'cursor_series') into _dblink_result;	
			END IF;	
			_prev_sos_featureofinterestid	= _sos_featureofinterestid;
			_prev_sos_observablepropertyid	= _sos_observablepropertyid;
			_prev_sos_procedureid			= _sos_procedureid;
		END IF;

		RAISE NOTICE '_sos_featureofinterestid %', _sos_featureofinterestid;
		RAISE NOTICE '_sos_observablepropertyid %', _sos_observablepropertyid;
		RAISE NOTICE '_sos_procedureid %', _sos_procedureid;
		RAISE NOTICE '_sos_seriesid %', _sos_seriesid;
					
--		RAISE NOTICE 'prepare insert';	


--	CONTINUE;
		
/*

 SELECT dblink_disconnect('sosdb');
 SELECT proc_ILM0102VH04(2015, 1, cast('http://wiki.aireas.com/index.php/airbox_pm1'  AS character varying), true);
*/		
		
		_observationidentifier := 'Airbox_standard_procedure_obs_' || new_unique_id || '_' || _loop_index;

		EXECUTE 'INSERT INTO ILM0102VH04_OUT (seriesid, phenomenontime, phenomenonticktime, identifier, description, unitid, quality, result_value) VALUES ($1, $2, $3, $4, $5, $6, $7, $8 );' USING _sos_seriesid, ILM0102VH01_OUT_rec.phenomenon_time, ILM0102VH01_OUT_rec.phenomenon_tick_time, _observationidentifier, 'testobservation', 13, ILM0102VH01_OUT_rec.quality, ILM0102VH01_OUT_rec.result_value;

			
		/* insert observation into SOS */
		
/* old version direct sos insert 
		_dblink_query := 'INSERT INTO observation ' || 
			' (observationid, seriesid, phenomenontimestart, phenomenontimeend, resulttime, validtimestart, validtimeend, deleted, samplinggeometry, identifier, codespace, name, codespacename, description, unitid) ' ||
			' VALUES (nextval(''observationid_seq''::regclass),'|| _sos_seriesid||','''|| ILM0102VH01_OUT_rec.phenomenon_time ||''' AT TIME ZONE ''UTC'' ,'''|| ILM0102VH01_OUT_rec.phenomenon_time||''' AT TIME ZONE ''UTC'' ,'''|| ILM0102VH01_OUT_rec.phenomenon_tick_time||''' AT TIME ZONE ''UTC'' , null, null, ''F'', null, ''Airbox_standard_procedure_obs_' || new_unique_id||'_'||_loop_index || ''', 34, null, 34, ''testobservation'', 13); ' ;
--		SELECT dblink_send_query('sosdb', _dblink_query ) 
--			into _dblink_result; 
--		SELECT * FROM dblink_get_result('sosdb') AS t1(f1 text) into _dblink_result;

		SELECT dblink_exec('sosdb', _dblink_query ) into _dblink_result; 
		
--		RAISE NOTICE 'Loop index %', _loop_index;	
		
--		RAISE NOTICE USING MESSAGE = ' Time: ' || ILM0102VH01_OUT_rec.phenomenon_time;
			
-- RAISE unique_violation USING MESSAGE = 'observation: '  || ' ' || _dblink_result; --for debug purpose
*/
		

	END LOOP;

	SELECT dblink_exec('sosdb','COMMIT') into _dblink_result;

	--SELECT dblink_close('sosdb', 'cursor_observableproperty') into _dblink_result;
	SELECT dblink_disconnect('sosdb') into _dblink_result;
	

		
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
   ;
ALTER FUNCTION public.proc_ILM0102VH04(hist_year INTEGER, hist_month INTEGER, observed_property varchar(250), init_tables BOOLEAN)
  OWNER TO postgres;   
