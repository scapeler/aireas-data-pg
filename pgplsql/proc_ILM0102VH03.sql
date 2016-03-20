/*
 USE/TEST: 
 
 select proc_ILM0102VH03(2015, cast('http://wiki.aireas.com/index.php/airbox_pm1' as character varying) );
 select proc_ILM0102VH03(2015, cast('http://wiki.aireas.com/index.php/airbox_pm25' as character varying) );
 select proc_ILM0102VH03(2015, cast('http://wiki.aireas.com/index.php/airbox_pm10' as character varying) );
 
 
 select * from ILM0102VH01_OUT_flag
 where flag_code = 'LowerThanAvg'
 OR flag_code = 'HigherThanAvg'
  limit 100;
  
 select o.feature_of_interest, o.observed_property, of.flag_code, count(*) 
from ILM0102VH01_OUT o
 , ILM0102VH01_OUT_flag of
where o.gid = of.ILM0102VH01_OUT_gid
AND (of.flag_code = 'LowerThanAvg'
     OR of.flag_code = 'HigherThanAvg')
group by o.feature_of_interest, o.observed_property, of.flag_code
order by o.feature_of_interest, o.observed_property, of.flag_code;
 
 
 delete from ILM0102VH01_OUT_FLAG where flag_code = 'LowerThanAvg';
 delete from ILM0102VH01_OUT_FLAG where flag_code = 'HigherThanAvg';
 
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
 
 DROP FUNCTION proc_ILM0102VH03(hist_year INTEGER, observed_property varchar(250))
*/
CREATE OR REPLACE FUNCTION public.proc_ILM0102VH03(hist_year INTEGER, observed_property varchar(250))
  RETURNS  void AS
$BODY$
DECLARE

	/* parameters */
	_parm_hist_year 		INTEGER;
	_parm_observed_property varchar(250);
    
	maincursor	cursor FOR SELECT * FROM ILM0102VH01_OUT o 
		WHERE 	extract(year from (phenomenon_tick_time - interval '1 hour')) = _parm_hist_year 
		--AND 	extract(month from (o.phenomenon_tick_time - interval '1 hour')) = 1
		AND 	o.observed_property = _parm_observed_property
		AND		o.quality > 50;
--		AND 	o.result_value > 40;
--		ORDER BY  o.feature_of_interest, o.observed_property, o.phenomenon_tick_time;
		

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
  _value_old 		double precision;
  _value_new 		double precision; 

  
  ILM0102VH01_OUT_rec 	record;
  batch_time_stamp 	timestamp with time zone;
  month integer;
  first_value BOOLEAN;
--  prev_value double precision;
--  prev_feature_of_interest varchar(250); 
  value_diff double precision;
  _foi_grid_cell integer;
  _avg_result_value double precision;
  _diff_result_value double precision;
  
  
  
BEGIN
	_parm_hist_year 			:= $1;
	_parm_observed_property 	:= $2;
	batch_time_stamp	:= current_timestamp;
	first_value			:= true;
--	prev_value			:= 0;
	value_diff			:= 0;
	
--RAISE unique_violation USING MESSAGE = 'retrieveddate: '  || ' ' || retrieveddate_selection; --for debug purpose
	
--	OPEN maincursor;
			
/*
	FOR ILM0102VH01_OUT_rec IN EXECUTE 'SELECT * FROM ILM0102VH01_OUT o 
		WHERE 	extract(year from (phenomenon_tick_time - interval ''1 hour'')) = $1 
		AND 	o.observed_property = $2 
		ORDER BY  o.feature_of_interest, o.observed_property, o.phenomenon_tick_time '
		USING _parm_hist_year, _parm_observed_property
*/

	FOR ILM0102VH01_OUT_rec IN maincursor
	LOOP
		
		/* get grid cell of this airbox */
		SELECT grid_gem_cell_gid
  			FROM public.grid_gem_cell_airbox
  			where airbox = ILM0102VH01_OUT_rec.foi_short || '.cal'
  			order by factor_distance
  			limit 1
			into _foi_grid_cell;
		
		/* get avg of max 3 airboxes within range of processed airbox (not included)  */
		SELECT AVG(o.result_value) avg_result_value
		FROM ILM0102VH01_OUT o
		WHERE o.feature_of_interest in (
			SELECT 'http://wiki.aireas.com/index.php/Airbox_' || substring(ggca.airbox
			 ,1,position('.cal' in ggca.airbox)-1) 
  				FROM public.grid_gem_cell_airbox ggca
  				where ggca.grid_gem_cell_gid = _foi_grid_cell
				and ggca.factor_distance <= 1000  -- airbox within 1000m distance
				and ggca.airbox <>  (ILM0102VH01_OUT_rec.foi_short || '.cal')
				limit 3 )
		AND o.quality > 50  -- over 50% quality is useful
		AND o.phenomenon_tick_time = ILM0102VH01_OUT_rec.phenomenon_tick_time
		AND o.observed_property = ILM0102VH01_OUT_rec.observed_property
		INTO _avg_result_value
		;
		
		IF _avg_result_value is null THEN
			CONTINUE;
		END IF;
		
		_diff_result_value := _avg_result_value - ILM0102VH01_OUT_rec.result_value;
		
		IF ( _diff_result_value > 0 -- result_value is lower than avg
			 AND @_diff_result_value > ILM0102VH01_OUT_rec.result_value *0.40  ) THEN  -- diff > 40% of result_value
			_flag_code		:= 'LowerThanAvg';
			_value_old		:= _avg_result_value;
			_value_new		:= ILM0102VH01_OUT_rec.result_value;
			_result_value 	:= _value_new;
			_quality		:= _quality -10;
			EXECUTE 'INSERT INTO ILM0102VH01_OUT_FLAG (ILM0102VH01_OUT_gid, flag_code, value_old, value_new, creation_date ) values($1, $2, $3, $4, $5)'
				USING  ILM0102VH01_OUT_rec.gid, _flag_code, _value_old, _value_new, batch_time_stamp;
			EXECUTE 'UPDATE ILM0102VH01_OUT set quality = $2 WHERE gid = $1 ;'
				USING  ILM0102VH01_OUT_rec.gid, _quality;	
		END IF; 
		IF ( _diff_result_value < 0 -- result_value is higher than avg
			 AND @_diff_result_value > ILM0102VH01_OUT_rec.result_value *0.40  ) THEN  -- diff > 40% of result_value
			_flag_code		:= 'HigherThanAvg';
			_value_old		:= _avg_result_value;
			_value_new		:= ILM0102VH01_OUT_rec.result_value;
			_result_value 	:= _value_new;
			_quality		:= _quality -10;
			EXECUTE 'INSERT INTO ILM0102VH01_OUT_FLAG (ILM0102VH01_OUT_gid, flag_code, value_old, value_new, creation_date ) values($1, $2, $3, $4, $5)'
				USING  ILM0102VH01_OUT_rec.gid, _flag_code, _value_old, _value_new, batch_time_stamp;
			EXECUTE 'UPDATE ILM0102VH01_OUT set quality = $2 WHERE gid = $1 ;'
				USING  ILM0102VH01_OUT_rec.gid, _quality;	
		END IF; 
		
	END LOOP;

--	CLOSE maincursor;
		
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
   ;
ALTER FUNCTION public.proc_ILM0102VH03(hist_year INTEGER, observed_property varchar(250))
  OWNER TO postgres;   
