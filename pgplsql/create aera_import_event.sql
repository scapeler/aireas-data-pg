-- Table: public.aera_import_event

-- DROP TABLE public.aera_import_event;
--CREATE SEQUENCE public.aera_import_event_gid_seq
--  INCREMENT 1
--  MINVALUE 1
--  MAXVALUE 9223372036854775807
--  START 1
--  CACHE 1;
--ALTER TABLE public.aera_import_event_gid_seq
--  OWNER TO postgres;

CREATE TABLE public.aera_import_event
(
  gid integer NOT NULL DEFAULT nextval('aera_import_event_gid_seq'::regclass),
  foi_code character varying(255),
--  tick_date timestamp with time zone,
  event_date timestamp with time zone,
  event_day character varying(50),
  event_time character varying(50),
  event_desc character varying(512),
  event_remarks character varying(512),
  lat double precision,
  lng double precision,
  geom geometry(Point),
  geom28992 geometry(Point,28992),
--  flag_date timestamp with time zone,
--  flag_code character varying(16),
--  flag_value character varying(255),
--  flag_remarks character varying(255),
  CONSTRAINT aera_import_event_pkey PRIMARY KEY (gid)
)
WITH (
  OIDS=FALSE
);
ALTER TABLE public.aera_import_event
  OWNER TO postgres;

-- Index: public.aera_import_event_foi_code_idx

-- DROP INDEX public.aera_import_event_foi_code_idx;

CREATE INDEX aera_import_event_foi_code_idx
  ON public.aera_import_event
  USING btree
  (foi_code COLLATE pg_catalog."default", event_date);

-- Index: public.aera_import_event_geom_gist

-- DROP INDEX public.aera_import_event_geom_gist;

CREATE INDEX aera_import_event_geom_gist
  ON public.aera_import_event
  USING gist
  (geom);

-- Index: public.idx_aera_import_event_geom28992

-- DROP INDEX public.idx_aera_import_event_geom28992;

CREATE INDEX idx_aera_import_event_geom28992
  ON public.aera_import_event
  USING gist
  (geom28992);

