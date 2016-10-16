-- DROP FUNCTION get_aireas_aqi(avg_type CHARACTER VARYING(60), retrieveddate TIMESTAMP WITH TIME ZONE, foi varchar(255), avg_period_param varchar(24), aqi_type varchar(24) )
-- test: select get_aireas_aqi('OZON',timestamp '2016-10-08 18:54:03.994+02','25.cal', '1hr', 'AiREAS_NL');
-- test: select get_aireas_aqi('OZON',timestamp '2016-10-08 18:54:03.994+02','25.cal', '1hr', 'AiREAS');
-- test: select get_aireas_aqi('UFP',timestamp '2016-10-08 18:54:03.994+02','11.cal', '1hr', 'AiREAS');

CREATE OR REPLACE FUNCTION public.get_aireas_aqi( avg_type CHARACTER VARYING(60), retrieveddate TIMESTAMP WITH TIME ZONE, foi varchar(255), avg_period_param varchar(24), aqi_type varchar(24) )
  RETURNS  record AS
$BODY$
DECLARE
  avg_period_param varchar;
  avg_period varchar;

  retrieveddata_start TIMESTAMP WITH TIME ZONE;
  stmt varchar    :=  '';
  stmt_p1 varchar :=  'SELECT CAST($1 as varchar(60)) AS avg_type, max(retrieveddate) AS retrieveddate, ';
  stmt_p2 varchar := '';
  stmt_p3 varchar := ', cast(null AS numeric ) avg_aqi, cast($5 AS varchar(60)) avg_aqi_type FROM aireas a1 
		WHERE 1=1 
		 AND a1.retrieveddate <= $2 
		 AND a1.retrieveddate >= $4 
		 AND a1.airbox = $3
		 AND exists (
		 	select 1 from grid_gem_cell_airbox cellair
			where 1=1 
			AND a1.airbox = cellair.airbox 
			AND ROUND(CAST(ST_Distance(GEOGRAPHY(a1.geom), GEOGRAPHY(cellair.airbox_geom)) AS NUMERIC), 5) < 40
			limit 1 
		 )';
  stmt_p4 varchar := '';
  air record;
  aqi_level record;
  aqi numeric;
  

  aqi_high_low record;
  
BEGIN
	
	
	CASE $4 
		WHEN '1hr'  THEN avg_period = '1 hours';
		ELSE  avg_period = '1 hours';
	END CASE;	
	retrieveddata_start := $2 - INTERVAL '1 hour'; --avg_period;
	
	CASE $1
		WHEN 'PM1'  THEN stmt_p2 := ' ROUND(CAST(AVG(pm1float) as numeric), 1) AS avg_avg ';
						 stmt_p4 := ' AND a1.pm1float > 0 ';
		WHEN 'PM25' THEN stmt_p2 := ' ROUND(CAST(AVG(pm25float) as numeric), 1) AS avg_avg ';
						 stmt_p4 := ' AND a1.pm25float > 0 ';
		WHEN 'PM10' THEN stmt_p2 := ' ROUND(CAST(AVG(pm10float) as numeric), 1) AS avg_avg ';
						 stmt_p4 := ' AND a1.pm10float > 0 ';
		WHEN 'UFP'  THEN stmt_p2 := ' ROUND(CAST(AVG(ufpfloat) as numeric), 1) AS avg_avg ';
						 stmt_p4 := ' AND a1.ufpfloat > 0 ';
		WHEN 'OZON' THEN stmt_p2 := ' ROUND(CAST(AVG(ozonfloat) as numeric), 1) AS avg_avg ';
						 stmt_p4 := ' AND a1.ozonfloat > 0 ';
		WHEN 'NO2' 	THEN stmt_p2 := ' ROUND(CAST(AVG(no2float) as numeric), 1) AS avg_avg ';
						 stmt_p4 := ' AND a1.no2float > 0 ';
		ELSE stmt_p2 := ' null AS avg_avg ';
			 stmt_p4 := ' AND 1=2 ';  --always no result when avg_type unknown
	END CASE;
		
	stmt :=  stmt_p1 || stmt_p2 || stmt_p3 || stmt_p4;
--	RAISE unique_violation USING MESSAGE = 'statement: '  || ' ' || stmt; --for debug purpose
--	RAISE unique_violation USING MESSAGE = 'param $4: '  || ' ' || avg_period; --for debug purpose
	
	EXECUTE stmt
		USING $1, $2, $3, retrieveddata_start, $5 
		INTO air;

	EXECUTE 'SELECT c_low, c_high, i_low, i_high FROM aireas_aqi_level WHERE aqi_type = $1 AND sensor_type = $2 AND $3 >= c_low AND $3 < c_high '
		USING $5, $1, air.avg_avg
		INTO aqi_level;   


/*
	IF ($5 = 'AiREAS_NL') THEN


	-- avg_aqi_type ='AiREAS_NL'
	CASE $1
		WHEN 'OZON'  THEN 
			WITH  temp (b, e, ab, ae) AS (VALUES (0,39,10,19), (40,99,51,100), (100,179,101,150), (180,239,151,200), (240,299,201,300), (300,550,301,500) ) 
			  SELECT * FROM temp where temp.b <= air.avg_avg and temp.e+1 > air.avg_avg INTO aqi_high_low;

			b  :=  aqi_high_low.b; 
			e  :=  aqi_high_low.e; 
			ab :=  aqi_high_low.ab; 
			ae :=  aqi_high_low.ae; 
		WHEN 'PM1'  THEN 
			WITH  temp (b, e, ab, ae) AS (VALUES (0,13,10,19), (14,33,51,100), (34,60,101,150), (61,94,151,200), (95,99,201,300), (100,130,301,500) ) 
			  SELECT * FROM temp where temp.b <= air.avg_avg and temp.e+1 > air.avg_avg INTO aqi_high_low;

			b  :=  aqi_high_low.b; 
			e  :=  aqi_high_low.e; 
			ab :=  aqi_high_low.ab; 
			ae :=  aqi_high_low.ae; 
		WHEN 'PM25'  THEN 
			WITH  temp (b, e, ab, ae) AS (VALUES (0,19,10,19), (20,49,51,100), (50,89,101,150), (90,139,151,200), (140,169,201,300), (170,300,301,500) ) 
			  SELECT * FROM temp where temp.b <= air.avg_avg and temp.e+1 > air.avg_avg INTO aqi_high_low;

			b  :=  aqi_high_low.b; 
			e  :=  aqi_high_low.e; 
			ab :=  aqi_high_low.ab; 
			ae :=  aqi_high_low.ae; 
		WHEN 'PM10'  THEN 
			WITH  temp (b, e, ab, ae) AS (VALUES (0,29,10,19), (30,74,51,100), (75,124,101,150), (125,199,151,200), (200,249,201,300), (250,450,301,500) ) 
			  SELECT * FROM temp where temp.b <= air.avg_avg and temp.e+1 > air.avg_avg INTO aqi_high_low;

			b  :=  aqi_high_low.b; 
			e  :=  aqi_high_low.e; 
			ab :=  aqi_high_low.ab; 
			ae :=  aqi_high_low.ae; 
		WHEN 'UFP'  THEN 
			WITH  temp (b, e, ab, ae) AS (VALUES (0,5,10,19), (6,14,51,100), (15,24,101,150), (25,39,151,200), (40,59,201,300), (60,140,301,500) ) 
			  SELECT * FROM temp where temp.b <= air.avg_avg and temp.e+1 > air.avg_avg INTO aqi_high_low;

			b  :=  aqi_high_low.b; 
			e  :=  aqi_high_low.e; 
			ab :=  aqi_high_low.ab; 
			ae :=  aqi_high_low.ae; 
		WHEN 'NO2'  THEN 
			WITH  temp (b, e, ab, ae) AS (VALUES (0,29,10,19), (30,74,51,100), (75,124,101,150), (125,199,151,200), (200,249,201,300), (250,450,301,500) ) 
			  SELECT * FROM temp where temp.b <= air.avg_avg and temp.e+1 > air.avg_avg INTO aqi_high_low;

			b  :=  aqi_high_low.b; 
			e  :=  aqi_high_low.e; 
			ab :=  aqi_high_low.ab; 
			ae :=  aqi_high_low.ae; 
		ELSE 	b  :=  null; 
			e  :=  null; 
			ab :=  null; 
			ae :=  null; 
	END CASE;		

	ELSE
	-- avg_aqi_type ='AiREAS'
	CASE $1
		WHEN 'OZON'  THEN 
			WITH  temp (b, e, ab, ae) AS (VALUES (0,39,0,50), (40,99,51,100), (100,179,101,150), (180,239,151,200), (240,299,201,300), (300,550,301,500) ) 
			  SELECT * FROM temp where temp.b <= air.avg_avg and temp.e+1 > air.avg_avg INTO aqi_high_low;

			b  :=  aqi_high_low.b; 
			e  :=  aqi_high_low.e; 
			ab :=  aqi_high_low.ab; 
			ae :=  aqi_high_low.ae; 
		WHEN 'PM1'  THEN 
			WITH  temp (b, e, ab, ae) AS (VALUES (0,13,0,50), (14,33,51,100), (34,60,101,150), (61,94,151,200), (95,99,201,300), (100,130,301,500) ) 
			  SELECT * FROM temp where temp.b <= air.avg_avg and temp.e+1 > air.avg_avg INTO aqi_high_low;

			b  :=  aqi_high_low.b; 
			e  :=  aqi_high_low.e; 
			ab :=  aqi_high_low.ab; 
			ae :=  aqi_high_low.ae; 
		WHEN 'PM25'  THEN 
			WITH  temp (b, e, ab, ae) AS (VALUES (0,19,0,50), (20,49,51,100), (50,89,101,150), (90,139,151,200), (140,169,201,300), (170,300,301,500) ) 
			  SELECT * FROM temp where temp.b <= air.avg_avg and temp.e+1 > air.avg_avg INTO aqi_high_low;

			b  :=  aqi_high_low.b; 
			e  :=  aqi_high_low.e; 
			ab :=  aqi_high_low.ab; 
			ae :=  aqi_high_low.ae; 
		WHEN 'PM10'  THEN 
			WITH  temp (b, e, ab, ae) AS (VALUES (0,29,0,50), (30,74,51,100), (75,124,101,150), (125,199,151,200), (200,249,201,300), (250,450,301,500) ) 
			  SELECT * FROM temp where temp.b <= air.avg_avg and temp.e+1 > air.avg_avg INTO aqi_high_low;

			b  :=  aqi_high_low.b; 
			e  :=  aqi_high_low.e; 
			ab :=  aqi_high_low.ab; 
			ae :=  aqi_high_low.ae; 
		WHEN 'UFP'  THEN 
			WITH  temp (b, e, ab, ae) AS (VALUES (0,5,0,50), (6,14,51,100), (15,24,101,150), (25,39,151,200), (40,59,201,300), (60,140,301,500) ) 
			  SELECT * FROM temp where temp.b <= air.avg_avg and temp.e+1 > air.avg_avg INTO aqi_high_low;

			b  :=  aqi_high_low.b; 
			e  :=  aqi_high_low.e; 
			ab :=  aqi_high_low.ab; 
			ae :=  aqi_high_low.ae; 
		WHEN 'NO2'  THEN 
			WITH  temp (b, e, ab, ae) AS (VALUES (0,29,0,50), (30,74,51,100), (75,124,101,150), (125,199,151,200), (200,249,201,300), (250,450,301,500) ) 
			  SELECT * FROM temp where temp.b <= air.avg_avg and temp.e+1 > air.avg_avg INTO aqi_high_low;

			b  :=  aqi_high_low.b; 
			e  :=  aqi_high_low.e; 
			ab :=  aqi_high_low.ab; 
			ae :=  aqi_high_low.ae; 
		ELSE 	b  :=  null; 
			e  :=  null; 
			ab :=  null; 
			ae :=  null; 
	END CASE;		

	END IF;
*/

--	air.avg_aqi := floor( ( (ae - ab) / (e-b) ) * (air.avg_avg - b) + ab);

	air.avg_aqi := floor( ( (aqi_level.i_high - 0.001 - aqi_level.i_low) / (aqi_level.c_high - 0.001 - aqi_level.c_low) ) * (air.avg_avg - aqi_level.c_low) + aqi_level.i_low);
9

--	RAISE unique_violation USING MESSAGE = 'air record: '  || ' ' || air.avg_type || air.avg_avg;  --for debug purpose

		

/*
	-- if no avg then try again in the next ring
	IF (air.retrieveddate = $2 AND air.avg_avg > 0) THEN
	ELSE
		EXECUTE stmt
		USING $1, $2, $3, 2000, 4000
		INTO air;
	END IF;
*/

	return air;
    
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
   ;
ALTER FUNCTION public.get_aireas_aqi(avg_type CHARACTER VARYING(60), retrieveddate TIMESTAMP WITH TIME ZONE, foi varchar(255), avg_period_param varchar(24), aqi_type varchar(24) )
  OWNER TO postgres;
   
