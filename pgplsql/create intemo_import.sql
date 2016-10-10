-- Table: public.intemo_import

-- DROP TABLE public.intemo_import;
--CREATE SEQUENCE public.intemo_import_gid_seq
--  INCREMENT 1
--  MINVALUE 1
--  MAXVALUE 9223372036854775807
--  START 1
--  CACHE 1;
--ALTER TABLE public.intemo_import_gid_seq
--  OWNER TO postgres;

CREATE TABLE public.intemo_import
(
  gid integer NOT NULL DEFAULT nextval('intemo_import_gid_seq'::regclass),
  fid character varying(255),
  measurement_id integer,
  insert_date timestamp with time zone,
  device_id character varying(50),
  sensor_name character varying(50),
  sensor_label character varying(50),
  sensor_unit character varying(50),
  measurement_date timestamp with time zone,
  measurement_day timestamp with time zone,
  measurement_hour integer,
  value_min double precision,
  value_max double precision,
  value_raw double precision,
  sensor_value double precision,
  sample_count double precision,
--  tick_date timestamp with time zone,
  point character varying(255),
  lat double precision,
  lng double precision,
  altitude double precision,
  geom geometry(Point),
  geom28992 geometry(Point,28992),
--  flag_date timestamp with time zone,
--  flag_code character varying(16),
--  flag_value character varying(255),
--  flag_remarks character varying(255),
  CONSTRAINT intemo_import_pkey PRIMARY KEY (gid)
)
WITH (
  OIDS=FALSE
);
ALTER TABLE public.intemo_import
  OWNER TO postgres;

-- Index: public.intemo_import_device_id_idx

-- DROP INDEX public.intemo_import_device_id_idx;

CREATE INDEX intemo_import_device_id_idx
  ON public.intemo_import
  USING btree
  (device_id COLLATE pg_catalog."default", measurement_date);

-- Index: public.intemo_import_geom_gist

-- DROP INDEX public.intemo_import_geom_gist;

CREATE INDEX intemo_import_geom_gist
  ON public.intemo_import
  USING gist
  (geom);

-- Index: public.idx_intemo_import_geom28992

-- DROP INDEX public.idx_intemo_import_geom28992;

CREATE INDEX idx_intemo_import_geom28992
  ON public.intemo_import
  USING gist
  (geom28992);

