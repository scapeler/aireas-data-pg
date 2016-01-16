/*

delete from aireas_airbox_sensor_tick_flags;

select set_airbox_tick_flags('1','2015');
select set_airbox_tick_flags('2','2015');
select set_airbox_tick_flags('3','2015');
select set_airbox_tick_flags('4','2015');
select set_airbox_tick_flags('5','2015');
select set_airbox_tick_flags('6','2015');
select set_airbox_tick_flags('7','2015');
select set_airbox_tick_flags('8','2015');
select set_airbox_tick_flags('9','2015');
select set_airbox_tick_flags('10','2015');
select set_airbox_tick_flags('11','2015');
select set_airbox_tick_flags('12','2015');
select set_airbox_tick_flags('13','2015');
select set_airbox_tick_flags('14','2015');
select set_airbox_tick_flags('15','2015');
select set_airbox_tick_flags('16','2015');
select set_airbox_tick_flags('17','2015');
select set_airbox_tick_flags('18','2015');
select set_airbox_tick_flags('19','2015');
select set_airbox_tick_flags('20','2015');
select set_airbox_tick_flags('21','2015');
select set_airbox_tick_flags('22','2015');
select set_airbox_tick_flags('23','2015');
select set_airbox_tick_flags('24','2015');
select set_airbox_tick_flags('25','2015');
select set_airbox_tick_flags('26','2015');
select set_airbox_tick_flags('27','2015');
select set_airbox_tick_flags('28','2015');
select set_airbox_tick_flags('29','2015');
select set_airbox_tick_flags('30','2015');
select set_airbox_tick_flags('31','2015');
select set_airbox_tick_flags('32','2015');
select set_airbox_tick_flags('33','2015');
select set_airbox_tick_flags('34','2015');
select set_airbox_tick_flags('35','2015');
select set_airbox_tick_flags('36','2015');
select set_airbox_tick_flags('37','2015');
select set_airbox_tick_flags('38','2015');
select set_airbox_tick_flags('39','2015');
select set_airbox_tick_flags('40','2015');


select airbox, count(*) 
from aireas_ticks
group by airbox
order by airbox
;

select airbox, count(*)
from aireas_airbox_sensor_tick_flags
group by airbox
order by airbox
;

select airbox, extract(year from tick_date) jaar , extract(month from tick_date) maand, count(*)
from aireas_airbox_sensor_tick_flags
where airbox = '20'
group by airbox, jaar, maand
order by airbox, jaar, maand
;

select airbox, extract(year from tick_date) jaar , extract(month from tick_date) maand, extract(day from tick_date) dag, count(*)
from aireas_airbox_sensor_tick_flags
where airbox = '20'
and extract(year from tick_date) = 2015 
and extract(month from tick_date) = 12
group by airbox, jaar, maand, dag
order by airbox, jaar, maand, dag
;



*/
-- DROP FUNCTION set_airbox_tick_flags(airbox varchar, year char(4) )
-- test: select set_airbox_tick_flags('12','2015');
CREATE OR REPLACE FUNCTION public.set_airbox_tick_flags( airbox varchar, year character(4) ) RETURNS void AS $BODY$
DECLARE
  tmp_tick_start  TIMESTAMP WITH TIME ZONE; 
  tmp_tick_end  TIMESTAMP WITH TIME ZONE; 
  tmpRecord record;

BEGIN
	tmp_tick_start := $2||'0101T00:00:00Z';
	tmp_tick_end := $2||'1231T24:00:00Z';


/*	EXECUTE ' SELECT ts.airbox, ts.tickdate FROM aireas_ticks ts ' ||
			'	LEFT OUTER JOIN aireas_histecn h ' ||
			'	ON ts.airbox = h.airbox and ts.tickdate = h.tickdate ' ||
			' WHERE 1=1 ' ||
			' AND h.airbox is null ' ||
			' AND ts.airbox = $1 '
			USING $1
			INTO tmpRecord;
*/
	FOR tmpRecord IN SELECT ts.airbox, ts.tickdate FROM aireas_ticks ts 
			LEFT OUTER JOIN aireas_histecn h 
			ON ts.airbox = h.airbox and ts.tickdate = h.tickdate 
			WHERE 1=1  
			AND h.airbox is null 
			AND ts.airbox = $1 
	LOOP
		INSERT INTO aireas_airbox_sensor_tick_flags (airbox, tick_date, flag_code ) VALUES (tmpRecord.airbox, tmpRecord.tickdate, 'NoHist');
		--SELECT airbox, tickdate, 'NoHist' from tmpRecord;
--		RETURN NEXT tmpRecordr; -- return current row of SELECT
	END LOOP;
			
--	EXECUTE ' INSERT INTO aireas_airbox_sensor_tick_flags (airbox, tickdate, flag_code ) SELECT airbox, tickdate, ''NoHist'' from $1; '
--			USING tmpRecord; 

--	WHILE tmp_tick_start <= tmp_tick_end LOOP
--	END LOOP;
	
--	RAISE unique_violation USING MESSAGE = 'tmp_tick_start: '  || ' ' || tmp_tick_start || ' tmp_tick_end: '  || ' ' || tmp_tick_end;  --for debug purpose

	return ;
    
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
   ;
ALTER FUNCTION public.set_airbox_tick_flags(airbox CHARACTER VARYING(255), year character(4))
  OWNER TO postgres;
   
