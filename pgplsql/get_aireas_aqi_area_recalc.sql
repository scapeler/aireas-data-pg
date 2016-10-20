/* USE/TEST1: 


select get_aireas_aqi_area_recalc('GM0772', 'EHV20141104:1', 'AiREAS_NL', timestamp '2016-02-15 00:00:00.000+02');
select get_aireas_aqi_area_recalc('GM0772', 'EHV20141104:1', 'AiREAS_NL', timestamp '2016-02-16 00:00:00.000+02');
select get_aireas_aqi_area_recalc('GM0772', 'EHV20141104:1', 'AiREAS_NL', timestamp '2016-02-17 00:00:00.000+02');
select get_aireas_aqi_area_recalc('GM0772', 'EHV20141104:1', 'AiREAS_NL', timestamp '2016-02-18 00:00:00.000+02');

select get_aireas_aqi_area_recalc('GM0772', 'EHV20141104:1', 'AiREAS_NL', timestamp '2016-06-05 00:00:00.000+02');
select get_aireas_aqi_area_recalc('GM0772', 'EHV20141104:1', 'AiREAS_NL', timestamp '2016-06-06 00:00:00.000+02');
select get_aireas_aqi_area_recalc('GM0772', 'EHV20141104:1', 'AiREAS_NL', timestamp '2016-06-07 00:00:00.000+02');
select get_aireas_aqi_area_recalc('GM0772', 'EHV20141104:1', 'AiREAS_NL', timestamp '2016-06-08 00:00:00.000+02');

select get_aireas_aqi_area_recalc('GM0772', 'EHV20141104:1', 'AiREAS_NL', timestamp '2016-10-03 00:00:00.000+02');
select get_aireas_aqi_area_recalc('GM0772', 'EHV20141104:1', 'AiREAS_NL', timestamp '2016-10-04 00:00:00.000+02');
select get_aireas_aqi_area_recalc('GM0772', 'EHV20141104:1', 'AiREAS_NL', timestamp '2016-10-05 00:00:00.000+02');
select get_aireas_aqi_area_recalc('GM0772', 'EHV20141104:1', 'AiREAS_NL', timestamp '2016-10-06 00:00:00.000+02');
*/-- delete from grid_gem_foi_aqi where avg_aqi_type = 'AiREAS_NL'
-- DROP FUNCTION get_aireas_aqi_area_recalc(CHARACTER VARYING(6), CHARACTER VARYING(15), aqi_type varchar(24),retrieveddate TIMESTAMP WITH TIME ZONE)
CREATE OR REPLACE FUNCTION public.get_aireas_aqi_area_recalc( gm_code CHARACTER VARYING(6), grid_code CHARACTER VARYING(15), aqi_type varchar(24), retrieveddate TIMESTAMP WITH TIME ZONE)
  RETURNS  void AS
$BODY$
DECLARE
  grid record;
  grid_gem_foi record;
  air record;
  avg_period_param varchar(24);
  retrieveddate_selection timestamp with time zone;
  retrieveddate_already_calculated timestamp with time zone;
  
  aqi_max_airbox numeric;
  aqi_max_area numeric;
  aqi_type varchar(24);
  
  retrieveddates record;
  last_date timestamp with time zone;
  
BEGIN
	aqi_type := $3;
	last_date := $4 + INTERVAL '1 day';
		
--RAISE unique_violation USING MESSAGE = 'retrieveddate: '  || ' ' || retrieveddate_selection || ' ' || retrieveddate_already_calculated; --for debug purpose
	

	FOR retrieveddates IN EXECUTE 'SELECT retrieveddate from aireas a where retrieveddate >= $1 and retrieveddate < $2 group by a.retrieveddate order by a.retrieveddate '
		USING $4,last_date
	LOOP

	   -- loop per selected retrieveddate

		-- Calculate AQI per retrieveddate 
		EXECUTE 'SELECT get_aireas_aqi_area($1,$2,$3,$4) '
			USING $1,$2, $3, retrieveddates.retrieveddate ;
--			INTO air;
			
		RAISE NOTICE 'DateR(%)', retrieveddates.retrieveddate;	

	END LOOP;
    
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
   ;
ALTER FUNCTION public.get_aireas_aqi_area_recalc(gm_code CHARACTER VARYING(6), grid_code CHARACTER VARYING(15), aqi_type varchar(24), retrieveddate TIMESTAMP WITH TIME ZONE )
  OWNER TO postgres;
   
