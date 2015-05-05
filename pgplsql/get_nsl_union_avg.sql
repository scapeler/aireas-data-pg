-- USE/TEST: select get_nsl_union_avg('nsl_result_ehv2013','2012'); -- = tablename and rekenjaar
-- USE/TEST: select get_nsl_union_avg('nsl_result_ehv2014','2013'); -- = tablename and rekenjaar
-- select * from nsl_union_avg;
-- delete from nsl_union_avg where rekenjaar = '2013' ;
-- DROP FUNCTION get_nsl_union_avg(CHARACTER VARYING(50), CHARACTER VARYING(4))
CREATE OR REPLACE FUNCTION public.get_nsl_union_avg( nsl_table_name CHARACTER VARYING(50), rekenjaar CHARACTER VARYING(4) )
  RETURNS  void AS
$BODY$
DECLARE
  
BEGIN
	EXECUTE 'INSERT INTO nsl_union_avg (mronde, rekenjaar, spmi_avg, geom, creation_date) 
				SELECT max(nsl.mronde), $2, round( (  (nsl.conc_pm25+MOD(((nsl.conc_pm25-round(nsl.conc_pm25))*10),2)/10)*3 + (nsl.conc_pm10+MOD(((nsl.conc_pm10-round(nsl.conc_pm10))*10),2)/10) ) /4 ,0),
				  ST_Union( ST_GeomFromText(ST_AsText(     ST_Buffer(GEOGRAPHY(nsl.geom4326), 75)     ) ) ),
				  current_timestamp
				FROM ' || $1 || ' nsl
				WHERE nsl.rekenjaar = $2 
				AND nsl.conc_pm10 is not null 
				AND nsl.conc_pm25 is not null
				GROUP BY round( (  (nsl.conc_pm25+MOD(((nsl.conc_pm25-round(nsl.conc_pm25))*10),2)/10)*3 + (nsl.conc_pm10+MOD(((nsl.conc_pm10-round(nsl.conc_pm10))*10),2)/10) ) /4 ,0) '
			USING $1, $2 ;
	
	--END IF;
    
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
   ;
ALTER FUNCTION public.get_nsl_union_avg(nsl_table_name CHARACTER VARYING(50), rekenjaar CHARACTER VARYING(4) )
  OWNER TO postgres;
   
