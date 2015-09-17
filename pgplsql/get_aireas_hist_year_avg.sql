
-- delete from aireas_hist_avg;


-- insert 'day avg' records per sensor 

INSERT INTO aireas_hist_avg (airbox, hist_year, hist_month, hist_day, hist_count, last_measuredate, avg_type, avg_avg, geom, creation_date)
SELECT distinct(airbox)
, date_part('year', measuredate) hist_year
, date_part('month', measuredate) hist_month
, date_part('day', measuredate) hist_day
, count(*) hist_count
, max (measuredate) last_measuredate
, 'PM1' avg_type
, round(cast(avg(PM1float) as numeric),2) avg_avg
, max(geom) geom
, current_timestamp creation_date
FROM public.aireas_hist
where 1=1 --date_part('year', measuredate) = 2013
and mark_date is null
and PM1float <> 0
and PM1float is not null
group by airbox, hist_year, hist_month, hist_day
order by airbox, hist_year, hist_month, hist_day
;

INSERT INTO aireas_hist_avg (airbox, hist_year, hist_month, hist_day, hist_count, last_measuredate, avg_type, avg_avg, geom, creation_date)
SELECT distinct(airbox)
, date_part('year', measuredate) hist_year
, date_part('month', measuredate) hist_month
, date_part('day', measuredate) hist_day
, count(*) hist_count
, max (measuredate) last_measuredate
, 'PM25' avg_type
, round(cast(avg(PM25float) as numeric),2) avg_avg
, max(geom) geom
, current_timestamp creation_date
FROM public.aireas_hist
where 1=1 --date_part('year', measuredate) = 2013
and mark_date is null
and PM25float <> 0
and PM25float is not null
group by airbox, hist_year, hist_month, hist_day
order by airbox, hist_year, hist_month, hist_day
;

INSERT INTO aireas_hist_avg (airbox, hist_year, hist_month, hist_day, hist_count, last_measuredate, avg_type, avg_avg, geom, creation_date)
SELECT distinct(airbox)
, date_part('year', measuredate) hist_year
, date_part('month', measuredate) hist_month
, date_part('day', measuredate) hist_day
, count(*) hist_count
, max (measuredate) last_measuredate
, 'PM10' avg_type
, round(cast(avg(PM10float) as numeric),2) avg_avg
, max(geom) geom
, current_timestamp creation_date
FROM public.aireas_hist
where 1=1 --date_part('year', measuredate) = 2013
and mark_date is null
and PM10float <> 0
and PM10float is not null
group by airbox, hist_year, hist_month, hist_day
order by airbox, hist_year, hist_month, hist_day
;

INSERT INTO aireas_hist_avg (airbox, hist_year, hist_month, hist_day, hist_count, last_measuredate, avg_type, avg_avg, geom, creation_date)
SELECT distinct(airbox)
, date_part('year', measuredate) hist_year
, date_part('month', measuredate) hist_month
, date_part('day', measuredate) hist_day
, count(*) hist_count
, max (measuredate) last_measuredate
, 'OZON' avg_type
, round(cast(avg(OZONfloat) as numeric),2) avg_avg
, max(geom) geom
, current_timestamp creation_date
FROM public.aireas_hist
where 1=1 --date_part('year', measuredate) = 2013
and mark_date is null
and OZONfloat <> 0
and OZONfloat is not null
group by airbox, hist_year, hist_month, hist_day
order by airbox, hist_year, hist_month, hist_day
;

INSERT INTO aireas_hist_avg (airbox, hist_year, hist_month, hist_day, hist_count, last_measuredate, avg_type, avg_avg, geom, creation_date)
SELECT distinct(airbox)
, date_part('year', measuredate) hist_year
, date_part('month', measuredate) hist_month
, date_part('day', measuredate) hist_day
, count(*) hist_count
, max (measuredate) last_measuredate
, 'UFP' avg_type
, round(cast(avg(UFPfloat) as numeric),2) avg_avg
, max(geom) geom
, current_timestamp creation_date
FROM public.aireas_hist
where 1=1 --date_part('year', measuredate) = 2013
and mark_date is null
and UFPfloat <> 0
and UFPfloat is not null
group by airbox, hist_year, hist_month, hist_day
order by airbox, hist_year, hist_month, hist_day
;

INSERT INTO aireas_hist_avg (airbox, hist_year, hist_month, hist_day, hist_count, last_measuredate, avg_type, avg_avg, geom, creation_date)
SELECT distinct(airbox)
, date_part('year', measuredate) hist_year
, date_part('month', measuredate) hist_month
, date_part('day', measuredate) hist_day
, count(*) hist_count
, max (measuredate) last_measuredate
, 'NO2' avg_type
, round(cast(avg(NO2float) as numeric),2) avg_avg
, max(geom) geom
, current_timestamp creation_date
FROM public.aireas_hist
where 1=1 --date_part('year', measuredate) = 2013
and mark_date is null
and NO2float <> 0
and NO2float is not null
group by airbox, hist_year, hist_month, hist_day
order by airbox, hist_year, hist_month, hist_day
;


-- insert 'month avg' records per sensor 

INSERT INTO aireas_hist_avg (airbox, hist_year, hist_month, hist_count, last_measuredate, avg_type, avg_avg, geom, creation_date)
SELECT distinct(airbox)
, date_part('year', measuredate) hist_year
, date_part('month', measuredate) hist_month
, count(*) hist_count
, max (measuredate) last_measuredate
, 'PM1' avg_type
, round(cast(avg(PM1float) as numeric),2) avg_avg
, max(geom) geom
, current_timestamp creation_date
FROM public.aireas_hist
where 1=1 --date_part('year', measuredate) = 2013
and mark_date is null
and PM1float <> 0
and PM1float is not null
group by airbox, hist_year, hist_month
order by airbox, hist_year, hist_month
;

INSERT INTO aireas_hist_avg (airbox, hist_year, hist_month, hist_count, last_measuredate, avg_type, avg_avg, geom, creation_date)
SELECT distinct(airbox)
, date_part('year', measuredate) hist_year
, date_part('month', measuredate) hist_month
, count(*) hist_count
, max (measuredate) last_measuredate
, 'PM25' avg_type
, round(cast(avg(PM25float) as numeric),2) avg_avg
, max(geom) geom
, current_timestamp creation_date
FROM public.aireas_hist
where 1=1 --date_part('year', measuredate) = 2013
and mark_date is null
and PM25float <> 0
and PM25float is not null
group by airbox, hist_year, hist_month
order by airbox, hist_year, hist_month
;

INSERT INTO aireas_hist_avg (airbox, hist_year, hist_month, hist_count, last_measuredate, avg_type, avg_avg, geom, creation_date)
SELECT distinct(airbox)
, date_part('year', measuredate) hist_year
, date_part('month', measuredate) hist_month
, count(*) hist_count
, max (measuredate) last_measuredate
, 'PM10' avg_type
, round(cast(avg(PM10float) as numeric),2) avg_avg
, max(geom) geom
, current_timestamp creation_date
FROM public.aireas_hist
where 1=1 --date_part('year', measuredate) = 2013
and mark_date is null
and PM10float <> 0
and PM10float is not null
group by airbox, hist_year, hist_month
order by airbox, hist_year, hist_month
;

INSERT INTO aireas_hist_avg (airbox, hist_year, hist_month, hist_count, last_measuredate, avg_type, avg_avg, geom, creation_date)
SELECT distinct(airbox)
, date_part('year', measuredate) hist_year
, date_part('month', measuredate) hist_month
, count(*) hist_count
, max (measuredate) last_measuredate
, 'OZON' avg_type
, round(cast(avg(OZONfloat) as numeric),2) avg_avg
, max(geom) geom
, current_timestamp creation_date
FROM public.aireas_hist
where 1=1 --date_part('year', measuredate) = 2013
and mark_date is null
and OZONfloat <> 0
and OZONfloat is not null
group by airbox, hist_year, hist_month
order by airbox, hist_year, hist_month
;

INSERT INTO aireas_hist_avg (airbox, hist_year, hist_month, hist_count, last_measuredate, avg_type, avg_avg, geom, creation_date)
SELECT distinct(airbox)
, date_part('year', measuredate) hist_year
, date_part('month', measuredate) hist_month
, count(*) hist_count
, max (measuredate) last_measuredate
, 'UFP' avg_type
, round(cast(avg(UFPfloat) as numeric),2) avg_avg
, max(geom) geom
, current_timestamp creation_date
FROM public.aireas_hist
where 1=1 --date_part('year', measuredate) = 2013
and mark_date is null
and UFPfloat <> 0
and UFPfloat is not null
group by airbox, hist_year, hist_month
order by airbox, hist_year, hist_month
;

INSERT INTO aireas_hist_avg (airbox, hist_year, hist_month, hist_count, last_measuredate, avg_type, avg_avg, geom, creation_date)
SELECT distinct(airbox)
, date_part('year', measuredate) hist_year
, date_part('month', measuredate) hist_month
, count(*) hist_count
, max (measuredate) last_measuredate
, 'NO2' avg_type
, round(cast(avg(NO2float) as numeric),2) avg_avg
, max(geom) geom
, current_timestamp creation_date
FROM public.aireas_hist
where 1=1 --date_part('year', measuredate) = 2013
and mark_date is null
and NO2float <> 0
and NO2float is not null
group by airbox, hist_year, hist_month
order by airbox, hist_year, hist_month
;


-- insert 'year avg' records per sensor 

INSERT INTO aireas_hist_avg (airbox, hist_year, hist_count, last_measuredate, avg_type, avg_avg, geom, creation_date)
SELECT distinct(airbox)
, date_part('year', measuredate) hist_year
, count(*) hist_count
, max (measuredate) last_measuredate
, 'PM1' avg_type
, round(cast(avg(PM1float) as numeric),2) avg_avg
, max(geom) geom
, current_timestamp creation_date
FROM public.aireas_hist
where 1=1 --date_part('year', measuredate) = 2013
and mark_date is null
and PM1float <> 0
and PM1float is not null
group by airbox, hist_year
order by airbox, hist_year
;

INSERT INTO aireas_hist_avg (airbox, hist_year, hist_count, last_measuredate, avg_type, avg_avg, geom, creation_date)
SELECT distinct(airbox)
, date_part('year', measuredate) hist_year
, count(*) hist_count
, max (measuredate) last_measuredate
, 'PM25' avg_type
, round(cast(avg(PM25float) as numeric),2) avg_avg
, max(geom) geom
, current_timestamp creation_date
FROM public.aireas_hist
where 1=1 --date_part('year', measuredate) = 2013
and mark_date is null
and PM25float <> 0
and PM25float is not null
group by airbox, hist_year
order by airbox, hist_year
;

INSERT INTO aireas_hist_avg (airbox, hist_year, hist_count, last_measuredate, avg_type, avg_avg, geom, creation_date)
SELECT distinct(airbox)
, date_part('year', measuredate) hist_year
, count(*) hist_count
, max (measuredate) last_measuredate
, 'PM10' avg_type
, round(cast(avg(PM10float) as numeric),2) avg_avg
, max(geom) geom
, current_timestamp creation_date
FROM public.aireas_hist
where 1=1 --date_part('year', measuredate) = 2013
and mark_date is null
and PM10float <> 0
and PM10float is not null
group by airbox, hist_year
order by airbox, hist_year
;

INSERT INTO aireas_hist_avg (airbox, hist_year, hist_count, last_measuredate, avg_type, avg_avg, geom, creation_date)
SELECT distinct(airbox)
, date_part('year', measuredate) hist_year
, count(*) hist_count
, max (measuredate) last_measuredate
, 'OZON' avg_type
, round(cast(avg(OZONfloat) as numeric),2) avg_avg
, max(geom) geom
, current_timestamp creation_date
FROM public.aireas_hist
where 1=1 --date_part('year', measuredate) = 2013
and mark_date is null
and OZONfloat <> 0
and OZONfloat is not null
group by airbox, hist_year
order by airbox, hist_year
;

INSERT INTO aireas_hist_avg (airbox, hist_year, hist_count, last_measuredate, avg_type, avg_avg, geom, creation_date)
SELECT distinct(airbox)
, date_part('year', measuredate) hist_year
, count(*) hist_count
, max (measuredate) last_measuredate
, 'UFP' avg_type
, round(cast(avg(UFPfloat) as numeric),2) avg_avg
, max(geom) geom
, current_timestamp creation_date
FROM public.aireas_hist
where 1=1 --date_part('year', measuredate) = 2013
and mark_date is null
and UFPfloat <> 0
and UFPfloat is not null
group by airbox, hist_year
order by airbox, hist_year
;

INSERT INTO aireas_hist_avg (airbox, hist_year, hist_count, last_measuredate, avg_type, avg_avg, geom, creation_date)
SELECT distinct(airbox)
, date_part('year', measuredate) hist_year
, count(*) hist_count
, max (measuredate) last_measuredate
, 'NO2' avg_type
, round(cast(avg(NO2float) as numeric),2) avg_avg
, max(geom) geom
, current_timestamp creation_date
FROM public.aireas_hist
where 1=1 --date_part('year', measuredate) = 2013
and mark_date is null
and NO2float <> 0
and NO2float is not null
group by airbox, hist_year
order by airbox, hist_year
;














!!  vanaf hier oud:

-- insert 'day avg' records
INSERT INTO aireas_hist_avg (airbox, hist_year, hist_month, hist_day, hist_count, last_measuredate, avg_type, avg_avg, geom, creation_date)
SELECT distinct(airbox)
, date_part('year', measuredate) hist_year
, date_part('month', measuredate) hist_month
, date_part('day', measuredate) hist_day
, count(*) hist_count
, max (measuredate) last_measuredate
, 'PM1' avg_type
, round(cast(avg(PM1float) as numeric),2) avg_avg
, max(geom) geom
, current_timestamp creation_date
FROM public.aireas_hist
where date_part('year', measuredate) = 2013
--and mark_date is null
group by airbox, hist_year, hist_month, hist_day
order by airbox, hist_year, hist_month, hist_day
;

INSERT INTO aireas_hist_avg (airbox, hist_year, hist_month, hist_day, hist_count, last_measuredate, avg_type, avg_avg, geom, creation_date)
SELECT distinct(airbox)
, date_part('year', measuredate) hist_year
, date_part('month', measuredate) hist_month
, date_part('day', measuredate) hist_day
, count(*) hist_count
, max (measuredate) last_measuredate
, 'PM25' avg_type
, round(cast(avg(PM25float) as numeric),2) avg_avg
, max(geom) geom
, current_timestamp creation_date
FROM public.aireas_hist
where date_part('year', measuredate) = 2013
--and mark_date is null
group by airbox, hist_year, hist_month, hist_day
order by airbox, hist_year, hist_month, hist_day
;

INSERT INTO aireas_hist_avg (airbox, hist_year, hist_month, hist_day, hist_count, last_measuredate, avg_type, avg_avg, geom, creation_date)
SELECT distinct(airbox)
, date_part('year', measuredate) hist_year
, date_part('month', measuredate) hist_month
, date_part('day', measuredate) hist_day
, count(*) hist_count
, max (measuredate) last_measuredate
, 'PM10' avg_type
, round(cast(avg(PM10float) as numeric),2) avg_avg
, max(geom) geom
, current_timestamp creation_date
FROM public.aireas_hist
where date_part('year', measuredate) = 2013
--and mark_date is null
group by airbox, hist_year, hist_month, hist_day
order by airbox, hist_year, hist_month, hist_day
;

INSERT INTO aireas_hist_avg (airbox, hist_year, hist_month, hist_day, hist_count, last_measuredate, avg_type, avg_avg, geom, creation_date)
SELECT distinct(airbox)
, date_part('year', measuredate) hist_year
, date_part('month', measuredate) hist_month
, date_part('day', measuredate) hist_day
, count(*) hist_count
, max (measuredate) last_measuredate
, 'OZON' avg_type
, round(cast(avg(OZONfloat) as numeric),2) avg_avg
, max(geom) geom
, current_timestamp creation_date
FROM public.aireas_hist
where date_part('year', measuredate) = 2013
--and mark_date is null
group by airbox, hist_year, hist_month, hist_day
order by airbox, hist_year, hist_month, hist_day
;

-- month avg
INSERT INTO aireas_hist_avg (airbox, hist_year, hist_month, hist_count, last_measuredate, avg_type, avg_avg, geom, creation_date)
SELECT distinct(airbox)
, hist_year
, hist_month
, sum(hist_count) hist_count
, max (last_measuredate) last_measuredate
, avg_type
, round(avg(avg_avg),2) avg_avg
, max(geom) geom
, current_timestamp creation_date
FROM public.aireas_hist_avg
where hist_year = 2013
and hist_month is not null
and hist_day is not null
group by airbox, avg_type, hist_year, hist_month
order by airbox, avg_type, hist_year, hist_month
;

-- year avg
INSERT INTO aireas_hist_avg (airbox, hist_year, hist_count, last_measuredate, avg_type, avg_avg, geom, creation_date)
SELECT distinct(airbox)
, hist_year
, sum(hist_count) hist_count
, max (last_measuredate) last_measuredate
, avg_type
, round(avg(avg_avg),2) avg_avg
, max(geom) geom
, current_timestamp creation_date
FROM public.aireas_hist_avg
where hist_year = 2013
and hist_month is not null
and hist_day is null
group by airbox, avg_type, hist_year
order by airbox, avg_type, hist_year
;



-- idem for 2014


-- insert 'day avg' records
INSERT INTO aireas_hist_avg (airbox, hist_year, hist_month, hist_day, hist_count, last_measuredate, avg_type, avg_avg, geom, creation_date)
SELECT distinct(airbox)
, date_part('year', measuredate) hist_year
, date_part('month', measuredate) hist_month
, date_part('day', measuredate) hist_day
, count(*) hist_count
, max (measuredate) last_measuredate
, 'PM1' avg_type
, round(cast(avg(PM1float) as numeric),2) avg_avg
, max(geom) geom
, current_timestamp creation_date
FROM public.aireas_hist
where date_part('year', measuredate) = 2014
--and mark_date is null
group by airbox, hist_year, hist_month, hist_day
order by airbox, hist_year, hist_month, hist_day
;

INSERT INTO aireas_hist_avg (airbox, hist_year, hist_month, hist_day, hist_count, last_measuredate, avg_type, avg_avg, geom, creation_date)
SELECT distinct(airbox)
, date_part('year', measuredate) hist_year
, date_part('month', measuredate) hist_month
, date_part('day', measuredate) hist_day
, count(*) hist_count
, max (measuredate) last_measuredate
, 'PM25' avg_type
, round(cast(avg(PM25float) as numeric),2) avg_avg
, max(geom) geom
, current_timestamp creation_date
FROM public.aireas_hist
where date_part('year', measuredate) = 2014
--and mark_date is null
group by airbox, hist_year, hist_month, hist_day
order by airbox, hist_year, hist_month, hist_day
;

INSERT INTO aireas_hist_avg (airbox, hist_year, hist_month, hist_day, hist_count, last_measuredate, avg_type, avg_avg, geom, creation_date)
SELECT distinct(airbox)
, date_part('year', measuredate) hist_year
, date_part('month', measuredate) hist_month
, date_part('day', measuredate) hist_day
, count(*) hist_count
, max (measuredate) last_measuredate
, 'PM10' avg_type
, round(cast(avg(PM10float) as numeric),2) avg_avg
, max(geom) geom
, current_timestamp creation_date
FROM public.aireas_hist
where date_part('year', measuredate) = 2014
--and mark_date is null
group by airbox, hist_year, hist_month, hist_day
order by airbox, hist_year, hist_month, hist_day
;

INSERT INTO aireas_hist_avg (airbox, hist_year, hist_month, hist_day, hist_count, last_measuredate, avg_type, avg_avg, geom, creation_date)
SELECT distinct(airbox)
, date_part('year', measuredate) hist_year
, date_part('month', measuredate) hist_month
, date_part('day', measuredate) hist_day
, count(*) hist_count
, max (measuredate) last_measuredate
, 'OZON' avg_type
, round(cast(avg(OZONfloat) as numeric),2) avg_avg
, max(geom) geom
, current_timestamp creation_date
FROM public.aireas_hist
where date_part('year', measuredate) = 2014
--and mark_date is null
group by airbox, hist_year, hist_month, hist_day
order by airbox, hist_year, hist_month, hist_day
;

-- month avg
INSERT INTO aireas_hist_avg (airbox, hist_year, hist_month, hist_count, last_measuredate, avg_type, avg_avg, geom, creation_date)
SELECT distinct(airbox)
, hist_year
, hist_month
, sum(hist_count) hist_count
, max (last_measuredate) last_measuredate
, avg_type
, round(avg(avg_avg),2) avg_avg
, max(geom) geom
, current_timestamp creation_date
FROM public.aireas_hist_avg
where hist_year = 2014
and hist_month is not null
and hist_day is not null
group by airbox, avg_type, hist_year, hist_month
order by airbox, avg_type, hist_year, hist_month
;

-- year avg
INSERT INTO aireas_hist_avg (airbox, hist_year, hist_count, last_measuredate, avg_type, avg_avg, geom, creation_date)
SELECT distinct(airbox)
, hist_year
, sum(hist_count) hist_count
, max (last_measuredate) last_measuredate
, avg_type
, round(avg(avg_avg),2) avg_avg
, max(geom) geom
, current_timestamp creation_date
FROM public.aireas_hist_avg
where hist_year = 2014
and hist_month is not null
and hist_day is null
group by airbox, avg_type, hist_year
order by airbox, avg_type, hist_year
;

-- idem for 2015

-- insert 'day avg' records
INSERT INTO aireas_hist_avg (airbox, hist_year, hist_month, hist_day, hist_count, last_measuredate, avg_type, avg_avg, geom, creation_date)
SELECT distinct(airbox)
, date_part('year', measuredate) hist_year
, date_part('month', measuredate) hist_month
, date_part('day', measuredate) hist_day
, count(*) hist_count
, max (measuredate) last_measuredate
, 'PM1' avg_type
, round(cast(avg(PM1float) as numeric),2) avg_avg
, max(geom) geom
, current_timestamp creation_date
FROM public.aireas_hist
where date_part('year', measuredate) = 2015
--and mark_date is null
group by airbox, hist_year, hist_month, hist_day
order by airbox, hist_year, hist_month, hist_day
;

INSERT INTO aireas_hist_avg (airbox, hist_year, hist_month, hist_day, hist_count, last_measuredate, avg_type, avg_avg, geom, creation_date)
SELECT distinct(airbox)
, date_part('year', measuredate) hist_year
, date_part('month', measuredate) hist_month
, date_part('day', measuredate) hist_day
, count(*) hist_count
, max (measuredate) last_measuredate
, 'PM25' avg_type
, round(cast(avg(PM25float) as numeric),2) avg_avg
, max(geom) geom
, current_timestamp creation_date
FROM public.aireas_hist
where date_part('year', measuredate) = 2015
--and mark_date is null
group by airbox, hist_year, hist_month, hist_day
order by airbox, hist_year, hist_month, hist_day
;

INSERT INTO aireas_hist_avg (airbox, hist_year, hist_month, hist_day, hist_count, last_measuredate, avg_type, avg_avg, geom, creation_date)
SELECT distinct(airbox)
, date_part('year', measuredate) hist_year
, date_part('month', measuredate) hist_month
, date_part('day', measuredate) hist_day
, count(*) hist_count
, max (measuredate) last_measuredate
, 'PM10' avg_type
, round(cast(avg(PM10float) as numeric),2) avg_avg
, max(geom) geom
, current_timestamp creation_date
FROM public.aireas_hist
where date_part('year', measuredate) = 2015
--and mark_date is null
group by airbox, hist_year, hist_month, hist_day
order by airbox, hist_year, hist_month, hist_day
;

INSERT INTO aireas_hist_avg (airbox, hist_year, hist_month, hist_day, hist_count, last_measuredate, avg_type, avg_avg, geom, creation_date)
SELECT distinct(airbox)
, date_part('year', measuredate) hist_year
, date_part('month', measuredate) hist_month
, date_part('day', measuredate) hist_day
, count(*) hist_count
, max (measuredate) last_measuredate
, 'OZON' avg_type
, round(cast(avg(OZONfloat) as numeric),2) avg_avg
, max(geom) geom
, current_timestamp creation_date
FROM public.aireas_hist
where date_part('year', measuredate) = 2015
--and mark_date is null
group by airbox, hist_year, hist_month, hist_day
order by airbox, hist_year, hist_month, hist_day
;

-- month avg
INSERT INTO aireas_hist_avg (airbox, hist_year, hist_month, hist_count, last_measuredate, avg_type, avg_avg, geom, creation_date)
SELECT distinct(airbox)
, hist_year
, hist_month
, sum(hist_count) hist_count
, max (last_measuredate) last_measuredate
, avg_type
, round(avg(avg_avg),2) avg_avg
, max(geom) geom
, current_timestamp creation_date
FROM public.aireas_hist_avg
where hist_year = 2015
and hist_month is not null
and hist_day is not null
group by airbox, avg_type, hist_year, hist_month
order by airbox, avg_type, hist_year, hist_month
;

-- year avg
INSERT INTO aireas_hist_avg (airbox, hist_year, hist_count, last_measuredate, avg_type, avg_avg, geom, creation_date)
SELECT distinct(airbox)
, hist_year
, sum(hist_count) hist_count
, max (last_measuredate) last_measuredate
, avg_type
, round(avg(avg_avg),2) avg_avg
, max(geom) geom
, current_timestamp creation_date
FROM public.aireas_hist_avg
where hist_year = 2015
and hist_month is not null
and hist_day is null
group by airbox, avg_type, hist_year
order by airbox, avg_type, hist_year
;







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
   
