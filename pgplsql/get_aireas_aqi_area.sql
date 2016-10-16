-- USE/TEST: select get_aireas_aqi_area('GM0772', 'EHV20141104:1', 'AiREAS_NL'); 
-- select * from grid_gem_aqi order by  feature_of_interest, retrieveddate;
-- delete from grid_gem_aqi; 
-- DROP FUNCTION get_aireas_aqi_area(CHARACTER VARYING(6), CHARACTER VARYING(15), aqi_type varchar(24))
CREATE OR REPLACE FUNCTION public.get_aireas_aqi_area( gm_code CHARACTER VARYING(6), grid_code CHARACTER VARYING(15), aqi_type varchar(24))
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
  
BEGIN
	aqi_type := $3;
	
	EXECUTE 'SELECT * FROM grid_gem WHERE gm_code = $1 AND grid_code = $2'
		USING $1, $2
		INTO grid;
	EXECUTE 'SELECT max(retrieveddate) from aireas' 
		INTO retrieveddate_selection;
	EXECUTE 'SELECT max(aqi.retrieveddate) 
		from grid_gem_foi_aqi aqi
		WHERE 1=1
		AND aqi.grid_code = $1
		AND aqi.retrieveddate = $2
		AND aqi.avg_aqi_type = $3 ' 
		USING grid.grid_code, retrieveddate_selection, aqi_type
		INTO retrieveddate_already_calculated;
--RAISE unique_violation USING MESSAGE = 'retrieveddate: '  || ' ' || retrieveddate_selection; --for debug purpose
	IF (retrieveddate_already_calculated is null) THEN

	aqi_max_area   := 0;
	aqi_max_airbox := 0;
	

	FOR grid_gem_foi IN EXECUTE 'SELECT distinct(ggca.airbox) feature_of_interest   FROM grid_gem_cell ggc, grid_gem_cell_airbox ggca WHERE ggc.grid_code = $1 and ggc.gid = ggca.grid_gem_cell_gid'
		USING grid.grid_code
	LOOP

	   -- loop per feature of interest / airbox

		aqi_max_airbox := 0;

	   
		-- Calculate per airbox the AQI for PM1, PM25, PM10, OZON, UFP, NO2
 		avg_period_param := '1hr';
		EXECUTE 'SELECT avg_type,retrieveddate,avg_avg ,avg_aqi,avg_aqi_type from get_aireas_aqi($1,$2,$3,$4,$5) AS (avg_type varchar(60), retrieveddate TIMESTAMP WITH TIME ZONE, avg_avg numeric, avg_aqi numeric, avg_aqi_type varchar(60))'
			USING 'PM1',retrieveddate_selection, grid_gem_foi.feature_of_interest, avg_period_param, aqi_type
			INTO air;
		IF (air.retrieveddate = retrieveddate_selection AND air.avg_aqi > 0) THEN
			EXECUTE 'INSERT INTO grid_gem_foi_aqi (grid_code, feature_of_interest, retrieveddate, avg_type, avg_period,
				avg_avg, avg_aqi, avg_aqi_type, creation_date) 
				VALUES ( 
				$1, $2, $3, $4, $5, $6, $7, $8, $9)'
			USING grid.grid_code, grid_gem_foi.feature_of_interest, retrieveddate_selection,air.avg_type, avg_period_param,
			 air.avg_avg, air.avg_aqi, air.avg_aqi_type, current_timestamp;
		END IF;	

		IF (air.avg_aqi > aqi_max_airbox) THEN
			aqi_max_airbox := air.avg_aqi;
		END IF;

		-- Calculate per airbox the AQI for PM1, PM25, PM10, OZON, UFP, NO2
 		avg_period_param := '1hr';
		EXECUTE 'SELECT avg_type,retrieveddate,avg_avg ,avg_aqi,avg_aqi_type from get_aireas_aqi($1,$2,$3,$4,$5) AS (avg_type varchar(60), retrieveddate TIMESTAMP WITH TIME ZONE, avg_avg numeric, avg_aqi numeric, avg_aqi_type varchar(60))'
			USING 'PM25',retrieveddate_selection, grid_gem_foi.feature_of_interest, avg_period_param, aqi_type
			INTO air;
		IF (air.retrieveddate = retrieveddate_selection AND air.avg_aqi > 0) THEN
			EXECUTE 'INSERT INTO grid_gem_foi_aqi (grid_code, feature_of_interest, retrieveddate, avg_type, avg_period,
				avg_avg, avg_aqi, avg_aqi_type, creation_date) 
				VALUES ( 
				$1, $2, $3, $4, $5, $6, $7, $8, $9)'
			USING grid.grid_code, grid_gem_foi.feature_of_interest, retrieveddate_selection,air.avg_type, avg_period_param,
			 air.avg_avg, air.avg_aqi, air.avg_aqi_type, current_timestamp;
		END IF;	

		IF (air.avg_aqi > aqi_max_airbox) THEN
			aqi_max_airbox := air.avg_aqi;
		END IF;

		-- Calculate per airbox the AQI for PM1, PM25, PM10, OZON, UFP, NO2
 		avg_period_param := '1hr';
		EXECUTE 'SELECT avg_type,retrieveddate,avg_avg ,avg_aqi,avg_aqi_type from get_aireas_aqi($1,$2,$3,$4,$5) AS (avg_type varchar(60), retrieveddate TIMESTAMP WITH TIME ZONE, avg_avg numeric, avg_aqi numeric, avg_aqi_type varchar(60))'
			USING 'PM10',retrieveddate_selection, grid_gem_foi.feature_of_interest, avg_period_param, aqi_type
			INTO air;
		IF (air.retrieveddate = retrieveddate_selection AND air.avg_aqi > 0) THEN
			EXECUTE 'INSERT INTO grid_gem_foi_aqi (grid_code, feature_of_interest, retrieveddate, avg_type, avg_period,
				avg_avg, avg_aqi, avg_aqi_type, creation_date) 
				VALUES ( 
				$1, $2, $3, $4, $5, $6, $7, $8, $9)'
			USING grid.grid_code, grid_gem_foi.feature_of_interest, retrieveddate_selection,air.avg_type, avg_period_param,
			 air.avg_avg, air.avg_aqi, air.avg_aqi_type, current_timestamp;
		END IF;	

		IF (air.avg_aqi > aqi_max_airbox) THEN
			aqi_max_airbox := air.avg_aqi;
		END IF;

		-- Calculate per airbox the AQI for PM1, PM25, PM10, OZON, UFP, NO2
 		avg_period_param := '1hr';
		EXECUTE 'SELECT avg_type,retrieveddate,avg_avg ,avg_aqi,avg_aqi_type from get_aireas_aqi($1,$2,$3,$4,$5) AS (avg_type varchar(60), retrieveddate TIMESTAMP WITH TIME ZONE, avg_avg numeric, avg_aqi numeric, avg_aqi_type varchar(60))'
			USING 'OZON',retrieveddate_selection, grid_gem_foi.feature_of_interest, avg_period_param, aqi_type
			INTO air;
		IF (air.retrieveddate = retrieveddate_selection AND air.avg_aqi > 0) THEN
			EXECUTE 'INSERT INTO grid_gem_foi_aqi (grid_code, feature_of_interest, retrieveddate, avg_type, avg_period,
				avg_avg, avg_aqi, avg_aqi_type, creation_date) 
				VALUES ( 
				$1, $2, $3, $4, $5, $6, $7, $8, $9)'
			USING grid.grid_code, grid_gem_foi.feature_of_interest, retrieveddate_selection,air.avg_type, avg_period_param,
			 air.avg_avg, air.avg_aqi, air.avg_aqi_type, current_timestamp;
		END IF;	

		IF (air.avg_aqi > aqi_max_airbox) THEN
			aqi_max_airbox := air.avg_aqi;
		END IF;

		-- Calculate per airbox the AQI for PM1, PM25, PM10, OZON, UFP, NO2
 		avg_period_param := '1hr';
		EXECUTE 'SELECT avg_type,retrieveddate,avg_avg ,avg_aqi,avg_aqi_type from get_aireas_aqi($1,$2,$3,$4,$5) AS (avg_type varchar(60), retrieveddate TIMESTAMP WITH TIME ZONE, avg_avg numeric, avg_aqi numeric, avg_aqi_type varchar(60))'
			USING 'UFP',retrieveddate_selection, grid_gem_foi.feature_of_interest, avg_period_param, aqi_type
			INTO air;
		IF (air.retrieveddate = retrieveddate_selection AND air.avg_aqi > 0) THEN
			EXECUTE 'INSERT INTO grid_gem_foi_aqi (grid_code, feature_of_interest, retrieveddate, avg_type, avg_period,
				avg_avg, avg_aqi, avg_aqi_type, creation_date) 
				VALUES ( 
				$1, $2, $3, $4, $5, $6, $7, $8, $9)'
			USING grid.grid_code, grid_gem_foi.feature_of_interest, retrieveddate_selection,air.avg_type, avg_period_param,
			 air.avg_avg, air.avg_aqi, air.avg_aqi_type, current_timestamp;
		END IF;	

		IF (air.avg_aqi > aqi_max_airbox) THEN
			aqi_max_airbox := air.avg_aqi;
		END IF;

		-- Calculate per airbox the AQI for PM1, PM25, PM10, OZON, UFP, NO2
 		avg_period_param := '1hr';
		EXECUTE 'SELECT avg_type,retrieveddate,avg_avg ,avg_aqi,avg_aqi_type from get_aireas_aqi($1,$2,$3,$4,$5) AS (avg_type varchar(60), retrieveddate TIMESTAMP WITH TIME ZONE, avg_avg numeric, avg_aqi numeric, avg_aqi_type varchar(60))'
			USING 'NO2',retrieveddate_selection, grid_gem_foi.feature_of_interest, avg_period_param, aqi_type
			INTO air;
		IF (air.retrieveddate = retrieveddate_selection AND air.avg_aqi > 0) THEN
			EXECUTE 'INSERT INTO grid_gem_foi_aqi (grid_code, feature_of_interest, retrieveddate, avg_type, avg_period,
				avg_avg, avg_aqi, avg_aqi_type, creation_date) 
				VALUES ( 
				$1, $2, $3, $4, $5, $6, $7, $8, $9)'
			USING grid.grid_code, grid_gem_foi.feature_of_interest, retrieveddate_selection,air.avg_type, avg_period_param,
			 air.avg_avg, air.avg_aqi, air.avg_aqi_type, current_timestamp;
		END IF;	

		IF (air.avg_aqi > aqi_max_airbox) THEN
			aqi_max_airbox := air.avg_aqi;
		END IF;



        --
		-- airbox AQI = max AQI of all sensors
		--
		IF (aqi_max_airbox > 0) THEN
			EXECUTE 'INSERT INTO grid_gem_foi_aqi (grid_code, feature_of_interest, retrieveddate, avg_type, avg_period,
				avg_aqi, avg_aqi_type, creation_date) 
				VALUES ( 
				$1, $2, $3, $4, $5, $6, $7, $8)'
			USING grid.grid_code, grid_gem_foi.feature_of_interest, retrieveddate_selection,'overall', avg_period_param,
			 aqi_max_airbox, air.avg_aqi_type, current_timestamp;
		END IF;	
		


		IF (aqi_max_airbox > aqi_max_area) THEN
			aqi_max_area := aqi_max_airbox;
		END IF;




	END LOOP;


    --
	-- area AQI = max AQI of all airboxes AQI
	--
	IF (aqi_max_area > 0) THEN
		EXECUTE 'INSERT INTO grid_gem_foi_aqi (grid_code, feature_of_interest, retrieveddate, avg_type, avg_period,
			avg_aqi, avg_aqi_type, creation_date) 
			VALUES ( 
			$1, $2, $3, $4, $5, $6, $7, $8)'
		USING grid.grid_code, 'overall', retrieveddate_selection,'overall', avg_period_param,
		 aqi_max_area, air.avg_aqi_type, current_timestamp;
	END IF;	


    --
	-- area AQI = max AQI per sensortype per area
	--
	IF (aqi_max_area > 0) THEN
		EXECUTE 'INSERT INTO grid_gem_foi_aqi (grid_code, feature_of_interest, retrieveddate, avg_type, avg_period,
			avg_aqi, avg_aqi_type, creation_date)  
			SELECT $1, $2, $3, avg_type, $4, max(avg_aqi), $5, $6  
			FROM  public.grid_gem_foi_aqi aqi 
			--, (select grid_code, avg_period, max(retrieveddate) retrieveddate from public.grid_gem_foi_aqi where date_part(''minute'', retrieveddate) = 1 group by grid_code, avg_period) actual  
			where 1=1  
			and avg_type <> ''overall''  
			--and date_part(''minute'', aqi.retrieveddate) = 1  
			and aqi.avg_period = $4 
			--and actual.grid_code = aqi.grid_code  
			--and actual.avg_period = aqi.avg_period
			and aqi.grid_code = $1 
			and aqi.retrieveddate = $3 
			group by avg_type, aqi.retrieveddate  
			order by avg_type, aqi.retrieveddate '
		USING grid.grid_code, 'overall', retrieveddate_selection, avg_period_param,
			air.avg_aqi_type, current_timestamp;
	END IF;	



	
	END IF;
 
    
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
   ;
ALTER FUNCTION public.get_aireas_aqi_area(gm_code CHARACTER VARYING(6), grid_code CHARACTER VARYING(15), aqi_type varchar(24) )
  OWNER TO postgres;
   
