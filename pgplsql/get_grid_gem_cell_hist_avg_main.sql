
-- USE/TEST: select get_grid_gem_cell_hist_avg_main('GM0772', 'EHV20141104:1',2014,null,null); 
-- select * from grid_gem_cell_hist_avg order by  grid_gem_cell_gid, hist_year, hist_month, hist_day; 
-- select * from grid_gem_cell_hist_union order by  grid_gem_cell_gid, hist_year, hist_month, hist_day; 
-- delete from grid_gem_cell_hist_avg; delete from grid_gem_cell_hist_union;
-- DROP FUNCTION get_grid_gem_cell_hist_avg_main(CHARACTER VARYING(6), CHARACTER VARYING(15), hist_year INTEGER, hist_month INTEGER, hist_day INTEGER)
CREATE OR REPLACE FUNCTION public.get_grid_gem_cell_hist_avg_main( gm_code CHARACTER VARYING(6), grid_code CHARACTER VARYING(15), hist_year INTEGER, hist_month INTEGER, hist_day INTEGER)
  RETURNS  void AS
$BODY$
DECLARE
  grid record;
  grid_gem_cell record;
  air record;
  hist_year INTEGER;
  hist_month INTEGER;
  hist_day INTEGER;
  stmt_p4 varchar := '';
--  retrieveddate_selection timestamp with time zone; 
--  retrieveddate_already_calculated timestamp with time zone; 
BEGIN
	hist_year := $3;
	hist_month := $4;
	hist_day := $5;
	
	stmt_p4 := ' AND hist_year = $1 ';
	IF (hist_month >= 1 AND hist_month <= 12) THEN
		stmt_p4 := stmt_p4 || ' AND avg.hist_month = $2 ' ;
	ELSE
		stmt_p4 := stmt_p4 || ' AND avg.hist_month is null ' ;	
	END IF;
	IF (hist_day >= 1 AND hist_day <= 31) THEN
		stmt_p4 := stmt_p4 || ' AND avg.hist_day = $3 ' ;
	ELSE
		stmt_p4 := stmt_p4 || ' AND avg.hist_day is null ' ;	
	END IF;

	
	EXECUTE 'SELECT * FROM grid_gem WHERE gm_code = $1 AND grid_code = $2'
		USING $1, $2
		INTO grid;
--	EXECUTE 'SELECT max(retrieveddate) from aireas_hist' 
--		INTO retrieveddate_selection; 
--	EXECUTE 'SELECT max(avg.retrieveddate) 
--		from grid_gem_cell_hist_avg avg,
--		grid_gem_cell cell
--		WHERE avg.grid_gem_cell_gid = cell.gid
--		AND cell.grid_code = $1
--		AND avg.retrieveddate = $2' 
--		USING grid.grid_code, retrieveddate_selection 
--		INTO retrieveddate_already_calculated; 
--RAISE unique_violation USING MESSAGE = 'retrieveddate: '  || ' ' || retrieveddate_selection; --for debug purpose
--	IF (retrieveddate_already_calculated is null) THEN  

	

	FOR grid_gem_cell IN EXECUTE 'SELECT * FROM grid_gem_cell WHERE grid_code = $1'
		USING grid.grid_code
	LOOP
	

		EXECUTE 'SELECT avg_type,cast(hist_year as INTEGER),cast(hist_month as INTEGER),cast(hist_day as INTEGER),avg_avg from get_grid_gem_cell_hist_avg_sub($1,$2,$3,$4,$5) AS (avg_type varchar(60), hist_year INTEGER, hist_month INTEGER, hist_day INTEGER, avg_avg numeric )'
			USING 'PM1',hist_year,hist_month, hist_day, grid_gem_cell.gid
			INTO air;
		IF (air.hist_year = hist_year AND air.avg_avg > 0) THEN
			EXECUTE 'INSERT INTO grid_gem_cell_hist_avg ( grid_gem_cell_gid, hist_year, hist_month, hist_day, avg_type, 
				avg_avg, creation_date) 
				VALUES ( 
				$1, $2, $3, $4, $5, $6, $7)'
			USING grid_gem_cell.gid, hist_year, hist_month, hist_day, air.avg_type,
			 air.avg_avg, current_timestamp;
		END IF;	

		EXECUTE 'SELECT avg_type,cast(hist_year as INTEGER),cast(hist_month as INTEGER),cast(hist_day as INTEGER),avg_avg from get_grid_gem_cell_hist_avg_sub($1,$2,$3,$4,$5) AS (avg_type varchar(60), hist_year INTEGER, hist_month INTEGER, hist_day INTEGER, avg_avg numeric )'
			USING 'PM25',hist_year,hist_month, hist_day, grid_gem_cell.gid
			INTO air;
		IF (air.hist_year = hist_year AND air.avg_avg > 0) THEN
			EXECUTE 'INSERT INTO grid_gem_cell_hist_avg ( grid_gem_cell_gid, hist_year, hist_month, hist_day, avg_type, 
				avg_avg, creation_date) 
				VALUES ( 
				$1, $2, $3, $4, $5, $6, $7)'
			USING grid_gem_cell.gid, hist_year, hist_month, hist_day, air.avg_type,
			 air.avg_avg, current_timestamp;
		END IF;	

		EXECUTE 'SELECT avg_type,cast(hist_year as INTEGER),cast(hist_month as INTEGER),cast(hist_day as INTEGER),avg_avg from get_grid_gem_cell_hist_avg_sub($1,$2,$3,$4,$5) AS (avg_type varchar(60), hist_year INTEGER, hist_month INTEGER, hist_day INTEGER, avg_avg numeric )'
			USING 'PM10',hist_year,hist_month, hist_day, grid_gem_cell.gid
			INTO air;
		IF (air.hist_year = hist_year AND air.avg_avg > 0) THEN
			EXECUTE 'INSERT INTO grid_gem_cell_hist_avg ( grid_gem_cell_gid, hist_year, hist_month, hist_day, avg_type, 
				avg_avg, creation_date) 
				VALUES ( 
				$1, $2, $3, $4, $5, $6, $7)'
			USING grid_gem_cell.gid, hist_year, hist_month, hist_day, air.avg_type,
			 air.avg_avg, current_timestamp;
		END IF;	

		EXECUTE 'SELECT avg_type,cast(hist_year as INTEGER),cast(hist_month as INTEGER),cast(hist_day as INTEGER),avg_avg from get_grid_gem_cell_hist_avg_sub($1,$2,$3,$4,$5) AS (avg_type varchar(60), hist_year INTEGER, hist_month INTEGER, hist_day INTEGER, avg_avg numeric )'
			USING 'SPMI',hist_year,hist_month, hist_day, grid_gem_cell.gid
			INTO air;
		IF (air.hist_year = hist_year AND air.avg_avg > 0) THEN
			EXECUTE 'INSERT INTO grid_gem_cell_hist_avg ( grid_gem_cell_gid, hist_year, hist_month, hist_day, avg_type, 
				avg_avg, creation_date) 
				VALUES ( 
				$1, $2, $3, $4, $5, $6, $7)'
			USING grid_gem_cell.gid, hist_year, hist_month, hist_day, air.avg_type,
			 air.avg_avg, current_timestamp;
		END IF;	

		EXECUTE 'SELECT avg_type,cast(hist_year as INTEGER),cast(hist_month as INTEGER),cast(hist_day as INTEGER),avg_avg from get_grid_gem_cell_hist_avg_sub($1,$2,$3,$4,$5) AS (avg_type varchar(60), hist_year INTEGER, hist_month INTEGER, hist_day INTEGER, avg_avg numeric )'
			USING 'UFP',hist_year,hist_month, hist_day, grid_gem_cell.gid
			INTO air;
		IF (air.hist_year = hist_year AND air.avg_avg > 0) THEN
			EXECUTE 'INSERT INTO grid_gem_cell_hist_avg ( grid_gem_cell_gid, hist_year, hist_month, hist_day, avg_type, 
				avg_avg, creation_date) 
				VALUES ( 
				$1, $2, $3, $4, $5, $6, $7)'
			USING grid_gem_cell.gid, hist_year, hist_month, hist_day, air.avg_type,
			 air.avg_avg, current_timestamp;
		END IF;	

		EXECUTE 'SELECT avg_type,cast(hist_year as INTEGER),cast(hist_month as INTEGER),cast(hist_day as INTEGER),avg_avg from get_grid_gem_cell_hist_avg_sub($1,$2,$3,$4,$5) AS (avg_type varchar(60), hist_year INTEGER, hist_month INTEGER, hist_day INTEGER, avg_avg numeric )'
			USING 'OZON',hist_year,hist_month, hist_day, grid_gem_cell.gid
			INTO air;
		IF (air.hist_year = hist_year AND air.avg_avg > 0) THEN
			EXECUTE 'INSERT INTO grid_gem_cell_hist_avg ( grid_gem_cell_gid, hist_year, hist_month, hist_day, avg_type, 
				avg_avg, creation_date) 
				VALUES ( 
				$1, $2, $3, $4, $5, $6, $7)'
			USING grid_gem_cell.gid, hist_year, hist_month, hist_day, air.avg_type,
			 air.avg_avg, current_timestamp;
		END IF;	

		EXECUTE 'SELECT avg_type,cast(hist_year as INTEGER),cast(hist_month as INTEGER),cast(hist_day as INTEGER),avg_avg from get_grid_gem_cell_hist_avg_sub($1,$2,$3,$4,$5) AS (avg_type varchar(60), hist_year INTEGER, hist_month INTEGER, hist_day INTEGER, avg_avg numeric )'
			USING 'HUM',hist_year,hist_month, hist_day, grid_gem_cell.gid
			INTO air;
		IF (air.hist_year = hist_year AND air.avg_avg > 0) THEN
			EXECUTE 'INSERT INTO grid_gem_cell_hist_avg ( grid_gem_cell_gid, hist_year, hist_month, hist_day, avg_type, 
				avg_avg, creation_date) 
				VALUES ( 
				$1, $2, $3, $4, $5, $6, $7)'
			USING grid_gem_cell.gid, hist_year, hist_month, hist_day, air.avg_type,
			 air.avg_avg, current_timestamp;
		END IF;	

		EXECUTE 'SELECT avg_type,cast(hist_year as INTEGER),cast(hist_month as INTEGER),cast(hist_day as INTEGER),avg_avg from get_grid_gem_cell_hist_avg_sub($1,$2,$3,$4,$5) AS (avg_type varchar(60), hist_year INTEGER, hist_month INTEGER, hist_day INTEGER, avg_avg numeric )'
			USING 'CELC',hist_year,hist_month, hist_day, grid_gem_cell.gid
			INTO air;
		IF (air.hist_year = hist_year AND air.avg_avg > 0) THEN
			EXECUTE 'INSERT INTO grid_gem_cell_hist_avg ( grid_gem_cell_gid, hist_year, hist_month, hist_day, avg_type, 
				avg_avg, creation_date) 
				VALUES ( 
				$1, $2, $3, $4, $5, $6, $7)'
			USING grid_gem_cell.gid, hist_year, hist_month, hist_day, air.avg_type,
			 air.avg_avg, current_timestamp;
		END IF;	

		EXECUTE 'SELECT avg_type,cast(hist_year as INTEGER),cast(hist_month as INTEGER),cast(hist_day as INTEGER),avg_avg from get_grid_gem_cell_hist_avg_sub($1,$2,$3,$4,$5) AS (avg_type varchar(60), hist_year INTEGER, hist_month INTEGER, hist_day INTEGER, avg_avg numeric )'
			USING 'NO2',hist_year,hist_month, hist_day, grid_gem_cell.gid
			INTO air;
		IF (air.hist_year = hist_year AND air.avg_avg > 0) THEN
			EXECUTE 'INSERT INTO grid_gem_cell_hist_avg ( grid_gem_cell_gid, hist_year, hist_month, hist_day, avg_type, 
				avg_avg, creation_date) 
				VALUES ( 
				$1, $2, $3, $4, $5, $6, $7)'
			USING grid_gem_cell.gid, hist_year, hist_month, hist_day, air.avg_type,
			 air.avg_avg, current_timestamp;
		END IF;	


	END LOOP;


	-- rounded avg_pm_all_hr to 1 decimal in 5 steps (0.0, 0.2, 0.4, 0.6, 0.8)
	EXECUTE 'INSERT INTO grid_gem_cell_hist_union (grid_gem_cell_gid, hist_year, hist_month, hist_day, 
				avg_type,
				avg_avg,
				creation_date, union_geom) 
				SELECT min(grid_gem_cell_gid), max(hist_year), max(hist_month), max(hist_day), avg.avg_type,
				  round(avg_avg,0),
				  current_timestamp,
				  ST_Union(cell.cell_geom)
				FROM grid_gem_cell_hist_avg avg,
				grid_gem_cell cell
				WHERE 1=1 ' || stmt_p4 ||
				' AND avg.grid_gem_cell_gid = cell.gid
				-- GROUP BY round(avg_pm_all_hr+MOD(((avg_pm_all_hr-round(avg_pm_all_hr))*10),2)/10,1)
				GROUP BY avg.avg_type, round(avg_avg,0) '
			USING hist_year, hist_month, hist_day;

	
--	END IF;
 
    --RETURN void;
    
--	'INSERT INTO grid_gem_avg_tmp values(gm_code,cell_geom)
--		select grid.gm_code, grid.cell_centroid_geom from grid_gem grid
--		where grid.gm_code = '|| $1;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
   ;
ALTER FUNCTION public.get_grid_gem_cell_hist_avg_main(gm_code CHARACTER VARYING(6), grid_code CHARACTER VARYING(15), hist_year INTEGER, hist_month INTEGER, hist_day INTEGER)
  OWNER TO postgres;   
