/*
 USE/TEST: 
 
 insert into featureofinteresttype (featureofinteresttypeid, featureofinteresttype) values(1, 'http://www.opengis.net/def/samplingFeatureType/OGC-OM/2.0/SF_SamplingPoint');
 INSERT INTO public.unit(unitid, unit) VALUES (nextval('unitid_seq'::regclass), 'testunit');
 
 
	select proc_ILM0102PH01(2015, 1, false);
 
 	SELECT dblink_disconnect('sosdb');
	
	delete from numericvalue;
	delete from observation;
	delete from series;
	
	
Last action to add min and max values to series.
update series ser
set firsttimestamp= obs.phenomenontimestart, lasttimestamp= obs.phenomenontimeend,
 firstnumericvalue = obs.nvminvalue, lastnumericvalue = obs.nvmaxvalue
from
 (select o.seriesid, min(o.phenomenontimestart) phenomenontimestart, max(o.phenomenontimeend) phenomenontimeend, 
	min(nv.value) nvminvalue, max(nv.value) nvmaxvalue
  from observation o,
  numericvalue nv
  where nv.observationid = o.observationid
  group by seriesid) AS obs
where ser.seriesid = obs.seriesid  
--and ser.seriesid = 777
;	

--update series ser set unitid=14;

--select * from series;
--select * from unit;

 
 
 SELECT 'update ilm0102vh04_out_identifier set identifier='''|| identifier || ''' where gid = ' || gid || ';'
  FROM public.ilm0102vh04_out_identifier
  order by identifier;
  
 
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
 
 DROP FUNCTION proc_ILM0102PH01(hist_year INTEGER, hist_month INTEGER, init_tables BOOLEAN)
*/




CREATE OR REPLACE FUNCTION public.proc_ILM0102PH01(hist_year INTEGER, hist_month INTEGER, init_tables BOOLEAN)
  RETURNS  void AS
$BODY$
DECLARE

	/* parameters */
	_parm_hist_year 		INTEGER;
	_parm_hist_month 		INTEGER;
	_parm_init_tables 		BOOLEAN;
	
	sos_config		record; --ILM0102PH01_TMP_CONFIG_SOS;
	

	identifierCursor	cursor FOR SELECT * FROM ILM0102VH04_OUT_IDENTIFIER idf
		ORDER BY  idf.identifier_type, idf.identifier
		;
	    
	maincursor	cursor FOR SELECT * FROM ILM0102VH04_OUT o
		WHERE	published = false 
		AND 	extract(year from (phenomenon_tick_time - interval '1 hour')) 	= _parm_hist_year 
		AND		extract(month from (phenomenon_tick_time - interval '1 hour')) 	= _parm_hist_month
		--AND		o.foi_short = '11'
		--AND 	extract(month from (o.phenomenon_tick_time - interval '1 hour')) = 1
		--AND 	o.observed_property = _parm_observed_property
		--AND		o.quality > 50
		-- AND 	o.result_value > 40
--		ORDER BY  o.offeringid, o.phenomenon_tick_time, featureofinterestid, o.observablepropertyid 
		ORDER BY  o.featureofinterestid, o.observablepropertyid, o.procedureid, o.phenomenon_tick_time 
		--LIMIT 10
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
  
	_prev_featureofinterestid 		bigint;
	_prev_observablepropertyid		bigint;
	_prev_offeringid 				bigint;
	_prev_procedureid 				bigint;
  
	_prev_sos_featureofinterestid	bigint;
	_prev_sos_observablepropertyid	bigint;
	_prev_sos_procedureid			bigint;
	_prev_sos_phenomenon_tick_time	timestamp with time zone;
  
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
	_sos_phenomenon_tick_time	timestamp with time zone;
	_sos_seriesid				bigint;
	
  
  ILM0102VH01_OUT_rec 	record;
  
  new_unique_id bigint;
  _newObservationid bigint;
  
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
	_dblink_query_insert varchar;
	_dblink_result text;
	_loop_index bigint;
	_retrieve_series boolean;
	_observationidentifier varchar;
	
	_VH04_foi_identifierid			bigint;
	_VH04_foi_identifier			varchar;
	_VH04_offering_identifierid		bigint;
	_VH04_offering_identifier		varchar;
	_VH04_procedure_identifierid	bigint;
	_VH04_procedure_identifier		varchar;
	_VH04_obsprop_identifierid		bigint;
	_VH04_obsprop_identifier		varchar;
	
  
BEGIN
	_parm_hist_year 			:= $1;
	_parm_hist_month			:= $2;
	_parm_init_tables			:= $3;
	
	/* get SOS connect info from config file*/
	EXECUTE 'DROP TABLE IF EXISTS ILM0102PH01_TMP_CONFIG_SOS';
	EXECUTE 'CREATE TABLE ILM0102PH01_TMP_CONFIG_SOS (
		ip			varchar(50),
		db			varchar(50),
		dbuser		varchar(50),
		password	varchar(50)
	)';	
	COPY ILM0102PH01_TMP_CONFIG_SOS FROM '/opt/SCAPE604/config/sos_postgres.csv' WITH DELIMITER ',' ; -- ip;db;account;password
	SELECT * FROM ILM0102PH01_TMP_CONFIG_SOS INTO sos_config;
	EXECUTE 'DROP TABLE IF EXISTS ILM0102PH01_TMP_CONFIG_SOS';
	
	
	
	batch_time_stamp	:= current_timestamp;
	first_value			:= true;
--	prev_value			:= 0;
	value_diff			:= 0;
	
	_sos_featureofinterestid 		:=0;
	_sos_observablepropertyid		:=0;
	_sos_procedureid				:=0;
	_sos_seriesid					:=null;
	_sos_phenomenon_tick_time		:=null;
	
	_prev_featureofinterestid		:=0;
	_prev_observablepropertyid		:=0;
	_prev_offeringid				:=0;
	_prev_procedureid				:=0;
	
	
	_prev_sos_featureofinterestid 	:=1;
	_prev_sos_observablepropertyid	:=1;
	_prev_sos_procedureid			:=1;
	_prev_sos_phenomenon_tick_time	:='1900-01-01 01:00:00+01';
	
	_VH04_foi_identifierid 			:= null;
	_VH04_foi_identifier 			:= null;
	_VH04_offering_identifierid 	:= null;
	_VH04_offering_identifier 		:= null;
	_VH04_procedure_identifierid 	:= null;
	_VH04_procedure_identifier 		:= null;
	_VH04_obsprop_identifierid 		:= null;
	_VH04_obsprop_identifier 		:= null;
	
	SELECT extract(epoch from now())*100000 into new_unique_id;	
	
	_sos_offeringidentifier		:= 'http://wiki.aireas.com/index.php/airbox_EHV_offering_initial';
	_sos_procedureidentifier 	:= 'http://wiki.aireas.com/index.php/airbox_standard_procedure';
	


/*
	IF (init_tables = true) THEN 
		EXECUTE 'DROP TABLE IF EXISTS ILM0102VH04_OUT';
		EXECUTE 'DROP TABLE IF EXISTS ILM0102VH04_OUT_IDENTIFIER';
	END IF;
*/






--		_dblink_query := 'INSERT INTO observation ' || 
--			' (observationid, seriesid, phenomenontimestart, phenomenontimeend, resulttime, validtimestart, validtimeend, deleted, samplinggeometry, identifier, codespace, name, codespacename, description, unitid) ' ||
--			' VALUES (nextval(''observationid_seq''::regclass),'|| _sos_seriesid||','''|| ILM0102VH01_OUT_rec.phenomenon_time ||''' AT TIME ZONE ''UTC'' ,'''|| ILM0102VH01_OUT_rec.phenomenon_time||''' AT TIME ZONE ''UTC'' ,'''|| ILM0102VH01_OUT_rec.phenomenon_tick_time||''' AT TIME ZONE ''UTC'' , null, null, ''F'', null, ''Airbox_standard_procedure_obs_' || new_unique_id||'_'||_loop_index || ''', 34, null, 34, ''testobservation'', 14); ' ;


/*	
	IF (_parm_init_tables = true) THEN
		EXECUTE 'CREATE TABLE ILM0102VH04_OUT (
--			gid integer NOT NULL DEFAULT nextval(''ILM0102DH01_OUT_GID_SEQ''::regclass),
--			observationid 		bigint,
--			seriesid	 		bigint,
			offeringid			bigint,
			featureofinterestid	bigint,
			procedureid	 		bigint,
			observablepropertyid	bigint,
			unitid				bigint,
			phenomenon_time 	timestamp with time zone,
			phenomenon_tick_time	timestamp with time zone,
			result_value		double precision,
			identifier			varchar(250),
			description			varchar(250),
			quality 			integer,
			published 			boolean
--			creation_date timestamp with time zone
--			CONSTRAINT ILM0102VH01_OUT_pkey PRIMARY KEY (gid)		
		)';	

		EXECUTE 'CREATE TABLE ILM0102VH04_OUT_IDENTIFIER (
			gid integer NOT NULL DEFAULT nextval(''ILM0102VH01_OUT_GID_SEQ''::regclass),
			identifier			varchar(250),
			identifier_type		varchar(50),
			sos_id		 		bigint,
			CONSTRAINT ILM0102VH04_OUT_pkey PRIMARY KEY (gid)
		)';	

	END IF;

*/	
	
	/* connect to SOS database */
	SELECT dblink_connect('sosdb', 'hostaddr='||sos_config.ip||' port=5432 dbname='||sos_config.db||' user='||sos_config.dbuser||' password='||sos_config.password||' ') into _dblink_result;





	
	/* get observablepropertyid from SOS */
/*	_dblink_query := 'select observablepropertyid FROM public.observableproperty WHERE identifier = ''' || _parm_observed_property || '''';
	SELECT dblink_open('sosdb', 'cursor_observableproperty', _dblink_query ) 
		into _dblink_result; --_sos_observablepropertyid;
	SELECT * --observablepropertyid 
		FROM dblink_fetch('sosdb', 'cursor_observableproperty', 1 ) 
		AS (observablepropertyid bigint) into _sos_observablepropertyid;
	SELECT dblink_close('sosdb', 'cursor_observableproperty') into _dblink_result;
*/

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




	FOR ILM0102VH04_OUT_IDENTIFIER_rec IN identifiercursor
	LOOP
		RAISE NOTICE 'Identifier Start:  % %', ILM0102VH04_OUT_IDENTIFIER_rec.identifier, ILM0102VH04_OUT_IDENTIFIER_rec.identifier_type  ;
		
		IF (ILM0102VH04_OUT_IDENTIFIER_rec.identifier_type = 'featureofinterest' ) THEN
			_dblink_query := 'select featureofinterestid FROM public.featureofinterest WHERE identifier = ''' || ILM0102VH04_OUT_IDENTIFIER_rec.identifier || ''';';
			SELECT dblink_open('sosdb', 'cursor_featureofinterest', _dblink_query ) 
				into _dblink_result; 
			SELECT *  
				FROM dblink_fetch('sosdb', 'cursor_featureofinterest', 1 ) 
				AS (featureofinterestid bigint) into _sos_featureofinterestid;
			SELECT dblink_close('sosdb', 'cursor_featureofinterest') into _dblink_result;
			IF 	_sos_featureofinterestid is null THEN
			
				_dblink_query_insert := 'insert INTO public.featureofinterest (featureofinterestid, identifier, hibernatediscriminator,featureofinteresttypeid ) values( nextval(''FEATUREOFINTERESTID_SEQ''::regclass), ''' || ILM0102VH04_OUT_IDENTIFIER_rec.identifier|| ''', ''T'', ' || '1' || ');' ;
			--	SELECT dblink_open('sosdb', 'cursor_featureofinterest_insert', _dblink_query_insert ) 
			--		into _dblink_result; 
				SELECT dblink_exec('sosdb', _dblink_query_insert ) into _dblink_result;
				

				_dblink_query := 'select featureofinterestid FROM public.featureofinterest WHERE identifier = ''' || ILM0102VH04_OUT_IDENTIFIER_rec.identifier || ''';';
				SELECT dblink_open('sosdb', 'cursor_featureofinterest', _dblink_query ) 
					into _dblink_result; 
				SELECT *  
					FROM dblink_fetch('sosdb', 'cursor_featureofinterest', 1 ) 
					AS (featureofinterestid bigint) into _sos_featureofinterestid;
				SELECT dblink_close('sosdb', 'cursor_featureofinterest') into _dblink_result;
				
				IF 	_sos_featureofinterestid is null THEN
					RAISE unique_violation USING MESSAGE = 'Identifier featureofinterest NOT FOUND IN SOS ' || ILM0102VH04_OUT_IDENTIFIER_rec.identifier || ' '|| ILM0102VH04_OUT_IDENTIFIER_rec.identifier_type  ;
					--RAISE NOTICE 'Identifier featureofinterest NOT FOUND IN SOS % %', ILM0102VH04_OUT_IDENTIFIER_rec.identifier, ILM0102VH04_OUT_IDENTIFIER_rec.identifier_type  ;
				ELSE 
					RAISE NOTICE 'Identifier featureofinterest CREATED IN SOS % % %', ILM0102VH04_OUT_IDENTIFIER_rec.identifier, ILM0102VH04_OUT_IDENTIFIER_rec.identifier_type, _sos_featureofinterestid ;
					EXECUTE 'UPDATE ILM0102VH04_OUT_IDENTIFIER SET sos_id = $1 where identifier = $2 ;'
					USING  _sos_featureofinterestid, ILM0102VH04_OUT_IDENTIFIER_rec.identifier ;
				END IF;
			ELSE 
				RAISE NOTICE 'Identifier featureofinterest FOUND IN SOS % % %', ILM0102VH04_OUT_IDENTIFIER_rec.identifier, ILM0102VH04_OUT_IDENTIFIER_rec.identifier_type, _sos_featureofinterestid ;				
				EXECUTE 'UPDATE ILM0102VH04_OUT_IDENTIFIER SET sos_id = $1 where identifier = $2 ;'
				USING  _sos_featureofinterestid, ILM0102VH04_OUT_IDENTIFIER_rec.identifier ;
			END IF;		
		END IF;

		IF (ILM0102VH04_OUT_IDENTIFIER_rec.identifier_type = 'procedure' ) THEN
			_dblink_query := 'select procedureid FROM public.procedure WHERE identifier = ''' || ILM0102VH04_OUT_IDENTIFIER_rec.identifier || ''';';
			SELECT dblink_open('sosdb', 'cursor_procedure', _dblink_query ) 
				into _dblink_result; 
			SELECT *  
				FROM dblink_fetch('sosdb', 'cursor_procedure', 1 ) 
				AS (procedureid bigint) into _sos_procedureid;
			SELECT dblink_close('sosdb', 'cursor_procedure') into _dblink_result;
			IF 	_sos_procedureid is null THEN
				RAISE unique_violation USING MESSAGE = 'Identifier procedure NOT FOUND IN SOS ' || ILM0102VH04_OUT_IDENTIFIER_rec.identifier || ' '|| ILM0102VH04_OUT_IDENTIFIER_rec.identifier_type  ;
			ELSE 
				RAISE NOTICE 'Identifier procedure FOUND IN SOS % % %', ILM0102VH04_OUT_IDENTIFIER_rec.identifier, ILM0102VH04_OUT_IDENTIFIER_rec.identifier_type, _sos_procedureid ;
				EXECUTE 'UPDATE ILM0102VH04_OUT_IDENTIFIER SET sos_id = $1 where identifier = $2 ;'
				USING  _sos_procedureid, ILM0102VH04_OUT_IDENTIFIER_rec.identifier ;
			END IF;		
		END IF;

		IF (ILM0102VH04_OUT_IDENTIFIER_rec.identifier_type = 'obsprop' ) THEN
			_dblink_query := 'select observablepropertyid FROM public.observableproperty WHERE identifier = ''' || ILM0102VH04_OUT_IDENTIFIER_rec.identifier || ''';';
			SELECT dblink_open('sosdb', 'cursor_observableproperty', _dblink_query ) 
				into _dblink_result; 
			SELECT *  
				FROM dblink_fetch('sosdb', 'cursor_observableproperty', 1 ) 
				AS (observablepropertyid bigint) into _sos_observablepropertyid;
			SELECT dblink_close('sosdb', 'cursor_observableproperty') into _dblink_result;
			IF 	_sos_observablepropertyid is null THEN
				RAISE unique_violation USING MESSAGE = 'Identifier observableproperty NOT FOUND IN SOS ' || ILM0102VH04_OUT_IDENTIFIER_rec.identifier || ' '|| ILM0102VH04_OUT_IDENTIFIER_rec.identifier_type  ;
			ELSE 
				RAISE NOTICE 'Identifier observableproperty FOUND IN SOS % % %', ILM0102VH04_OUT_IDENTIFIER_rec.identifier, ILM0102VH04_OUT_IDENTIFIER_rec.identifier_type, _sos_observablepropertyid ;
				EXECUTE 'UPDATE ILM0102VH04_OUT_IDENTIFIER SET sos_id = $1 where identifier = $2 ;'
				USING  _sos_observablepropertyid, ILM0102VH04_OUT_IDENTIFIER_rec.identifier ;
			END IF;		
		END IF;

		IF (ILM0102VH04_OUT_IDENTIFIER_rec.identifier_type = 'offering' ) THEN
			_dblink_query := 'select offeringid FROM public.offering WHERE identifier = ''' || ILM0102VH04_OUT_IDENTIFIER_rec.identifier || ''';';
			SELECT dblink_open('sosdb', 'cursor_offering', _dblink_query ) 
				into _dblink_result; 
			SELECT *  
				FROM dblink_fetch('sosdb', 'cursor_offering', 1 ) 
				AS (offeringid bigint) into _sos_offeringid;
			SELECT dblink_close('sosdb', 'cursor_offering') into _dblink_result;
			IF 	_sos_offeringid is null THEN
				RAISE unique_violation USING MESSAGE = 'Identifier offering NOT FOUND IN SOS ' || ILM0102VH04_OUT_IDENTIFIER_rec.identifier || ' '|| ILM0102VH04_OUT_IDENTIFIER_rec.identifier_type  ;
			ELSE 
				RAISE NOTICE 'Identifier offering FOUND IN SOS % % %', ILM0102VH04_OUT_IDENTIFIER_rec.identifier, ILM0102VH04_OUT_IDENTIFIER_rec.identifier_type, _sos_offeringid ;
				--update ILM0102VH04_OUT_IDENTIFIER set sos_id = _sos_offeringid where identifier = ILM0102VH04_OUT_IDENTIFIER_rec.identifier;
				
				EXECUTE 'UPDATE ILM0102VH04_OUT_IDENTIFIER SET sos_id = $1 where identifier = $2 ;'
				USING  _sos_offeringid, ILM0102VH04_OUT_IDENTIFIER_rec.identifier ;
				
			END IF;		
		END IF;



	END LOOP;	
	
			
	--RAISE NOTICE 'New observationid from SOS %', _dblink_result;		
		
	
	_loop_index := 0;

	--RAISE unique_violation USING MESSAGE = 'END TEST';

	FOR ILM0102VH04_OUT_rec IN maincursor
	LOOP
	
		_loop_index := 	_loop_index + 1;
		


		/* get featureofinterestid from SOS */
		IF ILM0102VH04_OUT_rec.featureofinterestid <> _prev_featureofinterestid THEN 
/*
			_dblink_query := 'select featureofinterestid FROM public.featureofinterest WHERE identifier = ''' || ILM0102VH01_OUT_rec.feature_of_interest || ''';';
			SELECT dblink_open('sosdb', 'cursor_featureofinterest', _dblink_query ) 
				into _dblink_result; 
			SELECT *  
				FROM dblink_fetch('sosdb', 'cursor_featureofinterest', 1 ) 
				AS (featureofinterestid bigint) into _sos_featureofinterestid;
			SELECT dblink_close('sosdb', 'cursor_featureofinterest') into _dblink_result;	
*/

			EXECUTE 'SELECT sos_id FROM ILM0102VH04_OUT_IDENTIFIER WHERE ILM0102VH04_OUT_IDENTIFIER.gid = $1 ;'
			USING  ILM0102VH04_OUT_rec.featureofinterestid
			INTO _sos_featureofinterestid;

			RAISE NOTICE 'featureofinterest  %', ILM0102VH04_OUT_rec.featureofinterestid ;
			_prev_featureofinterestid = ILM0102VH04_OUT_rec.featureofinterestid;

		END IF;


		/* get observedid from SOS */
		IF ILM0102VH04_OUT_rec.observablepropertyid <> _prev_observablepropertyid THEN 
/*
			_dblink_query := 'select featureofinterestid FROM public.featureofinterest WHERE identifier = ''' || ILM0102VH01_OUT_rec.feature_of_interest || ''';';
			SELECT dblink_open('sosdb', 'cursor_featureofinterest', _dblink_query ) 
				into _dblink_result; 
			SELECT *  
				FROM dblink_fetch('sosdb', 'cursor_featureofinterest', 1 ) 
				AS (featureofinterestid bigint) into _sos_featureofinterestid;
			SELECT dblink_close('sosdb', 'cursor_featureofinterest') into _dblink_result;	
*/

			EXECUTE 'SELECT sos_id FROM ILM0102VH04_OUT_IDENTIFIER WHERE ILM0102VH04_OUT_IDENTIFIER.gid = $1 ;'
			USING  ILM0102VH04_OUT_rec.observablepropertyid
			INTO _sos_observablepropertyid;

			RAISE NOTICE 'observableproperty  %', ILM0102VH04_OUT_rec.observablepropertyid ;
			_prev_observablepropertyid = ILM0102VH04_OUT_rec.observablepropertyid;

		END IF;



		/* get offeringid from SOS */
		IF ILM0102VH04_OUT_rec.offeringid <> _prev_offeringid THEN 
/*
			_dblink_query := 'select offeringid FROM public.offering WHERE identifier = ''' || _sos_offeringidentifier || '''';
			SELECT dblink_open('sosdb', 'cursor_offering', _dblink_query ) 
				into _dblink_result; 
			SELECT *  
				FROM dblink_fetch('sosdb', 'cursor_offering', 1 ) 
				AS (offeringid bigint) into _sos_offeringid;
			SELECT dblink_close('sosdb', 'cursor_offering') into _dblink_result;	
*/
			EXECUTE 'SELECT sos_id FROM ILM0102VH04_OUT_IDENTIFIER WHERE ILM0102VH04_OUT_IDENTIFIER.gid = $1 ;'
			USING  ILM0102VH04_OUT_rec.offeringid
			INTO _sos_offeringid;

			RAISE NOTICE 'offering  % ', ILM0102VH04_OUT_rec.offeringid ;
			_prev_offeringid = ILM0102VH04_OUT_rec.offeringid;
		END IF;


		/* get procedureid from SOS */

		IF ILM0102VH04_OUT_rec.procedureid <> _prev_procedureid THEN 

/*
			_dblink_query := 'select procedureid FROM public.procedure WHERE identifier = ''' || _sos_procedureidentifier || '''';
			SELECT dblink_open('sosdb', 'cursor_procedure', _dblink_query ) 
				into _dblink_result; 
			SELECT *  
				FROM dblink_fetch('sosdb', 'cursor_procedure', 1 ) 
				AS (procedureid bigint) into _sos_procedureid;
			SELECT dblink_close('sosdb', 'cursor_procedure') into _dblink_result;
*/
			EXECUTE 'SELECT sos_id FROM ILM0102VH04_OUT_IDENTIFIER WHERE ILM0102VH04_OUT_IDENTIFIER.gid = $1 ;'
			USING  ILM0102VH04_OUT_rec.procedureid
			INTO _sos_procedureid;
			RAISE NOTICE 'procedure  %', ILM0102VH04_OUT_rec.procedureid ;

			_prev_procedureid = ILM0102VH04_OUT_rec.procedureid;		
		END IF;


		_sos_phenomenon_tick_time := ILM0102VH04_OUT_rec.phenomenon_tick_time;

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
--		IF _sos_phenomenon_tick_time <> _prev_sos_phenomenon_tick_time  THEN
--			_retrieve_series = true;
--		END IF;

		
--		RAISE NOTICE '_retrieve_series %', _retrieve_series;
		

--		RAISE NOTICE 'Before:';
--		RAISE NOTICE '_sos_featureofinterestid %', _sos_featureofinterestid;
--		RAISE NOTICE '_sos_observablepropertyid %', _sos_observablepropertyid;
--		RAISE NOTICE '_sos_procedureid %', _sos_procedureid;
--		RAISE NOTICE '_sos_phenomenon_tick_time %', _sos_phenomenon_tick_time;
--		RAISE NOTICE '_sos_seriesid %', _sos_seriesid;


		IF _retrieve_series = true THEN 
			--RAISE NOTICE 'get series';

			RAISE NOTICE 'serie: % % %', _sos_featureofinterestid, _sos_observablepropertyid, _sos_phenomenon_tick_time;
			RAISE NOTICE 'Loop index %', _loop_index;


			_dblink_query := 'select seriesid FROM public.series ' || ' WHERE featureofinterestid 	= ' || _sos_featureofinterestid || ' AND observablepropertyid 	= ' || _sos_observablepropertyid || ' AND 	procedureid = ' || _sos_procedureid ||';';
			SELECT dblink_open('sosdb', 'cursor_series', _dblink_query ) into _dblink_result; 
			IF  _dblink_result = 'OK' THEN
				SELECT *  FROM dblink_fetch('sosdb', 'cursor_series', 1 ) AS (seriesid bigint) into _sos_seriesid;
				SELECT dblink_close('sosdb', 'cursor_series') into _dblink_result;	
			END IF;	
			
			IF _sos_seriesid is null THEN			
			
				_dblink_query_insert := 'INSERT INTO public.series (seriesid, featureofinterestid, observablepropertyid, procedureid ) values( nextval(''SERIESID_SEQ''::regclass), ' || _sos_featureofinterestid || ', ' || _sos_observablepropertyid || ',' || _sos_procedureid  || ');' ;
				--	SELECT dblink_open('sosdb', 'cursor_featureofinterest_insert', _dblink_query_insert ) 
				--		into _dblink_result; 
				SELECT dblink_exec('sosdb', _dblink_query_insert ) into _dblink_result;

				_dblink_query := 'select seriesid FROM public.series ' || ' WHERE featureofinterestid 	= ' || _sos_featureofinterestid || ' AND observablepropertyid 	= ' || _sos_observablepropertyid || ' AND 	procedureid = ' || _sos_procedureid ||';';
				SELECT dblink_open('sosdb', 'cursor_series', _dblink_query ) into _dblink_result; 
				IF  _dblink_result = 'OK' THEN
					SELECT *  FROM dblink_fetch('sosdb', 'cursor_series', 1 ) AS (seriesid bigint) into _sos_seriesid;
					SELECT dblink_close('sosdb', 'cursor_series') into _dblink_result;	
				END IF;	

			END IF;

			_prev_sos_featureofinterestid	:= _sos_featureofinterestid;
			_prev_sos_observablepropertyid	:= _sos_observablepropertyid;
			_prev_sos_procedureid			:= _sos_procedureid;
			_prev_sos_phenomenon_tick_time	:= _sos_phenomenon_tick_time;

		END IF;

--		RAISE NOTICE 'After:';
--		RAISE NOTICE 'serie: % % %', _sos_featureofinterestid, _sos_observablepropertyid, _sos_phenomenon_tick_time;
--		RAISE NOTICE '_sos_observablepropertyid %', _sos_observablepropertyid;
--		RAISE NOTICE '_sos_procedureid %', _sos_procedureid;
--		RAISE NOTICE '_sos_phenomenon_tick_time %', _sos_phenomenon_tick_time;
--		RAISE NOTICE '_sos_seriesid %', _sos_seriesid;


					
--		RAISE NOTICE 'prepare insert';	


		
/*

 SELECT dblink_disconnect('sosdb');
 SELECT proc_ILM0102VH04(2015, 1, cast('http://wiki.aireas.com/index.php/airbox_pm1'  AS character varying), true);
*/		
		
		_observationidentifier := 'airbox_standard_procedure_obs_' || new_unique_id || '_' || _loop_index;

--		EXECUTE 'INSERT INTO ILM0102VH04_OUT (seriesid, phenomenontime, phenomenonticktime, identifier, description, unitid, quality, result_value) VALUES ($1, $2, $3, $4, $5, $6, $7, $8 );' USING _sos_seriesid, ILM0102VH01_OUT_rec.phenomenon_time, ILM0102VH01_OUT_rec.phenomenon_tick_time, _observationidentifier, 'testobservation', 13, ILM0102VH01_OUT_rec.quality, ILM0102VH01_OUT_rec.result_value;

			
		/* insert observation into SOS */
		
		/* first get an unique observationid */
		SELECT * 
			FROM dblink('sosdb', 'select nextval(''observationid_seq''::regclass) ') 
			AS t1(observationid bigint) 
			INTO _dblink_result;
			
		_newobservationid := _dblink_result;			
	
		_dblink_query := 'INSERT INTO observation ' || 
			' (observationid, seriesid, phenomenontimestart, phenomenontimeend, resulttime, validtimestart, validtimeend, deleted, samplinggeometry, identifier, codespace, name, codespacename, description, unitid) ' ||
			' VALUES ('||_newobservationid||','|| _sos_seriesid||','''|| ILM0102VH04_OUT_rec.phenomenon_time ||''' AT TIME ZONE ''UTC'' ,'''|| ILM0102VH04_OUT_rec.phenomenon_time||''' AT TIME ZONE ''UTC'' ,'''|| ILM0102VH04_OUT_rec.phenomenon_tick_time||''' AT TIME ZONE ''UTC'' , null, null, ''F'', null, ''airbox_standard_procedure_obs_' || new_unique_id||'_'||_loop_index || ''', 39, null, 39, ''testobservation'', 15); ' ;
		SELECT dblink_exec('sosdb', _dblink_query ) into _dblink_result; 

		_dblink_query := 'INSERT INTO numericvalue ' || 
			' (observationid, value) ' ||
			' VALUES ('||_newobservationid||','|| ILM0102VH04_OUT_REC.result_value||'); ' ;
		SELECT dblink_exec('sosdb', _dblink_query ) into _dblink_result; 

		_dblink_query := 'INSERT INTO observationhasoffering ' || 
			' (observationid, offeringid) ' ||
			' VALUES ('||_newobservationid||','|| _sos_offeringid||'); ' ;
		SELECT dblink_exec('sosdb', _dblink_query ) into _dblink_result; 

		
--		RAISE NOTICE 'Loop index %', _loop_index;	
		
--		RAISE NOTICE USING MESSAGE = ' Time: ' || ILM0102VH01_OUT_rec.phenomenon_time;
			
-- RAISE unique_violation USING MESSAGE = 'observation: '  || ' ' || _dblink_result; --for debug purpose

		

	END LOOP;

/*
	SELECT dblink_exec('sosdb','COMMIT') into _dblink_result;

	--SELECT dblink_close('sosdb', 'cursor_observableproperty') into _dblink_result;
	SELECT dblink_disconnect('sosdb') into _dblink_result;
*/	

		
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
   ;
ALTER FUNCTION public.proc_ILM0102PH01(hist_year INTEGER, hist_month INTEGER, init_tables BOOLEAN)
  OWNER TO postgres;   
