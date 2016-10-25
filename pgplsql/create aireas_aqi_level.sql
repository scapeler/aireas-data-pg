--drop table aireas_aqi_level;
--CREATE SEQUENCE public.aireas_aqi_level_gid_seq
--  INCREMENT 1
--  MINVALUE 1
--  MAXVALUE 9223372036854775807
--  START 1
--  CACHE 1;
--ALTER TABLE public.aireas_aqi_level_gid_seq
--  OWNER TO postgres;
create table public.aireas_aqi_level (
  gid integer NOT NULL DEFAULT nextval('aireas_aqi_level_gid_seq'::regclass),
  aqi_type character varying(24) NOT NULL,
  sensor_type character varying(24) NOT NULL,
  i_low numeric NOT NULL,
  i_high numeric NOT NULL,
  c_low numeric NOT NULL,
  c_high numeric NOT NULL,
  aqi_class character varying(24) NOT NULL,
  aqi_sub_class character varying(24) NOT NULL,
  creation_date timestamp with time zone,
  CONSTRAINT aireas_aqi_level_pkey PRIMARY KEY (gid)
)
WITH (
  OIDS=FALSE
);
ALTER TABLE public.aireas_aqi_level
  OWNER TO postgres;
CREATE INDEX aireas_aqi_level_aqi_type_idx
  ON public.aireas_aqi_level
  USING btree
  (aqi_type, sensor_type);
  
  
insert into aireas_aqi_level (aqi_type, sensor_type, c_low, c_high, i_low, i_high, aqi_class, aqi_sub_class)  values ('AiREAS', 'OZON', 0,40,0,50,'Good','000');
insert into aireas_aqi_level (aqi_type, sensor_type, c_low, c_high, i_low, i_high, aqi_class, aqi_sub_class)  values ('AiREAS', 'OZON', 40,100,51,100,'Moderate','050');
insert into aireas_aqi_level (aqi_type, sensor_type, c_low, c_high, i_low, i_high, aqi_class, aqi_sub_class)  values ('AiREAS', 'OZON', 100,180,101,150,'UnhealthySens','100');
insert into aireas_aqi_level (aqi_type, sensor_type, c_low, c_high, i_low, i_high, aqi_class, aqi_sub_class)  values ('AiREAS', 'OZON', 180,240,151,200,'Unhealthy','150');
insert into aireas_aqi_level (aqi_type, sensor_type, c_low, c_high, i_low, i_high, aqi_class, aqi_sub_class)  values ('AiREAS', 'OZON', 240,300,201,300,'VeryUnhealthy','200');
insert into aireas_aqi_level (aqi_type, sensor_type, c_low, c_high, i_low, i_high, aqi_class, aqi_sub_class)  values ('AiREAS', 'OZON', 300,550,301,500,'Hazardous','300');

insert into aireas_aqi_level (aqi_type, sensor_type, c_low, c_high, i_low, i_high, aqi_class, aqi_sub_class)  values ('AiREAS', 'PM1', 0,14,0,50,'Good','000');
insert into aireas_aqi_level (aqi_type, sensor_type, c_low, c_high, i_low, i_high, aqi_class, aqi_sub_class)  values ('AiREAS', 'PM1', 14,34,51,100,'Moderate','050');
insert into aireas_aqi_level (aqi_type, sensor_type, c_low, c_high, i_low, i_high, aqi_class, aqi_sub_class)  values ('AiREAS', 'PM1', 34,61,101,150,'UnhealthySens','100');
insert into aireas_aqi_level (aqi_type, sensor_type, c_low, c_high, i_low, i_high, aqi_class, aqi_sub_class)  values ('AiREAS', 'PM1', 61,95,151,200,'Unhealthy','150');
insert into aireas_aqi_level (aqi_type, sensor_type, c_low, c_high, i_low, i_high, aqi_class, aqi_sub_class)  values ('AiREAS', 'PM1', 95,100,201,300,'VeryUnhealthy','200');
insert into aireas_aqi_level (aqi_type, sensor_type, c_low, c_high, i_low, i_high, aqi_class, aqi_sub_class)  values ('AiREAS', 'PM1', 100,130,301,500,'Hazardous','300');

insert into aireas_aqi_level (aqi_type, sensor_type, c_low, c_high, i_low, i_high, aqi_class, aqi_sub_class)  values ('AiREAS', 'PM25', 0,20,0,50,'Good','000');
insert into aireas_aqi_level (aqi_type, sensor_type, c_low, c_high, i_low, i_high, aqi_class, aqi_sub_class)  values ('AiREAS', 'PM25', 20,50,51,100,'Moderate','050');
insert into aireas_aqi_level (aqi_type, sensor_type, c_low, c_high, i_low, i_high, aqi_class, aqi_sub_class)  values ('AiREAS', 'PM25', 50,90,101,150,'UnhealthySens','100');
insert into aireas_aqi_level (aqi_type, sensor_type, c_low, c_high, i_low, i_high, aqi_class, aqi_sub_class)  values ('AiREAS', 'PM25', 90,140,151,200,'Unhealthy','150');
insert into aireas_aqi_level (aqi_type, sensor_type, c_low, c_high, i_low, i_high, aqi_class, aqi_sub_class)  values ('AiREAS', 'PM25', 140,170,201,300,'VeryUnhealthy','200');
insert into aireas_aqi_level (aqi_type, sensor_type, c_low, c_high, i_low, i_high, aqi_class, aqi_sub_class)  values ('AiREAS', 'PM25', 170,300,301,500,'Hazardous','300');

insert into aireas_aqi_level (aqi_type, sensor_type, c_low, c_high, i_low, i_high, aqi_class, aqi_sub_class)  values ('AiREAS', 'PM10', 0,30,0,50,'Good','000');
insert into aireas_aqi_level (aqi_type, sensor_type, c_low, c_high, i_low, i_high, aqi_class, aqi_sub_class)  values ('AiREAS', 'PM10', 30,75,51,100,'Moderate','050');
insert into aireas_aqi_level (aqi_type, sensor_type, c_low, c_high, i_low, i_high, aqi_class, aqi_sub_class)  values ('AiREAS', 'PM10', 75,125,101,150,'UnhealthySens','100');
insert into aireas_aqi_level (aqi_type, sensor_type, c_low, c_high, i_low, i_high, aqi_class, aqi_sub_class)  values ('AiREAS', 'PM10', 125,200,151,200,'Unhealthy','150');
insert into aireas_aqi_level (aqi_type, sensor_type, c_low, c_high, i_low, i_high, aqi_class, aqi_sub_class)  values ('AiREAS', 'PM10', 200,250,201,300,'VeryUnhealthy','200');
insert into aireas_aqi_level (aqi_type, sensor_type, c_low, c_high, i_low, i_high, aqi_class, aqi_sub_class)  values ('AiREAS', 'PM10', 250,450,301,500,'Hazardous','300');

insert into aireas_aqi_level (aqi_type, sensor_type, c_low, c_high, i_low, i_high, aqi_class, aqi_sub_class)  values ('AiREAS', 'UFP', 0,6,0,50,'Good','000');
insert into aireas_aqi_level (aqi_type, sensor_type, c_low, c_high, i_low, i_high, aqi_class, aqi_sub_class)  values ('AiREAS', 'UFP', 6,15,51,100,'Moderate','050');
insert into aireas_aqi_level (aqi_type, sensor_type, c_low, c_high, i_low, i_high, aqi_class, aqi_sub_class)  values ('AiREAS', 'UFP', 15,25,101,150,'UnhealthySens','100');
insert into aireas_aqi_level (aqi_type, sensor_type, c_low, c_high, i_low, i_high, aqi_class, aqi_sub_class)  values ('AiREAS', 'UFP', 25,40,151,200,'Unhealthy','150');
insert into aireas_aqi_level (aqi_type, sensor_type, c_low, c_high, i_low, i_high, aqi_class, aqi_sub_class)  values ('AiREAS', 'UFP', 40,60,201,300,'VeryUnhealthy','200');
insert into aireas_aqi_level (aqi_type, sensor_type, c_low, c_high, i_low, i_high, aqi_class, aqi_sub_class)  values ('AiREAS', 'UFP', 60,140,301,500,'Hazardous','300');

insert into aireas_aqi_level (aqi_type, sensor_type, c_low, c_high, i_low, i_high, aqi_class, aqi_sub_class)  values ('AiREAS', 'NO2', 0,30,0,50,'Good','000');
insert into aireas_aqi_level (aqi_type, sensor_type, c_low, c_high, i_low, i_high, aqi_class, aqi_sub_class)  values ('AiREAS', 'NO2', 30,75,51,100,'Moderate','050');
insert into aireas_aqi_level (aqi_type, sensor_type, c_low, c_high, i_low, i_high, aqi_class, aqi_sub_class)  values ('AiREAS', 'NO2', 75,125,101,150,'UnhealthySens','100');
insert into aireas_aqi_level (aqi_type, sensor_type, c_low, c_high, i_low, i_high, aqi_class, aqi_sub_class)  values ('AiREAS', 'NO2', 125,200,151,200,'Unhealthy','150');
insert into aireas_aqi_level (aqi_type, sensor_type, c_low, c_high, i_low, i_high, aqi_class, aqi_sub_class)  values ('AiREAS', 'NO2', 200,250,201,300,'VeryUnhealthy','200');
insert into aireas_aqi_level (aqi_type, sensor_type, c_low, c_high, i_low, i_high, aqi_class, aqi_sub_class)  values ('AiREAS', 'NO2', 250,450,301,500,'Hazardous','300');


insert into aireas_aqi_level (aqi_type, sensor_type, c_low, c_high, i_low, i_high, aqi_class, aqi_sub_class)  values ('AiREAS_NL', 'overall', 0,0,10,20,'Good','010');
insert into aireas_aqi_level (aqi_type, sensor_type, c_low, c_high, i_low, i_high, aqi_class, aqi_sub_class)  values ('AiREAS_NL', 'overall', 0,0,20,30,'Good','020');
insert into aireas_aqi_level (aqi_type, sensor_type, c_low, c_high, i_low, i_high, aqi_class, aqi_sub_class)  values ('AiREAS_NL', 'overall', 0,0,30,40,'Good','030');
insert into aireas_aqi_level (aqi_type, sensor_type, c_low, c_high, i_low, i_high, aqi_class, aqi_sub_class)  values ('AiREAS_NL', 'overall', 0,0,40,50,'Moderate','040');
insert into aireas_aqi_level (aqi_type, sensor_type, c_low, c_high, i_low, i_high, aqi_class, aqi_sub_class)  values ('AiREAS_NL', 'overall', 0,0,50,60,'Moderate','050');
insert into aireas_aqi_level (aqi_type, sensor_type, c_low, c_high, i_low, i_high, aqi_class, aqi_sub_class)  values ('AiREAS_NL', 'overall', 0,0,60,70,'Moderate','060');
insert into aireas_aqi_level (aqi_type, sensor_type, c_low, c_high, i_low, i_high, aqi_class, aqi_sub_class)  values ('AiREAS_NL', 'overall', 0,0,70,80,'UnhealthySens','070');
insert into aireas_aqi_level (aqi_type, sensor_type, c_low, c_high, i_low, i_high, aqi_class, aqi_sub_class)  values ('AiREAS_NL', 'overall', 0,0,80,90,'UnhealthySens','080');
insert into aireas_aqi_level (aqi_type, sensor_type, c_low, c_high, i_low, i_high, aqi_class, aqi_sub_class)  values ('AiREAS_NL', 'overall', 0,0,90,100,'Unhealthy','090');
insert into aireas_aqi_level (aqi_type, sensor_type, c_low, c_high, i_low, i_high, aqi_class, aqi_sub_class)  values ('AiREAS_NL', 'overall', 0,0,100,110,'Unhealthy','100');
insert into aireas_aqi_level (aqi_type, sensor_type, c_low, c_high, i_low, i_high, aqi_class, aqi_sub_class)  values ('AiREAS_NL', 'overall', 0,0,110,500,'Hazardous','110');

insert into aireas_aqi_level (aqi_type, sensor_type, c_low, c_high, i_low, i_high, aqi_class, aqi_sub_class)  values ('AiREAS_NL', 'OZON', 0,15,10,20,'Good','010');
insert into aireas_aqi_level (aqi_type, sensor_type, c_low, c_high, i_low, i_high, aqi_class, aqi_sub_class)  values ('AiREAS_NL', 'OZON', 15,30,20,30,'Good','020');
insert into aireas_aqi_level (aqi_type, sensor_type, c_low, c_high, i_low, i_high, aqi_class, aqi_sub_class)  values ('AiREAS_NL', 'OZON', 30,40,30,40,'Good','030');
insert into aireas_aqi_level (aqi_type, sensor_type, c_low, c_high, i_low, i_high, aqi_class, aqi_sub_class)  values ('AiREAS_NL', 'OZON', 40,60,40,50,'Moderate','040');
insert into aireas_aqi_level (aqi_type, sensor_type, c_low, c_high, i_low, i_high, aqi_class, aqi_sub_class)  values ('AiREAS_NL', 'OZON', 60,80,50,60,'Moderate','050');
insert into aireas_aqi_level (aqi_type, sensor_type, c_low, c_high, i_low, i_high, aqi_class, aqi_sub_class)  values ('AiREAS_NL', 'OZON', 80,100,60,70,'Moderate','060');
insert into aireas_aqi_level (aqi_type, sensor_type, c_low, c_high, i_low, i_high, aqi_class, aqi_sub_class)  values ('AiREAS_NL', 'OZON', 100,140,70,80,'UnhealthySens','070');
insert into aireas_aqi_level (aqi_type, sensor_type, c_low, c_high, i_low, i_high, aqi_class, aqi_sub_class)  values ('AiREAS_NL', 'OZON', 140,180,80,90,'UnhealthySens','080');
insert into aireas_aqi_level (aqi_type, sensor_type, c_low, c_high, i_low, i_high, aqi_class, aqi_sub_class)  values ('AiREAS_NL', 'OZON', 180,200,90,100,'Unhealthy','090');
insert into aireas_aqi_level (aqi_type, sensor_type, c_low, c_high, i_low, i_high, aqi_class, aqi_sub_class)  values ('AiREAS_NL', 'OZON', 200,240,100,110,'Unhealthy','100');
insert into aireas_aqi_level (aqi_type, sensor_type, c_low, c_high, i_low, i_high, aqi_class, aqi_sub_class)  values ('AiREAS_NL', 'OZON', 240,500,110,500,'Hazardous','110');

insert into aireas_aqi_level (aqi_type, sensor_type, c_low, c_high, i_low, i_high, aqi_class, aqi_sub_class)  values ('AiREAS_NL', 'PM1', 0,7,10,20,'Good','010');
insert into aireas_aqi_level (aqi_type, sensor_type, c_low, c_high, i_low, i_high, aqi_class, aqi_sub_class)  values ('AiREAS_NL', 'PM1', 7,10,20,30,'Good','020');
insert into aireas_aqi_level (aqi_type, sensor_type, c_low, c_high, i_low, i_high, aqi_class, aqi_sub_class)  values ('AiREAS_NL', 'PM1', 10,14,30,40,'Good','030');
insert into aireas_aqi_level (aqi_type, sensor_type, c_low, c_high, i_low, i_high, aqi_class, aqi_sub_class)  values ('AiREAS_NL', 'PM1', 14,20,40,50,'Moderate','040');
insert into aireas_aqi_level (aqi_type, sensor_type, c_low, c_high, i_low, i_high, aqi_class, aqi_sub_class)  values ('AiREAS_NL', 'PM1', 20,27,50,60,'Moderate','050');
insert into aireas_aqi_level (aqi_type, sensor_type, c_low, c_high, i_low, i_high, aqi_class, aqi_sub_class)  values ('AiREAS_NL', 'PM1', 27,34,60,70,'Moderate','060');
insert into aireas_aqi_level (aqi_type, sensor_type, c_low, c_high, i_low, i_high, aqi_class, aqi_sub_class)  values ('AiREAS_NL', 'PM1', 34,48,70,80,'UnhealthySens','070');
insert into aireas_aqi_level (aqi_type, sensor_type, c_low, c_high, i_low, i_high, aqi_class, aqi_sub_class)  values ('AiREAS_NL', 'PM1', 48,61,80,90,'UnhealthySens','080');
insert into aireas_aqi_level (aqi_type, sensor_type, c_low, c_high, i_low, i_high, aqi_class, aqi_sub_class)  values ('AiREAS_NL', 'PM1', 61,68,90,100,'Unhealthy','090');
insert into aireas_aqi_level (aqi_type, sensor_type, c_low, c_high, i_low, i_high, aqi_class, aqi_sub_class)  values ('AiREAS_NL', 'PM1', 68,95,100,110,'Unhealthy','100');
insert into aireas_aqi_level (aqi_type, sensor_type, c_low, c_high, i_low, i_high, aqi_class, aqi_sub_class)  values ('AiREAS_NL', 'PM1', 95,500,110,500,'Hazardous','110');

insert into aireas_aqi_level (aqi_type, sensor_type, c_low, c_high, i_low, i_high, aqi_class, aqi_sub_class)  values ('AiREAS_NL', 'PM25', 0,10,10,20,'Good','010');
insert into aireas_aqi_level (aqi_type, sensor_type, c_low, c_high, i_low, i_high, aqi_class, aqi_sub_class)  values ('AiREAS_NL', 'PM25', 10,15,20,30,'Good','020');
insert into aireas_aqi_level (aqi_type, sensor_type, c_low, c_high, i_low, i_high, aqi_class, aqi_sub_class)  values ('AiREAS_NL', 'PM25', 15,20,30,40,'Good','030');
insert into aireas_aqi_level (aqi_type, sensor_type, c_low, c_high, i_low, i_high, aqi_class, aqi_sub_class)  values ('AiREAS_NL', 'PM25', 20,30,40,50,'Moderate','040');
insert into aireas_aqi_level (aqi_type, sensor_type, c_low, c_high, i_low, i_high, aqi_class, aqi_sub_class)  values ('AiREAS_NL', 'PM25', 30,40,50,60,'Moderate','050');
insert into aireas_aqi_level (aqi_type, sensor_type, c_low, c_high, i_low, i_high, aqi_class, aqi_sub_class)  values ('AiREAS_NL', 'PM25', 40,50,60,70,'Moderate','060');
insert into aireas_aqi_level (aqi_type, sensor_type, c_low, c_high, i_low, i_high, aqi_class, aqi_sub_class)  values ('AiREAS_NL', 'PM25', 50,70,70,80,'UnhealthySens','070');
insert into aireas_aqi_level (aqi_type, sensor_type, c_low, c_high, i_low, i_high, aqi_class, aqi_sub_class)  values ('AiREAS_NL', 'PM25', 70,90,80,90,'UnhealthySens','080');
insert into aireas_aqi_level (aqi_type, sensor_type, c_low, c_high, i_low, i_high, aqi_class, aqi_sub_class)  values ('AiREAS_NL', 'PM25', 90,100,90,100,'Unhealthy','090');
insert into aireas_aqi_level (aqi_type, sensor_type, c_low, c_high, i_low, i_high, aqi_class, aqi_sub_class)  values ('AiREAS_NL', 'PM25', 100,140,100,110,'Unhealthy','100');
insert into aireas_aqi_level (aqi_type, sensor_type, c_low, c_high, i_low, i_high, aqi_class, aqi_sub_class)  values ('AiREAS_NL', 'PM25', 140,500,110,500,'Hazardous','110');

insert into aireas_aqi_level (aqi_type, sensor_type, c_low, c_high, i_low, i_high, aqi_class, aqi_sub_class)  values ('AiREAS_NL', 'PM10', 0,10,10,20,'Good','010');
insert into aireas_aqi_level (aqi_type, sensor_type, c_low, c_high, i_low, i_high, aqi_class, aqi_sub_class)  values ('AiREAS_NL', 'PM10', 10,20,20,30,'Good','020');
insert into aireas_aqi_level (aqi_type, sensor_type, c_low, c_high, i_low, i_high, aqi_class, aqi_sub_class)  values ('AiREAS_NL', 'PM10', 20,30,30,40,'Good','030');
insert into aireas_aqi_level (aqi_type, sensor_type, c_low, c_high, i_low, i_high, aqi_class, aqi_sub_class)  values ('AiREAS_NL', 'PM10', 30,45,40,50,'Moderate','040');
insert into aireas_aqi_level (aqi_type, sensor_type, c_low, c_high, i_low, i_high, aqi_class, aqi_sub_class)  values ('AiREAS_NL', 'PM10', 45,60,50,60,'Moderate','050');
insert into aireas_aqi_level (aqi_type, sensor_type, c_low, c_high, i_low, i_high, aqi_class, aqi_sub_class)  values ('AiREAS_NL', 'PM10', 60,75,60,70,'Moderate','060');
insert into aireas_aqi_level (aqi_type, sensor_type, c_low, c_high, i_low, i_high, aqi_class, aqi_sub_class)  values ('AiREAS_NL', 'PM10', 75,100,70,80,'UnhealthySens','070');
insert into aireas_aqi_level (aqi_type, sensor_type, c_low, c_high, i_low, i_high, aqi_class, aqi_sub_class)  values ('AiREAS_NL', 'PM10', 100,125,80,90,'UnhealthySens','080');
insert into aireas_aqi_level (aqi_type, sensor_type, c_low, c_high, i_low, i_high, aqi_class, aqi_sub_class)  values ('AiREAS_NL', 'PM10', 125,150,90,100,'Unhealthy','090');
insert into aireas_aqi_level (aqi_type, sensor_type, c_low, c_high, i_low, i_high, aqi_class, aqi_sub_class)  values ('AiREAS_NL', 'PM10', 150,200,100,110,'Unhealthy','100');
insert into aireas_aqi_level (aqi_type, sensor_type, c_low, c_high, i_low, i_high, aqi_class, aqi_sub_class)  values ('AiREAS_NL', 'PM10', 200,500,110,500,'Hazardous','110');

insert into aireas_aqi_level (aqi_type, sensor_type, c_low, c_high, i_low, i_high, aqi_class, aqi_sub_class)  values ('AiREAS_NL', 'NO2', 0,10,10,20,'Good','010');
insert into aireas_aqi_level (aqi_type, sensor_type, c_low, c_high, i_low, i_high, aqi_class, aqi_sub_class)  values ('AiREAS_NL', 'NO2', 10,20,20,30,'Good','020');
insert into aireas_aqi_level (aqi_type, sensor_type, c_low, c_high, i_low, i_high, aqi_class, aqi_sub_class)  values ('AiREAS_NL', 'NO2', 20,30,30,40,'Good','030');
insert into aireas_aqi_level (aqi_type, sensor_type, c_low, c_high, i_low, i_high, aqi_class, aqi_sub_class)  values ('AiREAS_NL', 'NO2', 30,45,40,50,'Moderate','040');
insert into aireas_aqi_level (aqi_type, sensor_type, c_low, c_high, i_low, i_high, aqi_class, aqi_sub_class)  values ('AiREAS_NL', 'NO2', 45,60,50,60,'Moderate','050');
insert into aireas_aqi_level (aqi_type, sensor_type, c_low, c_high, i_low, i_high, aqi_class, aqi_sub_class)  values ('AiREAS_NL', 'NO2', 60,75,60,70,'Moderate','060');
insert into aireas_aqi_level (aqi_type, sensor_type, c_low, c_high, i_low, i_high, aqi_class, aqi_sub_class)  values ('AiREAS_NL', 'NO2', 75,100,70,80,'UnhealthySens','070');
insert into aireas_aqi_level (aqi_type, sensor_type, c_low, c_high, i_low, i_high, aqi_class, aqi_sub_class)  values ('AiREAS_NL', 'NO2', 100,125,80,90,'UnhealthySens','080');
insert into aireas_aqi_level (aqi_type, sensor_type, c_low, c_high, i_low, i_high, aqi_class, aqi_sub_class)  values ('AiREAS_NL', 'NO2', 125,150,90,100,'Unhealthy','090');
insert into aireas_aqi_level (aqi_type, sensor_type, c_low, c_high, i_low, i_high, aqi_class, aqi_sub_class)  values ('AiREAS_NL', 'NO2', 150,200,100,110,'Unhealthy','100');
insert into aireas_aqi_level (aqi_type, sensor_type, c_low, c_high, i_low, i_high, aqi_class, aqi_sub_class)  values ('AiREAS_NL', 'NO2', 200,500,110,500,'Hazardous','110');

insert into aireas_aqi_level (aqi_type, sensor_type, c_low, c_high, i_low, i_high, aqi_class, aqi_sub_class)  values ('AiREAS_NL', 'UFP', 0,2,10,20,'Good','010');
insert into aireas_aqi_level (aqi_type, sensor_type, c_low, c_high, i_low, i_high, aqi_class, aqi_sub_class)  values ('AiREAS_NL', 'UFP', 2,4,20,30,'Good','020');
insert into aireas_aqi_level (aqi_type, sensor_type, c_low, c_high, i_low, i_high, aqi_class, aqi_sub_class)  values ('AiREAS_NL', 'UFP', 4,6,30,40,'Good','030');
insert into aireas_aqi_level (aqi_type, sensor_type, c_low, c_high, i_low, i_high, aqi_class, aqi_sub_class)  values ('AiREAS_NL', 'UFP', 6,9,40,50,'Moderate','040');
insert into aireas_aqi_level (aqi_type, sensor_type, c_low, c_high, i_low, i_high, aqi_class, aqi_sub_class)  values ('AiREAS_NL', 'UFP', 9,12,50,60,'Moderate','050');
insert into aireas_aqi_level (aqi_type, sensor_type, c_low, c_high, i_low, i_high, aqi_class, aqi_sub_class)  values ('AiREAS_NL', 'UFP', 12,15,60,70,'Moderate','060');
insert into aireas_aqi_level (aqi_type, sensor_type, c_low, c_high, i_low, i_high, aqi_class, aqi_sub_class)  values ('AiREAS_NL', 'UFP', 15,20,70,80,'UnhealthySens','070');
insert into aireas_aqi_level (aqi_type, sensor_type, c_low, c_high, i_low, i_high, aqi_class, aqi_sub_class)  values ('AiREAS_NL', 'UFP', 20,25,80,90,'UnhealthySens','080');
insert into aireas_aqi_level (aqi_type, sensor_type, c_low, c_high, i_low, i_high, aqi_class, aqi_sub_class)  values ('AiREAS_NL', 'UFP', 25,30,90,100,'Unhealthy','090');
insert into aireas_aqi_level (aqi_type, sensor_type, c_low, c_high, i_low, i_high, aqi_class, aqi_sub_class)  values ('AiREAS_NL', 'UFP', 30,40,100,110,'Unhealthy','100');
insert into aireas_aqi_level (aqi_type, sensor_type, c_low, c_high, i_low, i_high, aqi_class, aqi_sub_class)  values ('AiREAS_NL', 'UFP', 40,50,110,500,'Hazardous','110');




