
todo convert into hist_avg

-- USE/TEST: select get_grid_gem_cell_avg_hr('GM0772', 'EHV20141104:1'); 
-- select * from grid_gem_cell_avg order by  grid_gem_cell_gid, retrieveddate;
-- select * from grid_gem_cell_union order by  grid_gem_cell_gid, retrieveddate;
-- delete from grid_gem_cell_avg; delete from grid_gem_cell_union;
-- DROP FUNCTION get_grid_gem_cell_avg_hr(CHARACTER VARYING(6), CHARACTER VARYING(15))
CREATE OR REPLACE FUNCTION public.get_grid_gem_cell_avg_main( gm_code CHARACTER VARYING(6), grid_code CHARACTER VARYING(15))
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
	
	
		EXECUTE 'SELECT avg_type,retrieveddate,avg_avg from get_grid_gem_cell_avg($1,$2,$3) AS (avg_type varchar(60), retrieveddate TIMESTAMP WITH TIME ZONE, avg_avg numeric )'
			USING 'PM1',retrieveddate_selection, grid_gem_cell.gid
			INTO air;
		IF (air.retrieveddate = retrieveddate_selection AND air.avg_avg > 0) THEN
			EXECUTE 'INSERT INTO grid_gem_cell_avg ( grid_gem_cell_gid, retrieveddate, avg_type, 
				avg_avg, creation_date) 
				VALUES ( 
				$1, $2, $3, $4, $5)'
			USING grid_gem_cell.gid, retrieveddate_selection,air.avg_type,
			 air.avg_avg, current_timestamp;
		END IF;	
			
		EXECUTE 'SELECT avg_type,retrieveddate,avg_avg from get_grid_gem_cell_avg($1,$2,$3) AS (avg_type varchar(60), retrieveddate TIMESTAMP WITH TIME ZONE, avg_avg numeric )'
			USING 'PM25',retrieveddate_selection, grid_gem_cell.gid
			INTO air;
		IF (air.retrieveddate = retrieveddate_selection AND air.avg_avg > 0) THEN
			EXECUTE 'INSERT INTO grid_gem_cell_avg ( grid_gem_cell_gid, retrieveddate, avg_type, 
				avg_avg, creation_date) 
				VALUES ( 
				$1, $2, $3, $4, $5)'
			USING grid_gem_cell.gid, retrieveddate_selection,air.avg_type,
			 air.avg_avg, current_timestamp;
		END IF;	

		EXECUTE 'SELECT avg_type,retrieveddate,avg_avg from get_grid_gem_cell_avg($1,$2,$3) AS (avg_type varchar(60), retrieveddate TIMESTAMP WITH TIME ZONE, avg_avg numeric )'
			USING 'PM10',retrieveddate_selection, grid_gem_cell.gid
			INTO air;
		IF (air.retrieveddate = retrieveddate_selection AND air.avg_avg > 0) THEN
			EXECUTE 'INSERT INTO grid_gem_cell_avg ( grid_gem_cell_gid, retrieveddate, avg_type, 
				avg_avg, creation_date) 
				VALUES ( 
				$1, $2, $3, $4, $5)'
			USING grid_gem_cell.gid, retrieveddate_selection,air.avg_type,
			 air.avg_avg, current_timestamp;
		END IF;	

		EXECUTE 'SELECT avg_type,retrieveddate,avg_avg from get_grid_gem_cell_avg($1,$2,$3) AS (avg_type varchar(60), retrieveddate TIMESTAMP WITH TIME ZONE, avg_avg numeric )'
			USING 'SPMI',retrieveddate_selection, grid_gem_cell.gid
			INTO air;
		IF (air.retrieveddate = retrieveddate_selection AND air.avg_avg > 0) THEN
			EXECUTE 'INSERT INTO grid_gem_cell_avg ( grid_gem_cell_gid, retrieveddate, avg_type, 
				avg_avg, creation_date) 
				VALUES ( 
				$1, $2, $3, $4, $5)'
			USING grid_gem_cell.gid, retrieveddate_selection,air.avg_type,
			 air.avg_avg, current_timestamp;
		END IF;	

		EXECUTE 'SELECT avg_type,retrieveddate,avg_avg from get_grid_gem_cell_avg($1,$2,$3) AS (avg_type varchar(60), retrieveddate TIMESTAMP WITH TIME ZONE, avg_avg numeric )'
			USING 'UFP',retrieveddate_selection, grid_gem_cell.gid
			INTO air;
		IF (air.retrieveddate = retrieveddate_selection AND air.avg_avg > 0) THEN
			EXECUTE 'INSERT INTO grid_gem_cell_avg ( grid_gem_cell_gid, retrieveddate, avg_type, 
				avg_avg, creation_date) 
				VALUES ( 
				$1, $2, $3, $4, $5)'
			USING grid_gem_cell.gid, retrieveddate_selection,air.avg_type,
			 air.avg_avg, current_timestamp;
		END IF;	

		EXECUTE 'SELECT avg_type,retrieveddate,avg_avg from get_grid_gem_cell_avg($1,$2,$3) AS (avg_type varchar(60), retrieveddate TIMESTAMP WITH TIME ZONE, avg_avg numeric )'
			USING 'OZON',retrieveddate_selection, grid_gem_cell.gid
			INTO air;
		IF (air.retrieveddate = retrieveddate_selection AND air.avg_avg > 0) THEN
			EXECUTE 'INSERT INTO grid_gem_cell_avg ( grid_gem_cell_gid, retrieveddate, avg_type, 
				avg_avg, creation_date) 
				VALUES ( 
				$1, $2, $3, $4, $5)'
			USING grid_gem_cell.gid, retrieveddate_selection,air.avg_type,
			 air.avg_avg, current_timestamp;
		END IF;	

		EXECUTE 'SELECT avg_type,retrieveddate,avg_avg from get_grid_gem_cell_avg($1,$2,$3) AS (avg_type varchar(60), retrieveddate TIMESTAMP WITH TIME ZONE, avg_avg numeric )'
			USING 'HUM',retrieveddate_selection, grid_gem_cell.gid
			INTO air;
		IF (air.retrieveddate = retrieveddate_selection AND air.avg_avg > 0) THEN
			EXECUTE 'INSERT INTO grid_gem_cell_avg ( grid_gem_cell_gid, retrieveddate, avg_type, 
				avg_avg, creation_date) 
				VALUES ( 
				$1, $2, $3, $4, $5)'
			USING grid_gem_cell.gid, retrieveddate_selection,air.avg_type,
			 air.avg_avg, current_timestamp;
		END IF;	

		EXECUTE 'SELECT avg_type,retrieveddate,avg_avg from get_grid_gem_cell_avg($1,$2,$3) AS (avg_type varchar(60), retrieveddate TIMESTAMP WITH TIME ZONE, avg_avg numeric )'
			USING 'CELC',retrieveddate_selection, grid_gem_cell.gid
			INTO air;
		IF (air.retrieveddate = retrieveddate_selection AND air.avg_avg > 0) THEN
			EXECUTE 'INSERT INTO grid_gem_cell_avg ( grid_gem_cell_gid, retrieveddate, avg_type, 
				avg_avg, creation_date) 
				VALUES ( 
				$1, $2, $3, $4, $5)'
			USING grid_gem_cell.gid, retrieveddate_selection,air.avg_type,
			 air.avg_avg, current_timestamp;
		END IF;	

		EXECUTE 'SELECT avg_type,retrieveddate,avg_avg from get_grid_gem_cell_avg($1,$2,$3) AS (avg_type varchar(60), retrieveddate TIMESTAMP WITH TIME ZONE, avg_avg numeric )'
			USING 'NO2',retrieveddate_selection, grid_gem_cell.gid
			INTO air;
		IF (air.retrieveddate = retrieveddate_selection AND air.avg_avg > 0) THEN
			EXECUTE 'INSERT INTO grid_gem_cell_avg ( grid_gem_cell_gid, retrieveddate, avg_type, 
				avg_avg, creation_date) 
				VALUES ( 
				$1, $2, $3, $4, $5)'
			USING grid_gem_cell.gid, retrieveddate_selection,air.avg_type,
			 air.avg_avg, current_timestamp;
		END IF;	



	END LOOP;


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
   
