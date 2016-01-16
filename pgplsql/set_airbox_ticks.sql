/*
select set_airbox_ticks('1','2015');
select set_airbox_ticks('2','2015');
select set_airbox_ticks('3','2015');
select set_airbox_ticks('4','2015');
select set_airbox_ticks('5','2015');
select set_airbox_ticks('6','2015');
select set_airbox_ticks('7','2015');
select set_airbox_ticks('8','2015');
select set_airbox_ticks('9','2015');
select set_airbox_ticks('10','2015'); commit;
select set_airbox_ticks('11','2015');
select set_airbox_ticks('12','2015');
select set_airbox_ticks('13','2015');
select set_airbox_ticks('14','2015');
select set_airbox_ticks('15','2015');
select set_airbox_ticks('16','2015');
select set_airbox_ticks('17','2015');
select set_airbox_ticks('18','2015');
select set_airbox_ticks('19','2015');
select set_airbox_ticks('20','2015'); commit;
select set_airbox_ticks('21','2015');
select set_airbox_ticks('22','2015');
select set_airbox_ticks('23','2015');
select set_airbox_ticks('24','2015');
select set_airbox_ticks('25','2015');
select set_airbox_ticks('26','2015');
select set_airbox_ticks('27','2015');
select set_airbox_ticks('28','2015');
select set_airbox_ticks('29','2015');
select set_airbox_ticks('30','2015'); commit;
select set_airbox_ticks('31','2015');
select set_airbox_ticks('32','2015');
select set_airbox_ticks('33','2015');
select set_airbox_ticks('34','2015');
select set_airbox_ticks('35','2015');
select set_airbox_ticks('36','2015');
select set_airbox_ticks('37','2015');
select set_airbox_ticks('38','2015');
select set_airbox_ticks('39','2015');
select set_airbox_ticks('40','2015'); commit;

*/
-- DROP FUNCTION set_airbox_ticks(airbox varchar, year char(4) )
-- test: select set_airbox_ticks('1','2015');
CREATE OR REPLACE FUNCTION public.set_airbox_ticks( airbox varchar, year character(4) ) RETURNS void AS $BODY$
DECLARE
  tmp_tick_start  TIMESTAMP WITH TIME ZONE; 
  tmp_tick_end  TIMESTAMP WITH TIME ZONE; 
BEGIN
	tmp_tick_start := $2||'0101T00:00:00Z';
	tmp_tick_end := $2||'1231T24:00:00Z';

	WHILE tmp_tick_start <= tmp_tick_end LOOP
		EXECUTE 'INSERT INTO aireas_ticks (airbox, tickdate)  VALUES ($1,$2);'
		USING $1, tmp_tick_start; 
		tmp_tick_start := tmp_tick_start + time '00:10';
	END LOOP;
	
--	RAISE unique_violation USING MESSAGE = 'tmp_tick_start: '  || ' ' || tmp_tick_start || ' tmp_tick_end: '  || ' ' || tmp_tick_end;  --for debug purpose

	return ;
    
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
   ;
ALTER FUNCTION public.set_airbox_ticks(airbox CHARACTER VARYING(255), year character(4))
  OWNER TO postgres;
   
