-- DROP FUNCTION get_grid_gem_cell_hist_avg_sub(avg_type CHARACTER VARYING(60), hist_year INTEGER, hist_month INTEGER, hist_day INTEGER, gid INTEGER )
-- test: select get_grid_gem_cell_hist_avg_sub('PM1','2014', null, null, 477);
CREATE OR REPLACE FUNCTION public.get_grid_gem_cell_hist_avg_sub( avg_type CHARACTER VARYING(60), hist_year INTEGER, hist_month INTEGER, hist_day INTEGER, gid INTEGER )
  RETURNS  record AS
$BODY$
DECLARE
  stmt varchar    :=  '';
  stmt_p1 varchar :=  'SELECT CAST($1 as varchar(60)) AS avg_type, cast(hist_year AS INTEGER), cast(hist_month AS INTEGER), cast(hist_day AS INTEGER), ';
  stmt_p2 varchar :=  '	ROUND(a1.avg_avg, 1) AS avg_avg ';
  stmt_p3 varchar :=  ' FROM aireas_hist_avg a1, grid_gem_cell_airbox cellair 
		WHERE 1=1 
         AND a1.avg_avg > 0 AND a1.avg_type = $1 
		 AND cellair.grid_gem_cell_gid = $5
		-- AND a1.hist_year = $2 
		-- AND a1.hist_month is null -- $3 
		-- AND a1.hist_day = $4 
		 AND a1.airbox = cellair.airbox
		 AND ROUND(CAST(ST_Distance(GEOGRAPHY(a1.geom), GEOGRAPHY(cellair.airbox_geom)) AS NUMERIC), 5) < 40
		 AND cellair.factor_distance >= $6 
		 AND cellair.factor_distance <= $7 ';
  stmt_p4 varchar := '';
  air record;
BEGIN
	stmt_p4 := ' AND a1.hist_year = $2 ';
	IF ($3 >= 1 AND $3 <= 12) THEN
		stmt_p4 := stmt_p4 || ' AND a1.hist_month = $3 ' ;
	ELSE
		stmt_p4 := stmt_p4 || ' AND a1.hist_month is null ' ;	
	END IF;
	IF ($4 >= 1 AND $4 <= 31) THEN
		stmt_p4 := stmt_p4 || ' AND a1.hist_day = $4 ' ;
	ELSE
		stmt_p4 := stmt_p4 || ' AND a1.hist_day is null ' ;	
	END IF;
		
/*
	CASE $1
		WHEN 'PM1'  THEN stmt_p2 := ' ROUND(CAST(AVG(pm1float) as numeric), 1) AS avg_avg ';
						 stmt_p4 := ' AND a1.pm1float > 0 ';
		WHEN 'PM25' THEN stmt_p2 := ' ROUND(CAST(AVG(pm25float) as numeric), 1) AS avg_avg ';
						 stmt_p4 := ' AND a1.pm25float > 0 ';
		WHEN 'PM10' THEN stmt_p2 := ' ROUND(CAST(AVG(pm10float) as numeric), 1) AS avg_avg ';
						 stmt_p4 := ' AND a1.pm10float > 0 ';
		WHEN 'SPMI' THEN stmt_p2 := ' ROUND(CAST((AVG(pm1float)*4+AVG(pm25float)*3+AVG(pm10float))/8 AS NUMERIC), 1) AS avg_avg ';
						 stmt_p4 := ' AND a1.pm1float > 0 ';
		WHEN 'UFP'  THEN stmt_p2 := ' ROUND(CAST(AVG(ufpfloat) as numeric), 1) AS avg_avg ';
						 stmt_p4 := ' AND a1.ufpfloat > 0 ';
		WHEN 'OZON' THEN stmt_p2 := ' ROUND(CAST(AVG(ozonfloat) as numeric), 1) AS avg_avg ';
						 stmt_p4 := ' AND a1.ozonfloat > 0 ';
		WHEN 'HUM'  THEN stmt_p2 := ' ROUND(CAST(AVG(humfloat) as numeric), 1) AS avg_avg ';
						 stmt_p4 := ' AND a1.humfloat > 0 ';
		WHEN 'CELC' THEN stmt_p2 := ' ROUND(CAST(AVG(celcfloat) as numeric), 1) AS avg_avg ';
						 stmt_p4 := ' AND a1.celcfloat > 0 ';
		WHEN 'NO2' 	THEN stmt_p2 := ' ROUND(CAST(AVG(no2float) as numeric), 1) AS avg_avg ';
						 stmt_p4 := ' AND a1.no2float > 0 ';
		ELSE stmt_p2 := ' null AS avg_avg ';
			 stmt_p4 := ' AND 1=2 ';  --always no result when avg_type unknown
	END CASE;
*/		
	stmt :=  stmt_p1 || stmt_p2 || stmt_p3 || stmt_p4;
--	RAISE unique_violation USING MESSAGE = 'statement: '  || ' ' || stmt; --for debug purpose
	
	EXECUTE stmt
		USING $1, $2, $3, $4, $5, 0, 500
		INTO air;
	--air.avg_type := 123456;	

--	RAISE unique_violation USING MESSAGE = 'air record: '  || ' ' || air.avg_type; --avg_type; -- air.avg_type;  --for debug purpose

		
	-- if no avg then try again in the next ring
	IF (air.avg_avg > 0) THEN
	ELSE
		EXECUTE stmt
		USING $1, $2, $3, $4, $5, 500, 1000
		INTO air;
	END IF;
		   
	-- if no avg then try again in the next ring
	IF (air.avg_avg > 0) THEN
	ELSE
		EXECUTE stmt
		USING $1, $2, $3, $4, $5, 1000, 1500
		INTO air;
	END IF;

	-- if no avg then try again in the next ring
	IF (air.avg_avg > 0) THEN
	ELSE
		EXECUTE stmt
		USING $1, $2, $3, $4, $5, 1500, 2000
		INTO air;
	END IF;

/*
	-- if no avg then try again in the next ring
	IF (air.avg_avg > 0) THEN
	ELSE
		EXECUTE stmt
		USING $1, $2, $3, $4, $5, 2000, 4000
		INTO air;
	END IF;
*/

	return air;
    
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
   ;
ALTER FUNCTION public.get_grid_gem_cell_hist_avg_sub(avg_type CHARACTER VARYING(60), hist_year INTEGER, hist_month INTEGER, hist_day INTEGER, gid INTEGER)
  OWNER TO postgres;
   
