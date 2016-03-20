-- Table: public.ILM0102VH01

-- DROP TABLE public.ILM0102VH01;
--CREATE SEQUENCE public.ILM0102VH01_gid_seq
--  INCREMENT 1
--  MINVALUE 1
--  MAXVALUE 9223372036854775807
--  START 1
--  CACHE 1;
--ALTER TABLE public.ILM0102VH01_gid_seq
--  OWNER TO postgres;

CREATE TABLE public.ILM0102VH01
(
  gid integer NOT NULL DEFAULT nextval('ILM0102VH01_gid_seq'::regclass),
  airbox character varying(255),
  tick_date timestamp with time zone,
  measure_date timestamp with time zone,
  lat double precision,
  lng double precision,
  gpslat double precision,
  gpslng double precision,
  pm1 double precision,
  pm25 double precision,
  pm10 double precision,
  ufp double precision,
  ozone double precision,
  rhum double precision,
  temp double precision,
  rhumext double precision,
  tempext double precision,
  no2 double precision,
  geom geometry(Point),
  geom28992 geometry(Point,28992),
  flag_date timestamp with time zone,
  flag_code character varying(16),
  flag_value character varying(255),
  flag_remarks character varying(255),
  CONSTRAINT ILM0102VH01_pkey PRIMARY KEY (gid)
)
WITH (
  OIDS=FALSE
);
ALTER TABLE public.ILM0102VH01
  OWNER TO postgres;

-- Index: public.ILM0102VH01_airbox_idx

-- DROP INDEX public.ILM0102VH01_airbox_idx;

CREATE INDEX ILM0102VH01_airbox_idx
  ON public.ILM0102VH01
  USING btree
  (airbox COLLATE pg_catalog."default", tick_date);

-- Index: public.ILM0102VH01_geom_gist

-- DROP INDEX public.ILM0102VH01_geom_gist;

CREATE INDEX ILM0102VH01_geom_gist
  ON public.ILM0102VH01
  USING gist
  (geom);

-- Index: public.idx_ILM0102VH01_geom28992

-- DROP INDEX public.idx_ILM0102VH01_geom28992;

CREATE INDEX idx_ILM0102VH01_geom28992
  ON public.ILM0102VH01
  USING gist
  (geom28992);

