-- USE/TEST: select get_grid_gem_cell_avg_hr('GM0772', 'EHV20141104:1'); 
-- select * from grid_gem_cell_avg order by  grid_gem_cell_gid, retrieveddate;
-- select * from grid_gem_cell_union order by  grid_gem_cell_gid, retrieveddate;
-- delete from grid_gem_cell_avg; delete from grid_gem_cell_union;
-- DROP FUNCTION get_grid_gem_cell_avg_hr(CHARACTER VARYING(6), CHARACTER VARYING(15))
CREATE OR REPLACE FUNCTION public.get_grid_gem_cell_avg_hr( gm_code CHARACTER VARYING(6), grid_code CHARACTER VARYING(15))
  RETURNS  void AS
$BODY$
DECLARE
  grid record;
  grid_gem_cell record;
  air record;
  retrieveddate_selection timestamp with time zone;
  retrieveddate_already_calculated timestamp with time zone;
BEGIN
	EXECUTE 'SELECT * FROM grid_gem WHERE gm_code = $1 AND grid_code = $2'
		USING $1, $2
		INTO grid;
	EXECUTE 'SELECT max(retrieveddate) from aireas' 
		INTO retrieveddate_selection;
	EXECUTE 'SELECT max(avg.retrieveddate) 
		from grid_gem_cell_avg avg,
		grid_gem_cell cell
		WHERE avg.grid_gem_cell_gid = cell.gid
		AND cell.grid_code = $1
		AND avg.retrieveddate = $2' 
		USING grid.grid_code, retrieveddate_selection
		INTO retrieveddate_already_calculated;
--RAISE unique_violation USING MESSAGE = 'retrieveddate: '  || ' ' || retrieveddate_selection; --for debug purpose
	IF (retrieveddate_already_calculated is null) THEN

	

	FOR grid_gem_cell IN EXECUTE 'SELECT * FROM grid_gem_cell WHERE grid_code = $1'
		USING grid.grid_code
	LOOP
		EXECUTE 'SELECT max(retrieveddate) retrieveddate, 
		ROUND(CAST(AVG(pm1float) as numeric), 1) AS avg_pm1_hr,
		ROUND(CAST(AVG(pm25float) as numeric), 1) AS avg_pm25_hr,
		ROUND(CAST(AVG(pm10float) as numeric), 1) AS avg_pm10_hr,
		ROUND(CAST((AVG(pm1float)*4+AVG(pm25float)*3+AVG(pm10float))/8 AS NUMERIC), 1) AS avg_pm_all_hr
		FROM aireas a1
		, grid_gem_cell_airbox cellair 
		WHERE 1=1 
		 AND cellair.grid_gem_cell_gid = $2
		 AND a1.retrieveddate <= $1 
		 AND a1.retrieveddate >= current_timestamp - INTERVAL ''1 hour'' 
		 AND a1.airbox = cellair.airbox
		 AND ROUND(CAST(ST_Distance(GEOGRAPHY(a1.geom), GEOGRAPHY(cellair.airbox_geom)) AS NUMERIC), 5) < 30
		 AND cellair.factor_distance < 250'
		USING retrieveddate_selection, grid_gem_cell.gid
		INTO air;

		-- if no avg then try again in the next ring
		if (air.retrieveddate = retrieveddate_selection AND air.avg_pm_all_hr > 0) THEN
		ELSE
		EXECUTE 'SELECT max(retrieveddate) retrieveddate, 
		ROUND(CAST(AVG(pm1float) as numeric), 1) AS avg_pm1_hr,
		ROUND(CAST(AVG(pm25float) as numeric), 1) AS avg_pm25_hr,
		ROUND(CAST(AVG(pm10float) as numeric), 1) AS avg_pm10_hr,
		ROUND(CAST((AVG(pm1float)*4+AVG(pm25float)*3+AVG(pm10float))/8 AS NUMERIC), 1) AS avg_pm_all_hr
		FROM aireas a1
		, grid_gem_cell_airbox cellair 
		WHERE 1=1 
		 AND cellair.grid_gem_cell_gid = $2
		 AND a1.retrieveddate <= $1 
		 AND a1.retrieveddate >= current_timestamp - INTERVAL ''1 hour'' 
		 AND a1.airbox = cellair.airbox
		 AND ROUND(CAST(ST_Distance(GEOGRAPHY(a1.geom), GEOGRAPHY(cellair.airbox_geom)) AS NUMERIC), 5) < 30
		 AND (cellair.factor_distance >= 250 and cellair.factor_distance < 500 ) '
		USING retrieveddate_selection, grid_gem_cell.gid
		INTO air;
		END IF;

		-- if no avg then try again in the next ring
		if (air.retrieveddate = retrieveddate_selection AND air.avg_pm_all_hr > 0) THEN
		ELSE
		EXECUTE 'SELECT max(retrieveddate) retrieveddate, 
		ROUND(CAST(AVG(pm1float) as numeric), 1) AS avg_pm1_hr,
		ROUND(CAST(AVG(pm25float) as numeric), 1) AS avg_pm25_hr,
		ROUND(CAST(AVG(pm10float) as numeric), 1) AS avg_pm10_hr,
		ROUND(CAST((AVG(pm1float)*4+AVG(pm25float)*3+AVG(pm10float))/8 AS NUMERIC), 1) AS avg_pm_all_hr
		FROM aireas a1
		, grid_gem_cell_airbox cellair 
		WHERE 1=1 
		 AND cellair.grid_gem_cell_gid = $2
		 AND a1.retrieveddate <= $1 
		 AND a1.retrieveddate >= current_timestamp - INTERVAL ''1 hour'' 
		 AND a1.airbox = cellair.airbox
		 AND ROUND(CAST(ST_Distance(GEOGRAPHY(a1.geom), GEOGRAPHY(cellair.airbox_geom)) AS NUMERIC), 5) < 30
		 AND (cellair.factor_distance >= 500 and cellair.factor_distance < 1000 ) '
		USING retrieveddate_selection, grid_gem_cell.gid
		INTO air;
		END IF;

		-- if no avg then try again in the next ring
		if (air.retrieveddate = retrieveddate_selection AND air.avg_pm_all_hr > 0) THEN
		ELSE
		EXECUTE 'SELECT max(retrieveddate) retrieveddate, 
		ROUND(CAST(AVG(pm1float) as numeric), 1) AS avg_pm1_hr,
		ROUND(CAST(AVG(pm25float) as numeric), 1) AS avg_pm25_hr,
		ROUND(CAST(AVG(pm10float) as numeric), 1) AS avg_pm10_hr,
		ROUND(CAST((AVG(pm1float)*4+AVG(pm25float)*3+AVG(pm10float))/8 AS NUMERIC), 1) AS avg_pm_all_hr
		FROM aireas a1
		, grid_gem_cell_airbox cellair 
		WHERE 1=1 
		 AND cellair.grid_gem_cell_gid = $2
		 AND a1.retrieveddate <= $1 
		 AND a1.retrieveddate >= current_timestamp - INTERVAL ''1 hour'' 
		 AND a1.airbox = cellair.airbox
		 AND ROUND(CAST(ST_Distance(GEOGRAPHY(a1.geom), GEOGRAPHY(cellair.airbox_geom)) AS NUMERIC), 5) < 30
		 AND (cellair.factor_distance >= 1000 and cellair.factor_distance < 1500 ) '
		USING retrieveddate_selection, grid_gem_cell.gid
		INTO air;
		END IF;

		-- if no avg then try again in the next ring
		if (air.retrieveddate = retrieveddate_selection AND air.avg_pm_all_hr > 0) THEN
		ELSE
		EXECUTE 'SELECT max(retrieveddate) retrieveddate, 
		ROUND(CAST(AVG(pm1float) as numeric), 1) AS avg_pm1_hr,
		ROUND(CAST(AVG(pm25float) as numeric), 1) AS avg_pm25_hr,
		ROUND(CAST(AVG(pm10float) as numeric), 1) AS avg_pm10_hr,
		ROUND(CAST((AVG(pm1float)*4+AVG(pm25float)*3+AVG(pm10float))/8 AS NUMERIC), 1) AS avg_pm_all_hr
		FROM aireas a1
		, grid_gem_cell_airbox cellair 
		WHERE 1=1 
		 AND cellair.grid_gem_cell_gid = $2
		 AND a1.retrieveddate <= $1 
		 AND a1.retrieveddate >= current_timestamp - INTERVAL ''1 hour'' 
		 AND a1.airbox = cellair.airbox
		 AND ROUND(CAST(ST_Distance(GEOGRAPHY(a1.geom), GEOGRAPHY(cellair.airbox_geom)) AS NUMERIC), 5) < 30
		 AND (cellair.factor_distance >= 1500 and cellair.factor_distance < 2000 ) '
		USING retrieveddate_selection, grid_gem_cell.gid
		INTO air;
		END IF;

		-- if no avg then try again in the next ring
		if (air.retrieveddate = retrieveddate_selection AND air.avg_pm_all_hr > 0) THEN
		ELSE
		EXECUTE 'SELECT max(retrieveddate) retrieveddate, 
		ROUND(CAST(AVG(pm1float) as numeric), 1) AS avg_pm1_hr,
		ROUND(CAST(AVG(pm25float) as numeric), 1) AS avg_pm25_hr,
		ROUND(CAST(AVG(pm10float) as numeric), 1) AS avg_pm10_hr,
		ROUND(CAST((AVG(pm1float)*4+AVG(pm25float)*3+AVG(pm10float))/8 AS NUMERIC), 1) AS avg_pm_all_hr
		FROM aireas a1
		, grid_gem_cell_airbox cellair 
		WHERE 1=1 
		 AND cellair.grid_gem_cell_gid = $2
		 AND a1.retrieveddate <= $1 
		 AND a1.retrieveddate >= current_timestamp - INTERVAL ''1 hour'' 
		 AND a1.airbox = cellair.airbox
		 AND ROUND(CAST(ST_Distance(GEOGRAPHY(a1.geom), GEOGRAPHY(cellair.airbox_geom)) AS NUMERIC), 5) < 30
		 AND (cellair.factor_distance >= 2000 and cellair.factor_distance < 4000 ) '
		USING retrieveddate_selection, grid_gem_cell.gid
		INTO air;
		END IF;


		IF (air.retrieveddate = retrieveddate_selection AND air.avg_pm_all_hr > 0) THEN
			EXECUTE 'INSERT INTO grid_gem_cell_avg (grid_gem_cell_gid, retrieveddate, 
				avg_pm1_hr, avg_pm25_hr, avg_pm10_hr, avg_pm_all_hr, creation_date) VALUES ( 
				$1, $2, $3, $4, $5, $6, $7)'
			USING grid_gem_cell.gid, retrieveddate_selection,
			 air.avg_pm1_hr, air.avg_pm25_hr, air.avg_pm10_hr, air.avg_pm_all_hr,
			 current_timestamp;
		END IF;

	END LOOP;

	-- rounded avg_pm_all_hr to 1 decimal in 5 steps (0.0, 0.2, 0.4, 0.6, 0.8)
	EXECUTE 'INSERT INTO grid_gem_cell_union (grid_gem_cell_gid, retrieveddate, 
				avg_pm1_hr, avg_pm25_hr, avg_pm10_hr, avg_pm_all_hr, creation_date, union_geom) 
				SELECT min(grid_gem_cell_gid), max(retrieveddate), 
				  max(avg_pm1_hr), max(avg_pm25_hr), max(avg_pm10_hr),
				  --round(avg_pm_all_hr+MOD(((avg_pm_all_hr-round(avg_pm_all_hr))*10),2)/10,1),
				  round(avg_pm_all_hr,0),
				  current_timestamp,
				  ST_Union(cell.cell_geom)
				FROM grid_gem_cell_avg avg,
				grid_gem_cell cell
				WHERE retrieveddate = $1
				AND avg.grid_gem_cell_gid = cell.gid
				-- GROUP BY round(avg_pm_all_hr+MOD(((avg_pm_all_hr-round(avg_pm_all_hr))*10),2)/10,1)
				GROUP BY round(avg_pm_all_hr,0) '
			USING retrieveddate_selection;
	
	END IF;
 
    --RETURN void;
    
--	'INSERT INTO grid_gem_avg_tmp values(gm_code,cell_geom)
--		select grid.gm_code, grid.cell_centroid_geom from grid_gem grid
--		where grid.gm_code = '|| $1;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
   ;
ALTER FUNCTION public.get_grid_gem_cell_avg_hr(gm_code CHARACTER VARYING(6), grid_code CHARACTER VARYING(15))
  OWNER TO postgres;
   
