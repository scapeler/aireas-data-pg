/*
 USE/TEST: 
 
 select * from get_cbs_buurt_from_point(5.47518775, 51.4897514333333);

 DROP FUNCTION get_cbs_buurt_from_point(lat double precision, lng double precision);
*/
CREATE OR REPLACE FUNCTION public.get_cbs_buurt_from_point(lat double precision, lng double precision)
  RETURNS table(gm_code varchar(10), gm_naam varchar(60), bu_code varchar(10), bu_naam varchar(60), geom4326 geometry(MultiPolygon,4326)) AS
$BODY$
DECLARE
  
  _lat double precision;
  _lng double precision;
  
  _buurt_rec record;
  
BEGIN
	_lat 	:= $1;
	_lng 	:= $2;
	
--RAISE unique_violation USING MESSAGE = 'retrieveddate: '  || ' ' || retrieveddate_selection; --for debug purpose
	
			
	RETURN QUERY SELECT bu.gm_code, bu.gm_naam, bu.bu_code, bu.bu_naam, bu.geom4326 
		FROM (select bu.gm_code, bu.gm_naam, bu.bu_code, bu.bu_naam, bu.geom4326
			from cbsbuurt2012 bu
			-- where bu.gm_code='GM0772'
			) bu
		WHERE ST_Intersects(ST_SetSRID(ST_MakePoint( _lat, _lng),4326), bu.geom4326);
		
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
   ;
ALTER FUNCTION public.get_cbs_buurt_from_point (lat double precision, lng double precision)
  OWNER TO postgres;   
