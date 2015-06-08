-- Table: public.aireas

-- DROP TABLE public.aireas;
--CREATE SEQUENCE public.aireas_gid_seq
--  INCREMENT 1
--  MINVALUE 1
--  MAXVALUE 9223372036854775807
--  START 1
--  CACHE 1;
--ALTER TABLE public.aireas_gid_seq
--  OWNER TO postgres;

CREATE TABLE public.aireas
(
  gid integer NOT NULL DEFAULT nextval('aireas_gid_seq'::regclass),
  airbox character varying(255),
  retrieveddatechar character varying(60),
  measuredatechar character varying(60),
  retrieveddate timestamp with time zone,
  measuredate timestamp with time zone,
  gpslat character varying(60),
  gpslng character varying(60),
  lat double precision,
  lng double precision,
  pm1 character varying(60),
  pm25 character varying(60),
  pm10 character varying(60),
  ufp character varying(60),
  ozon character varying(60),
  hum character varying(60),
  celc character varying(60),
  no2 character varying(60),
  gpslatfloat double precision,
  gpslngfloat double precision,
  pm1float double precision,
  pm25float double precision,
  pm10float double precision,
  ufpfloat double precision,
  ozonfloat double precision,
  humfloat double precision,
  celcfloat double precision,
  no2float double precision,
  geom geometry(Point),
  geom28992 geometry(Point,28992),
  CONSTRAINT aireas_pkey PRIMARY KEY (gid)
)
WITH (
  OIDS=FALSE
);
ALTER TABLE public.aireas
  OWNER TO postgres;

-- Index: public.aireas_airbox_idx

-- DROP INDEX public.aireas_airbox_idx;

CREATE INDEX aireas_airbox_idx
  ON public.aireas
  USING btree
  (airbox COLLATE pg_catalog."default");

-- Index: public.aireas_geom_gist

-- DROP INDEX public.aireas_geom_gist;

CREATE INDEX aireas_geom_gist
  ON public.aireas
  USING gist
  (geom);

-- Index: public.aireas_retrieveddate_idx

-- DROP INDEX public.aireas_retrieveddate_idx;

CREATE INDEX aireas_retrieveddate_idx
  ON public.aireas
  USING btree
  (retrieveddate);

-- Index: public.idx_aireas_geom28992

-- DROP INDEX public.idx_aireas_geom28992;

CREATE INDEX idx_aireas_geom28992
  ON public.aireas
  USING gist
  (geom28992);

