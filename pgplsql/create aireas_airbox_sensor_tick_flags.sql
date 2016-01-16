/*


select * from aireas_airbox_sensor_tick_flags;

INSERT INTO aireas_airbox_sensor_tick_flags (airbox, sensor_type, tick_date, flag_code) VALUES ('36', 'PM25', '2015-02-01T00:10:00Z', 'PHigh');
INSERT INTO aireas_airbox_sensor_tick_flags (airbox, sensor_type, tick_date, flag_code) VALUES ('36', 'PM25', '2015-02-01T00:20:00Z', 'PHigh');
INSERT INTO aireas_airbox_sensor_tick_flags (airbox, sensor_type, tick_date, flag_code) VALUES ('12', 'PM10', '2015-06-10T07:40:00Z', 'BaseLinePm');
INSERT INTO aireas_airbox_sensor_tick_flags (airbox, sensor_type, tick_date, flag_code) VALUES ('36', 'PM25', '2015-08-16T03:10:00Z', 'CalcValLow');


*/

-- select * from aireas_airbox_sensor_tick_flags;


-- Table: public.aireas_airbox_sensor_tick_flags

-- DROP TABLE public.aireas_airbox_sensor_tick_flags;
--CREATE SEQUENCE public.aireas_airbox_sensor_tick_flags_gid_seq
--  INCREMENT 1
--  MINVALUE 1
--  MAXVALUE 9223372036854775807
--  START 1
--  CACHE 1;
--ALTER TABLE public.aireas_airbox_sensor_tick_flags_gid_seq
--  OWNER TO postgres;

CREATE TABLE public.aireas_airbox_sensor_tick_flags
(
  gid integer NOT NULL DEFAULT nextval('aireas_airbox_sensor_tick_flags_gid_seq'::regclass),
  airbox character varying(255),
  sensor_type varchar(60),
  tick_date timestamp with time zone,  
  flag_code character varying(255),
  flag_value character varying(255),  
  flag_remarks character varying(255),
  CONSTRAINT aireas_airbox_tick_flags_pkey PRIMARY KEY (gid)
)
WITH (
  OIDS=FALSE
);
ALTER TABLE public.aireas_airbox_sensor_tick_flags
  OWNER TO postgres;

-- Index: public.aireas_airbox_sensor_tick_flags_at_idx

-- DROP INDEX public.aireas_airbox_sensor_tick_flags_at_idx;

CREATE UNIQUE INDEX aireas_airbox_sensor_tick_flags_at_idx
  ON public.aireas_airbox_sensor_tick_flags
  USING btree
  (airbox COLLATE pg_catalog."default", sensor_type, tick_date);


