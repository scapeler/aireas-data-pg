/*
 USE/TEST: select proc_ILM0102VH01(2015, true);  
 
 select * from ILM0102VH01_OUT limit 100;
 
 select * 
 from ILM0102VH01_OUT o
 , ILM0102VH01_OUT_FLAG of
 WHERE o.gid = of.ILM0102VH01_OUT_gid
 AND of.flag_code <> 'LowLevel';
 
 select extract(year from (phenomenon_tick_time - interval '1 hour')) observation_year, o.observed_property, of.flag_code flag, count(*)
 from ILM0102VH01_OUT o
 , ILM0102VH01_OUT_FLAG of
 WHERE o.gid = of.ILM0102VH01_OUT_gid
 GROUP BY observation_year, o.observed_property, of.flag_code
 ORDER BY observation_year, o.observed_property, of.flag_code
 ;
 
 select count(*) from ILM0102VH01_OUT;
 
 DROP FUNCTION proc_ILM0102VH01(hist_year INTEGER, init_tables BOOLEAN)
*/
CREATE OR REPLACE FUNCTION public.proc_ILM0102VH01(hist_year INTEGER, init_tables BOOLEAN)
  RETURNS  void AS
$BODY$
DECLARE
  
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
  
  /* ILM0102VH01_OUT_FLAG */
  _flag_code varchar(25);
  _value_old double precision;
  _value_new double precision; 
  
  /* parameters */
  hist_year INTEGER;
  init_tables BOOLEAN;
  
  histecn_rec record;
  batch_time_stamp timestamp with time zone;
  new_gid integer;
  month integer;
  
  
BEGIN
	hist_year 		:= $1;
	init_tables 	:= $2;
	batch_time_stamp:= current_timestamp;
	
--RAISE unique_violation USING MESSAGE = 'retrieveddate: '  || ' ' || retrieveddate_selection; --for debug purpose
	
	
	IF (init_tables = true) THEN 
		EXECUTE 'DROP TABLE IF EXISTS ILM0102VH01_OUT';
		EXECUTE 'DROP TABLE IF EXISTS ILM0102VH01_OUT_FLAG';
	END IF;
			
	/* 
	EXECUTE 'CREATE SEQUENCE ILM0102VH01_OUT_GID_SEQ
		INCREMENT 1
		MINVALUE 1
		MAXVALUE 9223372036854775807
		START 1
		CACHE 1';
	EXECUTE 'CREATE SEQUENCE ILM0102VH01_OUT_FLAG_GID_SEQ
		INCREMENT 1
		MINVALUE 1
		MAXVALUE 9223372036854775807
		START 1
		CACHE 1';
	*/
		
	IF (init_tables = true) THEN
		EXECUTE 'CREATE TABLE ILM0102VH01_OUT (
			gid integer NOT NULL DEFAULT nextval(''ILM0102VH01_OUT_GID_SEQ''::regclass),
			feature_of_interest varchar(250),
			foi_short varchar(50),
			lat double precision,
			lng double precision,
			phenomenon_time timestamp with time zone,
			phenomenon_tick_time timestamp with time zone,
			observed_property varchar(250),
			result_value double precision,
			quality integer,
			creation_date timestamp with time zone,
			CONSTRAINT ILM0102VH01_OUT_pkey PRIMARY KEY (gid)		
		)';	
		EXECUTE 'CREATE TABLE ILM0102VH01_OUT_FLAG (
			gid integer NOT NULL DEFAULT nextval(''ILM0102VH01_OUT_FLAG_GID_SEQ''::regclass),
			ILM0102VH01_OUT_gid integer,
			flag_code varchar(25),
			value_old double precision,
			value_new double precision,
			creation_date timestamp with time zone,
			CONSTRAINT ILM0102VH01_OUT_FLAG_pkey PRIMARY KEY (gid)		
		)';
	END IF;

	FOR month IN 1..12
	LOOP

	FOR histecn_rec IN EXECUTE 'SELECT * FROM aireas_histecn ahe 
		WHERE 	extract(year from (ahe.tick_date - interval ''1 hour'')) = $1 
		AND 	extract(month from (ahe.tick_date - interval ''1 hour'')) = $2 
		ORDER BY ahe.airbox, ahe.tick_date'
		USING hist_year, month
	LOOP
		
		_feature_of_interest	:= 'http://wiki.aireas.com/index.php/Airbox_' || histecn_rec.airbox;
		_foi_short				:= '' || histecn_rec.airbox;
		_lat					:= histecn_rec.lat;
		_lng					:= histecn_rec.lng;
		_phenomenon_time 		:= histecn_rec.measure_date;
		_phenomenon_tick_time 	:= histecn_rec.tick_date;
		_creation_date 			:= batch_time_stamp;


		/* PM1   */
		IF (histecn_rec.pm1 is not null) THEN
		select nextval('ILM0102VH01_OUT_GID_SEQ'::regclass) into new_gid;
		_observed_property 	:= 'http://wiki.aireas.com/index.php/airbox_pm1';
		_result_value 		:= histecn_rec.pm1;	
		_quality			:= 100;
		IF (_result_value < 1) THEN
			_flag_code		:= 'LowLevel';
			_value_old		:= _result_value;
			_value_new		:= 1;
			_result_value 	:= _value_new;
			_quality		:= _quality -5;
			EXECUTE 'INSERT INTO ILM0102VH01_OUT_FLAG (ILM0102VH01_OUT_gid, flag_code, value_old, value_new, creation_date ) values($1, $2, $3, $4, $5)'
				USING  new_gid, _flag_code, _value_old, _value_new, _creation_date;
		END IF; 
		IF (_result_value > 60) THEN
			_flag_code		:= 'HighLevel';
			_value_old		:= _result_value;
			_value_new		:= 60;
			_result_value 	:= _value_new;
			_quality		:= _quality -10;
			EXECUTE 'INSERT INTO ILM0102VH01_OUT_FLAG (ILM0102VH01_OUT_gid, flag_code, value_old, value_new, creation_date ) values($1, $2, $3, $4, $5)'
				USING  new_gid, _flag_code, _value_old, _value_new, _creation_date;
		END IF; 
		IF (_result_value > (histecn_rec.pm25*1.05) ) THEN  -- 5% tolerance  PM1<PM2.5<PM10
			_flag_code		:= 'PM1GTPM25';
			_value_old		:= _result_value;
			_value_new		:= histecn_rec.pm25;
			_quality		:= _quality -40;
			EXECUTE 'INSERT INTO ILM0102VH01_OUT_FLAG (ILM0102VH01_OUT_gid, flag_code, value_old, value_new, creation_date ) values($1, $2, $3, $4, $5)'
				USING  new_gid, _flag_code, _value_old, _value_new, _creation_date;
		END IF; 
		EXECUTE 'INSERT INTO ILM0102VH01_OUT (gid, feature_of_interest, foi_short, lat, lng, observed_property, result_value, phenomenon_time, phenomenon_tick_time, quality, creation_date ) values($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11)'
			USING new_gid, _feature_of_interest, _foi_short, _lat, _lng, _observed_property, _result_value, _phenomenon_time, _phenomenon_tick_time, _quality, _creation_date;
		END IF;

		/* PM2.5  */
		IF (histecn_rec.pm25 is not null) THEN
		select nextval('ILM0102VH01_OUT_GID_SEQ'::regclass) into new_gid;
		_observed_property 	:= 'http://wiki.aireas.com/index.php/airbox_pm25';
		_result_value := histecn_rec.pm25;	
		_quality			:= 100;
		IF (_result_value < 1) THEN
			_flag_code		:= 'LowLevel';
			_value_old		:= _result_value;
			_value_new		:= 1;
			_result_value 	:= _value_new;
			_quality		:= _quality -5;
			EXECUTE 'INSERT INTO ILM0102VH01_OUT_FLAG (ILM0102VH01_OUT_gid, flag_code, value_old, value_new, creation_date ) values($1, $2, $3, $4, $5)'
				USING  new_gid, _flag_code, _value_old, _value_new, _creation_date;
		END IF; 
		IF (_result_value > 150) THEN
			_flag_code		:= 'HighLevel';
			_value_old		:= _result_value;
			_value_new		:= 150;
			_result_value 	:= _value_new;
			_quality		:= _quality -10;
			EXECUTE 'INSERT INTO ILM0102VH01_OUT_FLAG (ILM0102VH01_OUT_gid, flag_code, value_old, value_new, creation_date ) values($1, $2, $3, $4, $5)'
				USING  new_gid, _flag_code, _value_old, _value_new, _creation_date;
		END IF; 
		IF (_result_value > (histecn_rec.pm10*1.05) ) THEN  -- 5% tolerance  PM1<PM2.5<PM10
			_flag_code		:= 'PM25GTPM10';
			_value_old		:= _result_value;
			_value_new		:= histecn_rec.pm10;
			_quality		:= _quality -40;
			EXECUTE 'INSERT INTO ILM0102VH01_OUT_FLAG (ILM0102VH01_OUT_gid, flag_code, value_old, value_new, creation_date ) values($1, $2, $3, $4, $5)'
				USING  new_gid, _flag_code, _value_old, _value_new, _creation_date;
		END IF; 
		EXECUTE 'INSERT INTO ILM0102VH01_OUT (gid, feature_of_interest, foi_short, lat, lng, observed_property, result_value, phenomenon_time, phenomenon_tick_time, quality, creation_date ) values($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11)'
			USING new_gid, _feature_of_interest, _foi_short, _lat, _lng, _observed_property, _result_value, _phenomenon_time, _phenomenon_tick_time, _quality, _creation_date;
		END IF;


		/* PM10  */
		IF (histecn_rec.pm10 is not null) THEN
		select nextval('ILM0102VH01_OUT_GID_SEQ'::regclass) into new_gid;
		_observed_property 	:= 'http://wiki.aireas.com/index.php/airbox_pm10';
		_result_value := histecn_rec.pm10;	
		_quality			:= 100;
		IF (_result_value < 2) THEN
			_flag_code		:= 'LowLevel';
			_value_old		:= _result_value;
			_value_new		:= 2;
			_result_value 	:= _value_new;
			_quality		:= _quality -5;
			EXECUTE 'INSERT INTO ILM0102VH01_OUT_FLAG (ILM0102VH01_OUT_gid, flag_code, value_old, value_new, creation_date ) values($1, $2, $3, $4, $5)'
				USING  new_gid, _flag_code, _value_old, _value_new, _creation_date;
		END IF; 
		IF (_result_value > 600) THEN
			_flag_code		:= 'HighLevel';
			_value_old		:= _result_value;
			_value_new		:= 600;
			_result_value 	:= _value_new;
			_quality		:= _quality -10;
			EXECUTE 'INSERT INTO ILM0102VH01_OUT_FLAG (ILM0102VH01_OUT_gid, flag_code, value_old, value_new, creation_date ) values($1, $2, $3, $4, $5)'
				USING  new_gid, _flag_code, _value_old, _value_new, _creation_date;
		END IF; 
		EXECUTE 'INSERT INTO ILM0102VH01_OUT (gid, feature_of_interest, foi_short, lat, lng, observed_property, result_value, phenomenon_time, phenomenon_tick_time, quality, creation_date ) values($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11)'
			USING new_gid, _feature_of_interest, _foi_short, _lat, _lng, _observed_property, _result_value, _phenomenon_time, _phenomenon_tick_time, _quality, _creation_date;
		END IF;


		/* RHUM   */
		IF (histecn_rec.rhum is not null) THEN
		select nextval('ILM0102VH01_OUT_GID_SEQ'::regclass) into new_gid;
		_observed_property 	:= 'http://wiki.aireas.com/index.php/airbox_rhum';
		_result_value 		:= histecn_rec.rhum;	
		_quality			:= 100;
		IF (_result_value < 1) THEN
			_flag_code		:= 'OutOfRangeLow';
			_value_old		:= _result_value;
			_value_new		:= _result_value;
			_result_value 	:= _value_new;
			_quality		:= 0;
			EXECUTE 'INSERT INTO ILM0102VH01_OUT_FLAG (ILM0102VH01_OUT_gid, flag_code, value_old, value_new, creation_date ) values($1, $2, $3, $4, $5)'
				USING  new_gid, _flag_code, _value_old, _value_new, _creation_date;
		END IF; 
		IF (_result_value > 100) THEN
			_flag_code		:= 'OutOfRangeHigh';
			_value_old		:= _result_value;
			_value_new		:= _result_value;
			_result_value 	:= _value_new;
			_quality		:= 0;
			EXECUTE 'INSERT INTO ILM0102VH01_OUT_FLAG (ILM0102VH01_OUT_gid, flag_code, value_old, value_new, creation_date ) values($1, $2, $3, $4, $5)'
				USING  new_gid, _flag_code, _value_old, _value_new, _creation_date;
		END IF; 
		EXECUTE 'INSERT INTO ILM0102VH01_OUT (gid, feature_of_interest, foi_short, lat, lng, observed_property, result_value, phenomenon_time, phenomenon_tick_time, quality, creation_date ) values($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11)'
			USING new_gid, _feature_of_interest, _foi_short, _lat, _lng, _observed_property, _result_value, _phenomenon_time, _phenomenon_tick_time, _quality, _creation_date;
		END IF;


		/* RHUMEXT   */
		IF (histecn_rec.rhumext is not null) THEN
		select nextval('ILM0102VH01_OUT_GID_SEQ'::regclass) into new_gid;
		_observed_property 	:= 'http://wiki.aireas.com/index.php/airbox_rhumext';
		_result_value 		:= histecn_rec.rhumext;	
		_quality			:= 100;
		IF (_result_value < 1) THEN
			_flag_code		:= 'OutOfRangeLow';
			_value_old		:= _result_value;
			_value_new		:= _result_value;
			_result_value 	:= _value_new;
			_quality		:= 0;
			EXECUTE 'INSERT INTO ILM0102VH01_OUT_FLAG (ILM0102VH01_OUT_gid, flag_code, value_old, value_new, creation_date ) values($1, $2, $3, $4, $5)'
				USING  new_gid, _flag_code, _value_old, _value_new, _creation_date;
		END IF; 
		IF (_result_value > 100) THEN
			_flag_code		:= 'OutOfRangeHigh';
			_value_old		:= _result_value;
			_value_new		:= _result_value;
			_result_value 	:= _value_new;
			_quality		:= 0;
			EXECUTE 'INSERT INTO ILM0102VH01_OUT_FLAG (ILM0102VH01_OUT_gid, flag_code, value_old, value_new, creation_date ) values($1, $2, $3, $4, $5)'
				USING  new_gid, _flag_code, _value_old, _value_new, _creation_date;
		END IF; 
		EXECUTE 'INSERT INTO ILM0102VH01_OUT (gid, feature_of_interest, foi_short, lat, lng, observed_property, result_value, phenomenon_time, phenomenon_tick_time, quality, creation_date ) values($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11)'
			USING new_gid, _feature_of_interest, _foi_short, _lat, _lng, _observed_property, _result_value, _phenomenon_time, _phenomenon_tick_time, _quality, _creation_date;
		END IF;


		/* TEMP   */
		IF (histecn_rec.temp is not null) THEN
		select nextval('ILM0102VH01_OUT_GID_SEQ'::regclass) into new_gid;
		_observed_property 	:= 'http://wiki.aireas.com/index.php/airbox_temp';
		_result_value 		:= histecn_rec.temp;	
		_quality			:= 100;
		IF (_result_value < -30) THEN
			_flag_code		:= 'OutOfRangeLow';
			_value_old		:= _result_value;
			_value_new		:= _result_value;
			_result_value 	:= _value_new;
			_quality		:= 0;
			EXECUTE 'INSERT INTO ILM0102VH01_OUT_FLAG (ILM0102VH01_OUT_gid, flag_code, value_old, value_new, creation_date ) values($1, $2, $3, $4, $5)'
				USING  new_gid, _flag_code, _value_old, _value_new, _creation_date;
		END IF; 
		IF (_result_value > 50) THEN
			_flag_code		:= 'OutOfRangeHigh';
			_value_old		:= _result_value;
			_value_new		:= _result_value;
			_result_value 	:= _value_new;
			_quality		:= 0;
			EXECUTE 'INSERT INTO ILM0102VH01_OUT_FLAG (ILM0102VH01_OUT_gid, flag_code, value_old, value_new, creation_date ) values($1, $2, $3, $4, $5)'
				USING  new_gid, _flag_code, _value_old, _value_new, _creation_date;
		END IF; 
		EXECUTE 'INSERT INTO ILM0102VH01_OUT (gid, feature_of_interest, foi_short, lat, lng, observed_property, result_value, phenomenon_time, phenomenon_tick_time, quality, creation_date ) values($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11)'
			USING new_gid, _feature_of_interest, _foi_short, _lat, _lng, _observed_property, _result_value, _phenomenon_time, _phenomenon_tick_time, _quality, _creation_date;
		END IF;



		/* TEMPEXT   */
		IF (histecn_rec.tempext is not null) THEN
		select nextval('ILM0102VH01_OUT_GID_SEQ'::regclass) into new_gid;
		_observed_property 	:= 'http://wiki.aireas.com/index.php/airbox_tempext';
		_result_value 		:= histecn_rec.tempext;	
		_quality			:= 100;
		IF (_result_value < -30) THEN
			_flag_code		:= 'OutOfRangeLow';
			_value_old		:= _result_value;
			_value_new		:= _result_value;
			_result_value 	:= _value_new;
			_quality		:= 0;
			EXECUTE 'INSERT INTO ILM0102VH01_OUT_FLAG (ILM0102VH01_OUT_gid, flag_code, value_old, value_new, creation_date ) values($1, $2, $3, $4, $5)'
				USING  new_gid, _flag_code, _value_old, _value_new, _creation_date;
		END IF; 
		IF (_result_value > 50) THEN
			_flag_code		:= 'OutOfRangeHigh';
			_value_old		:= _result_value;
			_value_new		:= _result_value;
			_result_value 	:= _value_new;
			_quality		:= 0;
			EXECUTE 'INSERT INTO ILM0102VH01_OUT_FLAG (ILM0102VH01_OUT_gid, flag_code, value_old, value_new, creation_date ) values($1, $2, $3, $4, $5)'
				USING  new_gid, _flag_code, _value_old, _value_new, _creation_date;
		END IF; 
		EXECUTE 'INSERT INTO ILM0102VH01_OUT (gid, feature_of_interest, foi_short, lat, lng, observed_property, result_value, phenomenon_time, phenomenon_tick_time, quality, creation_date ) values($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11)'
			USING new_gid, _feature_of_interest, _foi_short, _lat, _lng, _observed_property, _result_value, _phenomenon_time, _phenomenon_tick_time, _quality, _creation_date;
		END IF;




	END LOOP;
		
	END LOOP; -- month loop
	
	IF (init_tables = true) THEN
		CREATE INDEX ILM0102VH01_OUT_foi_op_tick_idx
  			ON public.ILM0102VH01_OUT
  			USING btree
  			(feature_of_interest, observed_property, phenomenon_tick_time);
	END IF;		

END;
$BODY$
  LANGUAGE plpgsql VOLATILE
   ;
ALTER FUNCTION public.proc_ILM0102VH01(hist_year INTEGER, init_tables BOOLEAN)
  OWNER TO postgres;   
