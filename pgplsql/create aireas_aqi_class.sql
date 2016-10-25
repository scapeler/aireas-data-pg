--drop table aireas_aqi_class;
--CREATE SEQUENCE public.aireas_aqi_class_gid_seq
--  INCREMENT 1
--  MINVALUE 1
--  MAXVALUE 9223372036854775807
--  START 1
--  CACHE 1;
--ALTER TABLE public.aireas_aqi_class_gid_seq
--  OWNER TO postgres;
create table public.aireas_aqi_class (
  gid integer NOT NULL DEFAULT nextval('aireas_aqi_class_gid_seq'::regclass),
  aqi_type character varying(24) NOT NULL,
  aqi_class character varying(24) NOT NULL,
  aqi_sub_class character varying(24),
  aqi_color character varying(24) NOT NULL,
  aqi_low numeric NOT NULL,
  aqi_high numeric NOT NULL,
  creation_date timestamp with time zone,
  CONSTRAINT aireas_aqi_class_pkey PRIMARY KEY (gid)
)
WITH (
  OIDS=FALSE
);
ALTER TABLE public.aireas_aqi_class
  OWNER TO postgres;
CREATE INDEX aireas_aqi_class_aqi_type_idx
  ON public.aireas_aqi_class
  USING btree
  (aqi_type, aqi_class, aqi_sub_class);
  

insert into aireas_aqi_class (aqi_type, aqi_class, aqi_sub_class, aqi_color, aqi_low, aqi_high)  values ('AiREAS', 'Good', 				null, 'Green',	0,50);
insert into aireas_aqi_class (aqi_type, aqi_class, aqi_sub_class, aqi_color, aqi_low, aqi_high)  values ('AiREAS', 'Moderate', 			null, 'Yellow',	50,100);
insert into aireas_aqi_class (aqi_type, aqi_class, aqi_sub_class, aqi_color, aqi_low, aqi_high)  values ('AiREAS', 'UnhealthySens', 	null, 'Orange',	100,150);
insert into aireas_aqi_class (aqi_type, aqi_class, aqi_sub_class, aqi_color, aqi_low, aqi_high)  values ('AiREAS', 'Unhealthy', 		null, 'Red',	150,200);
insert into aireas_aqi_class (aqi_type, aqi_class, aqi_sub_class, aqi_color, aqi_low, aqi_high)  values ('AiREAS', 'VeryUnhealthy', 	null, 'Purple',	200,300);
insert into aireas_aqi_class (aqi_type, aqi_class, aqi_sub_class, aqi_color, aqi_low, aqi_high)  values ('AiREAS', 'Hazardous', 		null, 'Maroon',	300,500);

insert into aireas_aqi_class (aqi_type, aqi_class, aqi_sub_class, aqi_color, aqi_low, aqi_high)  values ('AiREAS', 'Good', 				'000', 'Green',	0,50);
insert into aireas_aqi_class (aqi_type, aqi_class, aqi_sub_class, aqi_color, aqi_low, aqi_high)  values ('AiREAS', 'Moderate', 			'050', 'Yellow',50,100);
insert into aireas_aqi_class (aqi_type, aqi_class, aqi_sub_class, aqi_color, aqi_low, aqi_high)  values ('AiREAS', 'UnhealthySens', 	'100', 'Orange',100,150);
insert into aireas_aqi_class (aqi_type, aqi_class, aqi_sub_class, aqi_color, aqi_low, aqi_high)  values ('AiREAS', 'Unhealthy', 		'150', 'Red',	150,200);
insert into aireas_aqi_class (aqi_type, aqi_class, aqi_sub_class, aqi_color, aqi_low, aqi_high)  values ('AiREAS', 'VeryUnhealthy', 	'200', 'Purple',200,300);
insert into aireas_aqi_class (aqi_type, aqi_class, aqi_sub_class, aqi_color, aqi_low, aqi_high)  values ('AiREAS', 'Hazardous', 		'300', 'Maroon',300,500);


insert into aireas_aqi_class (aqi_type, aqi_class, aqi_sub_class, aqi_color, aqi_low, aqi_high)  values ('AiREAS_NL', 'Good', 			null, '#00b0f0',10,40);
insert into aireas_aqi_class (aqi_type, aqi_class, aqi_sub_class, aqi_color, aqi_low, aqi_high)  values ('AiREAS_NL', 'Moderate', 		null, '#ffff04',40,70);
insert into aireas_aqi_class (aqi_type, aqi_class, aqi_sub_class, aqi_color, aqi_low, aqi_high)  values ('AiREAS_NL', 'UnhealthySens', 	null, '#ff8141',70,90);
insert into aireas_aqi_class (aqi_type, aqi_class, aqi_sub_class, aqi_color, aqi_low, aqi_high)  values ('AiREAS_NL', 'Unhealthy', 		null, '#ff0201',90,110);
insert into aireas_aqi_class (aqi_type, aqi_class, aqi_sub_class, aqi_color, aqi_low, aqi_high)  values ('AiREAS_NL', 'VeryUnhealthy', 	null, '#7030a0',110,500);
  
insert into aireas_aqi_class (aqi_type, aqi_class, aqi_sub_class, aqi_color, aqi_low, aqi_high)  values ('AiREAS_NL', 'Good', 			'010', '#00b0f0',10,20);
insert into aireas_aqi_class (aqi_type, aqi_class, aqi_sub_class, aqi_color, aqi_low, aqi_high)  values ('AiREAS_NL', 'Good', 			'020', '#00b0f0',20,30);
insert into aireas_aqi_class (aqi_type, aqi_class, aqi_sub_class, aqi_color, aqi_low, aqi_high)  values ('AiREAS_NL', 'Good', 			'030', '#00b0f0',30,40);
insert into aireas_aqi_class (aqi_type, aqi_class, aqi_sub_class, aqi_color, aqi_low, aqi_high)  values ('AiREAS_NL', 'Moderate', 		'040', '#ffff04',40,50);
insert into aireas_aqi_class (aqi_type, aqi_class, aqi_sub_class, aqi_color, aqi_low, aqi_high)  values ('AiREAS_NL', 'Moderate', 		'050', '#ffff04',50,60);
insert into aireas_aqi_class (aqi_type, aqi_class, aqi_sub_class, aqi_color, aqi_low, aqi_high)  values ('AiREAS_NL', 'Moderate', 		'060', '#ffff04',60,70);
insert into aireas_aqi_class (aqi_type, aqi_class, aqi_sub_class, aqi_color, aqi_low, aqi_high)  values ('AiREAS_NL', 'UnhealthySens', 	'070', '#ff8141',70,80);
insert into aireas_aqi_class (aqi_type, aqi_class, aqi_sub_class, aqi_color, aqi_low, aqi_high)  values ('AiREAS_NL', 'UnhealthySens', 	'080', '#ff8141',80,90);
insert into aireas_aqi_class (aqi_type, aqi_class, aqi_sub_class, aqi_color, aqi_low, aqi_high)  values ('AiREAS_NL', 'Unhealthy', 		'090', '#ff0201',90,100);
insert into aireas_aqi_class (aqi_type, aqi_class, aqi_sub_class, aqi_color, aqi_low, aqi_high)  values ('AiREAS_NL', 'Unhealthy', 		'100', '#ff0201',100,110);
insert into aireas_aqi_class (aqi_type, aqi_class, aqi_sub_class, aqi_color, aqi_low, aqi_high)  values ('AiREAS_NL', 'VeryUnhealthy', 	'110', '#7030a0',110,500);

