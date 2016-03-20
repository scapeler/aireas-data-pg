/*
 USE/TEST: 
 
 select proc_ILM0102VH02(2015, cast('http://wiki.aireas.com/index.php/airbox_pm1' as character varying) );
 select proc_ILM0102VH02(2015, cast('http://wiki.aireas.com/index.php/airbox_pm25' as character varying) );
 select proc_ILM0102VH02(2015, cast('http://wiki.aireas.com/index.php/airbox_pm10' as character varying) );
 select proc_ILM0102VH02(2015, cast('http://wiki.aireas.com/index.php/airbox_temp' as character varying) );
 select proc_ILM0102VH02(2015, cast('http://wiki.aireas.com/index.php/airbox_tempext' as character varying) );
 select proc_ILM0102VH02(2015, cast('http://wiki.aireas.com/index.php/airbox_rhum' as character varying) );
 select proc_ILM0102VH02(2015, cast('http://wiki.aireas.com/index.php/airbox_rhumext' as character varying) );
 
 
 select * from ILM0102VH01_OUT limit 100;
 
 delete from ILM0102VH01_OUT_FLAG where flag_code = 'JumpUp';
 delete from ILM0102VH01_OUT_FLAG where flag_code = 'JumpDown';
 
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
 
 DROP FUNCTION proc_ILM0102VH02(hist_year INTEGER, observed_property varchar(250))
*/
CREATE OR REPLACE FUNCTION public.proc_ILM0102VH02(hist_year INTEGER, observed_property varchar(250))
  RETURNS  void AS
$BODY$
DECLARE
  
  /*  ILM0102VH01_OUT */
  _feature_of_interest varchar(250);
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
  _value_old 		double precision;
  _value_new 		double precision; 
  
  /* parameters */
  hist_year 		INTEGER;
  observed_property varchar(250);
  
  ILM0102VH01_OUT_rec 	record;
  batch_time_stamp 	timestamp with time zone;
  month integer;
  first_value BOOLEAN;
  prev_value double precision;
  prev_feature_of_interest varchar(250); 
  value_diff double precision;
  
  
BEGIN
	hist_year 			:= $1;
	observed_property 	:= $2;
	batch_time_stamp	:= current_timestamp;
	first_value			:= true;
	prev_value			:= 0;
	value_diff			:= 0;
	
--RAISE unique_violation USING MESSAGE = 'retrieveddate: '  || ' ' || retrieveddate_selection; --for debug purpose
	
			
	FOR ILM0102VH01_OUT_rec IN EXECUTE 'SELECT * FROM ILM0102VH01_OUT o 
		WHERE 	extract(year from (phenomenon_tick_time - interval ''1 hour'')) = $1 
		AND 	o.observed_property = $2 
		AND 	o.quality > 50
		ORDER BY  o.feature_of_interest, o.observed_property, o.phenomenon_tick_time '
		USING hist_year, observed_property
	LOOP
		
		IF first_value = true THEN
			prev_value 					:= ILM0102VH01_OUT_rec.result_value;
			prev_feature_of_interest 	:= ILM0102VH01_OUT_rec.feature_of_interest;
			first_value 				:= false;
			CONTINUE;
		END IF;

		IF (prev_feature_of_interest <> ILM0102VH01_OUT_rec.feature_of_interest) THEN
			prev_value 					:= ILM0102VH01_OUT_rec.result_value;
			prev_feature_of_interest 	:= ILM0102VH01_OUT_rec.feature_of_interest;
			first_value 				:= false;
			CONTINUE;
		END IF;

		value_diff 		:= ILM0102VH01_OUT_rec.result_value - prev_value;	
			
		IF ( value_diff > 0 AND value_diff > ILM0102VH01_OUT_rec.result_value*2 ) THEN
			_flag_code		:= 'JumpUp';
			_value_old		:= prev_value;
			_value_new		:= ILM0102VH01_OUT_rec.result_value;
			_result_value 	:= _value_new;
			_quality		:= _quality -5;
			EXECUTE 'INSERT INTO ILM0102VH01_OUT_FLAG (ILM0102VH01_OUT_gid, flag_code, value_old, value_new, creation_date ) values($1, $2, $3, $4, $5)'
				USING  ILM0102VH01_OUT_rec.gid, _flag_code, _value_old, _value_new, batch_time_stamp;
			EXECUTE 'UPDATE ILM0102VH01_OUT set quality = $2 WHERE gid = $1 ;'
				USING  ILM0102VH01_OUT_rec.gid, _quality;
		END IF; 
		IF ( value_diff < 0 AND value_diff < ILM0102VH01_OUT_rec.result_value*-2 ) THEN
			_flag_code		:= 'JumpDown';
			_value_old		:= prev_value;
			_value_new		:= ILM0102VH01_OUT_rec.result_value;
			_result_value 	:= _value_new;
			_quality		:= _quality -5;
			EXECUTE 'INSERT INTO ILM0102VH01_OUT_FLAG (ILM0102VH01_OUT_gid, flag_code, value_old, value_new, creation_date ) values($1, $2, $3, $4, $5)'
				USING  ILM0102VH01_OUT_rec.gid, _flag_code, _value_old, _value_new, batch_time_stamp;
			EXECUTE 'UPDATE ILM0102VH01_OUT set quality = $2 WHERE gid = $1 ;'
				USING  ILM0102VH01_OUT_rec.gid, _quality;
		END IF; 
		
		prev_value 					:= ILM0102VH01_OUT_rec.result_value;
		prev_feature_of_interest 	:= ILM0102VH01_OUT_rec.feature_of_interest;

	END LOOP;
		
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
   ;
ALTER FUNCTION public.proc_ILM0102VH02(hist_year INTEGER, observed_property varchar(250))
  OWNER TO postgres;   
