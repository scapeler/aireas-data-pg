-- USE/TEST: select get_aireas_aqi_area('GM0772', 'EHV20141104:1'); 
-- select * from grid_gem_aqi order by  feature_of_interest, retrieveddate;
-- delete from grid_gem_aqi; 
-- DROP FUNCTION get_aireas_aqi_area(CHARACTER VARYING(6), CHARACTER VARYING(15))
CREATE OR REPLACE FUNCTION public.get_aireas_aqi_area( gm_code CHARACTER VARYING(6), grid_code CHARACTER VARYING(15))
  RETURNS  void AS
$BODY$
DECLARE
  grid record;
  grid_gem_foi record;
  air record;
  avg_period_param varchar(24);
  retrieveddate_selection timestamp with time zone;
  retrieveddate_already_calculated timestamp with time zone;
BEGIN
	EXECUTE 'SELECT * FROM grid_gem WHERE gm_code = $1 AND grid_code = $2'
		USING $1, $2
		INTO grid;
	EXECUTE 'SELECT max(retrieveddate) from aireas' 
		INTO retrieveddate_selection;
	EXECUTE 'SELECT max(aqi.retrieveddate) 
		from grid_gem_foi_aqi aqi
		WHERE 1=1
		AND aqi.grid_code = $1
		AND aqi.retrieveddate = $2' 
		USING grid.grid_code, retrieveddate_selection
		INTO retrieveddate_already_calculated;
--RAISE unique_violation USING MESSAGE = 'retrieveddate: '  || ' ' || retrieveddate_selection; --for debug purpose
	IF (retrieveddate_already_calculated is null) THEN

	

	FOR grid_gem_foi IN EXECUTE 'SELECT distinct(ggca.airbox) feature_of_interest   FROM grid_gem_cell ggc, grid_gem_cell_airbox ggca WHERE ggc.grid_code = $1 and ggc.gid = ggca.grid_gem_cell_gid'
		USING grid.grid_code
	LOOP
	
		-- Calculate per airbox the AQI for PM1, PM25, PM10, OZON, UFP, NO2
 		avg_period_param := '1hr';
		EXECUTE 'SELECT avg_type,retrieveddate,avg_avg ,avg_aqi,avg_aqi_type from get_aireas_aqi($1,$2,$3,$4) AS (avg_type varchar(60), retrieveddate TIMESTAMP WITH TIME ZONE, avg_avg numeric, avg_aqi numeric, avg_aqi_type varchar(60))'
			USING 'PM1',retrieveddate_selection, grid_gem_foi.feature_of_interest, avg_period_param
			INTO air;
		IF (air.retrieveddate = retrieveddate_selection AND air.avg_aqi > 0) THEN
			EXECUTE 'INSERT INTO grid_gem_foi_aqi (grid_code, feature_of_interest, retrieveddate, avg_type, avg_period,
				avg_avg, avg_aqi, avg_aqi_type, creation_date) 
				VALUES ( 
				$1, $2, $3, $4, $5, $6, $7, $8, $9)'
			USING grid.grid_code, grid_gem_foi.feature_of_interest, retrieveddate_selection,air.avg_type, avg_period_param,
			 air.avg_avg, air.avg_aqi, air.avg_aqi_type, current_timestamp;
		END IF;	

		-- Calculate per airbox the AQI for PM1, PM25, PM10, OZON, UFP, NO2
 		avg_period_param := '1hr';
		EXECUTE 'SELECT avg_type,retrieveddate,avg_avg ,avg_aqi,avg_aqi_type from get_aireas_aqi($1,$2,$3,$4) AS (avg_type varchar(60), retrieveddate TIMESTAMP WITH TIME ZONE, avg_avg numeric, avg_aqi numeric, avg_aqi_type varchar(60))'
			USING 'PM25',retrieveddate_selection, grid_gem_foi.feature_of_interest, avg_period_param
			INTO air;
		IF (air.retrieveddate = retrieveddate_selection AND air.avg_aqi > 0) THEN
			EXECUTE 'INSERT INTO grid_gem_foi_aqi (grid_code, feature_of_interest, retrieveddate, avg_type, avg_period,
				avg_avg, avg_aqi, avg_aqi_type, creation_date) 
				VALUES ( 
				$1, $2, $3, $4, $5, $6, $7, $8, $9)'
			USING grid.grid_code, grid_gem_foi.feature_of_interest, retrieveddate_selection,air.avg_type, avg_period_param,
			 air.avg_avg, air.avg_aqi, air.avg_aqi_type, current_timestamp;
		END IF;	

		-- Calculate per airbox the AQI for PM1, PM25, PM10, OZON, UFP, NO2
 		avg_period_param := '1hr';
		EXECUTE 'SELECT avg_type,retrieveddate,avg_avg ,avg_aqi,avg_aqi_type from get_aireas_aqi($1,$2,$3,$4) AS (avg_type varchar(60), retrieveddate TIMESTAMP WITH TIME ZONE, avg_avg numeric, avg_aqi numeric, avg_aqi_type varchar(60))'
			USING 'PM10',retrieveddate_selection, grid_gem_foi.feature_of_interest, avg_period_param
			INTO air;
		IF (air.retrieveddate = retrieveddate_selection AND air.avg_aqi > 0) THEN
			EXECUTE 'INSERT INTO grid_gem_foi_aqi (grid_code, feature_of_interest, retrieveddate, avg_type, avg_period,
				avg_avg, avg_aqi, avg_aqi_type, creation_date) 
				VALUES ( 
				$1, $2, $3, $4, $5, $6, $7, $8, $9)'
			USING grid.grid_code, grid_gem_foi.feature_of_interest, retrieveddate_selection,air.avg_type, avg_period_param,
			 air.avg_avg, air.avg_aqi, air.avg_aqi_type, current_timestamp;
		END IF;	

		-- Calculate per airbox the AQI for PM1, PM25, PM10, OZON, UFP, NO2
 		avg_period_param := '1hr';
		EXECUTE 'SELECT avg_type,retrieveddate,avg_avg ,avg_aqi,avg_aqi_type from get_aireas_aqi($1,$2,$3,$4) AS (avg_type varchar(60), retrieveddate TIMESTAMP WITH TIME ZONE, avg_avg numeric, avg_aqi numeric, avg_aqi_type varchar(60))'
			USING 'OZON',retrieveddate_selection, grid_gem_foi.feature_of_interest, avg_period_param
			INTO air;
		IF (air.retrieveddate = retrieveddate_selection AND air.avg_aqi > 0) THEN
			EXECUTE 'INSERT INTO grid_gem_foi_aqi (grid_code, feature_of_interest, retrieveddate, avg_type, avg_period,
				avg_avg, avg_aqi, avg_aqi_type, creation_date) 
				VALUES ( 
				$1, $2, $3, $4, $5, $6, $7, $8, $9)'
			USING grid.grid_code, grid_gem_foi.feature_of_interest, retrieveddate_selection,air.avg_type, avg_period_param,
			 air.avg_avg, air.avg_aqi, air.avg_aqi_type, current_timestamp;
		END IF;	

		-- Calculate per airbox the AQI for PM1, PM25, PM10, OZON, UFP, NO2
 		avg_period_param := '1hr';
		EXECUTE 'SELECT avg_type,retrieveddate,avg_avg ,avg_aqi,avg_aqi_type from get_aireas_aqi($1,$2,$3,$4) AS (avg_type varchar(60), retrieveddate TIMESTAMP WITH TIME ZONE, avg_avg numeric, avg_aqi numeric, avg_aqi_type varchar(60))'
			USING 'UFP',retrieveddate_selection, grid_gem_foi.feature_of_interest, avg_period_param
			INTO air;
		IF (air.retrieveddate = retrieveddate_selection AND air.avg_aqi > 0) THEN
			EXECUTE 'INSERT INTO grid_gem_foi_aqi (grid_code, feature_of_interest, retrieveddate, avg_type, avg_period,
				avg_avg, avg_aqi, avg_aqi_type, creation_date) 
				VALUES ( 
				$1, $2, $3, $4, $5, $6, $7, $8, $9)'
			USING grid.grid_code, grid_gem_foi.feature_of_interest, retrieveddate_selection,air.avg_type, avg_period_param,
			 air.avg_avg, air.avg_aqi, air.avg_aqi_type, current_timestamp;
		END IF;	

		-- Calculate per airbox the AQI for PM1, PM25, PM10, OZON, UFP, NO2
 		avg_period_param := '1hr';
		EXECUTE 'SELECT avg_type,retrieveddate,avg_avg ,avg_aqi,avg_aqi_type from get_aireas_aqi($1,$2,$3,$4) AS (avg_type varchar(60), retrieveddate TIMESTAMP WITH TIME ZONE, avg_avg numeric, avg_aqi numeric, avg_aqi_type varchar(60))'
			USING 'NO2',retrieveddate_selection, grid_gem_foi.feature_of_interest, avg_period_param
			INTO air;
		IF (air.retrieveddate = retrieveddate_selection AND air.avg_aqi > 0) THEN
			EXECUTE 'INSERT INTO grid_gem_foi_aqi (grid_code, feature_of_interest, retrieveddate, avg_type, avg_period,
				avg_avg, avg_aqi, avg_aqi_type, creation_date) 
				VALUES ( 
				$1, $2, $3, $4, $5, $6, $7, $8, $9)'
			USING grid.grid_code, grid_gem_foi.feature_of_interest, retrieveddate_selection,air.avg_type, avg_period_param,
			 air.avg_avg, air.avg_aqi, air.avg_aqi_type, current_timestamp;
		END IF;	





	END LOOP;

/*
	-- rounded avg_pm_all_hr to 1 decimal in 5 steps (0.0, 0.2, 0.4, 0.6, 0.8)
	EXECUTE 'INSERT INTO grid_gem_cell_union (grid_gem_cell_gid, retrieveddate, 
				avg_type,
				avg_avg,
				creation_date, union_geom) 
				SELECT min(grid_gem_cell_gid), max(retrieveddate), avg.avg_type,
				  round(avg_avg,0),
				  current_timestamp,
				  ST_Union(cell.cell_geom)
				FROM grid_gem_cell_avg avg,
				grid_gem_cell cell
				WHERE retrieveddate = $1
				AND avg.grid_gem_cell_gid = cell.gid
				-- GROUP BY round(avg_pm_all_hr+MOD(((avg_pm_all_hr-round(avg_pm_all_hr))*10),2)/10,1)
				GROUP BY avg.avg_type, round(avg_avg,0) '
			USING retrieveddate_selection;
*/
	
	END IF;
 
    --RETURN void;
    
--	'INSERT INTO grid_gem_avg_tmp values(gm_code,cell_geom)
--		select grid.gm_code, grid.cell_centroid_geom from grid_gem grid
--		where grid.gm_code = '|| $1;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
   ;
ALTER FUNCTION public.get_aireas_aqi_area(gm_code CHARACTER VARYING(6), grid_code CHARACTER VARYING(15))
  OWNER TO postgres;
   
