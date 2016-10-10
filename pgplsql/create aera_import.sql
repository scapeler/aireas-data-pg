-- Table: public.aera_import

-- DROP TABLE public.aera_import;
--CREATE SEQUENCE public.aera_import_gid_seq
--  INCREMENT 1
--  MINVALUE 1
--  MAXVALUE 9223372036854775807
--  START 1
--  CACHE 1;
--ALTER TABLE public.aera_import_gid_seq
--  OWNER TO postgres;

CREATE TABLE public.aera_import
(
  gid integer NOT NULL DEFAULT nextval('aera_import_gid_seq'::regclass),
  foi_code character varying(255),
--  tick_date timestamp with time zone,
  measurement_date timestamp with time zone,
  lat double precision,
  lng double precision,
  unknown double precision,
  n double precision,
  dpav double precision,
  p double precision,
  file_name character varying(255),
  seqnr double precision,
  geom geometry(Point),
  geom28992 geometry(Point,28992),
--  flag_date timestamp with time zone,
--  flag_code character varying(16),
--  flag_value character varying(255),
--  flag_remarks character varying(255),
  CONSTRAINT aera_import_pkey PRIMARY KEY (gid)
)
WITH (
  OIDS=FALSE
);
ALTER TABLE public.aera_import
  OWNER TO postgres;

-- Index: public.aera_import_foi_code_idx

-- DROP INDEX public.aera_import_foi_code_idx;

CREATE INDEX aera_import_foi_code_idx
  ON public.aera_import
  USING btree
  (foi_code COLLATE pg_catalog."default", measurement_date);

-- Index: public.aera_import_geom_gist

-- DROP INDEX public.aera_import_geom_gist;

CREATE INDEX aera_import_geom_gist
  ON public.aera_import
  USING gist
  (geom);

-- Index: public.idx_aera_import_geom28992

-- DROP INDEX public.idx_aera_import_geom28992;

CREATE INDEX idx_aera_import_geom28992
  ON public.aera_import
  USING gist
  (geom28992);

