-- DROP FUNCTION get_grid_gem_cell_avg(avg_type CHARACTER VARYING(60), retrieveddate TIMESTAMP WITH TIME ZONE, gid INTEGER )
-- test: select get_grid_gem_cell_avg('SPMI','2015-05-05 22:54:03.994+02',125);
CREATE OR REPLACE FUNCTION public.get_grid_gem_cell_avg( avg_type CHARACTER VARYING(60), retrieveddate TIMESTAMP WITH TIME ZONE, gid INTEGER )
  RETURNS  record AS
$BODY$
DECLARE
  stmt varchar    :=  '';
  stmt_p1 varchar :=  'SELECT CAST($1 as varchar(60)) AS avg_type, max(retrieveddate) AS retrieveddate, ';
  stmt_p2 varchar := '';
  stmt_p3 varchar := ' FROM aireas a1, grid_gem_cell_airbox cellair 
		WHERE 1=1 
		 AND cellair.grid_gem_cell_gid = $3
		 AND a1.retrieveddate <= $2 
		 AND a1.retrieveddate >= current_timestamp - INTERVAL ''00:30:00'' 
		 AND a1.airbox = cellair.airbox
		 AND ROUND(CAST(ST_Distance(GEOGRAPHY(a1.geom), GEOGRAPHY(cellair.airbox_geom)) AS NUMERIC), 5) < 30
		 AND cellair.factor_distance >= $4 
		 AND cellair.factor_distance <= $5 ';
  stmt_p4 varchar := '';
  air record;
BEGIN
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
		
	stmt :=  stmt_p1 || stmt_p2 || stmt_p3 || stmt_p4;
--	RAISE unique_violation USING MESSAGE = 'statement: '  || ' ' || stmt; --for debug purpose
	
	EXECUTE stmt
		USING $1, $2, $3, 0, 500
		INTO air;
	--air.avg_type := 123456;	

--	RAISE unique_violation USING MESSAGE = 'air record: '  || ' ' || air.avg_type; --avg_type; -- air.avg_type;  --for debug purpose

		
	-- if no avg then try again in the next ring
	IF (air.retrieveddate = $2 AND air.avg_avg > 0) THEN
	ELSE
		EXECUTE stmt
		USING $1, $2, $3, 500, 1000
		INTO air;
	END IF;
		   
	-- if no avg then try again in the next ring
	IF (air.retrieveddate = $2 AND air.avg_avg > 0) THEN
	ELSE
		EXECUTE stmt
		USING $1, $2, $3, 1000, 1500
		INTO air;
	END IF;

	-- if no avg then try again in the next ring
	IF (air.retrieveddate = $2 AND air.avg_avg > 0) THEN
	ELSE
		EXECUTE stmt
		USING $1, $2, $3, 1500, 2000
		INTO air;
	END IF;

	-- if no avg then try again in the next ring
	IF (air.retrieveddate = $2 AND air.avg_avg > 0) THEN
	ELSE
		EXECUTE stmt
		USING $1, $2, $3, 2000, 4000
		INTO air;
	END IF;


	return air;
    
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
   ;
ALTER FUNCTION public.get_grid_gem_cell_avg(avg_type CHARACTER VARYING(60), retrieveddate TIMESTAMP WITH TIME ZONE, gid INTEGER)
  OWNER TO postgres;
   
