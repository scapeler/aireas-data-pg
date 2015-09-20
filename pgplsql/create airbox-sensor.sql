--drop table airbox-sensor;
--CREATE SEQUENCE public.airbox_sensor_gid_seq
--  INCREMENT 1
--  MINVALUE 1
--  MAXVALUE 9223372036854775807
--  START 1
--  CACHE 1;
--ALTER TABLE public.airbox_sensor_gid_seq
--  OWNER TO postgres;
create table public.airbox_sensor (
  gid integer NOT NULL DEFAULT nextval('airbox_gid_seq'::regclass),
  airbox character varying(255) NOT NULL,
  sensor character varying(255),
  start_date timestamp with time zone NOT NULL,
  airbox_type character varying(255),
  sensor_type character varying(255),
  status character varying(50),
  description character varying(255),
  comment character varying(255),
  geom geometry(Point),
  mutation_date timestamp with time zone NOT NULL,
  creation_date timestamp with time zone NOT NULL,
  CONSTRAINT airbox_sensor_pkey PRIMARY KEY (gid)
)
WITH (
  OIDS=FALSE
);
ALTER TABLE public.airbox_sensor
  OWNER TO postgres;
CREATE INDEX airbox_sensor_airbox_sensor_start_date_idx
  ON public.airbox_sensor
  USING btree
  (airbox, sensor, start_date);
CREATE INDEX airbox_sensor_geom_gist
  ON public.airbox_sensor
  USING gist
  (geom);