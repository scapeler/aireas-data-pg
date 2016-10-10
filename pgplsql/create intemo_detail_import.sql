-- Table: public.intemo_detail_import

-- DROP TABLE public.intemo_detail_import;
--CREATE SEQUENCE public.intemo_detail_import_gid_seq
--  INCREMENT 1
--  MINVALUE 1
--  MAXVALUE 9223372036854775807
--  START 1
--  CACHE 1;
--ALTER TABLE public.intemo_detail_import_gid_seq
--  OWNER TO postgres;

CREATE TABLE public.intemo_detail_import
(
  gid integer NOT NULL DEFAULT nextval('intemo_detail_import_gid_seq'::regclass),
  device_id character varying(50),
  measurement_date timestamp with time zone,
  v_audio_9 double precision,
  u_audio_9 double precision,
  t_audio_9 double precision,
  v_audio_8 double precision,
  u_audio_8 double precision,
  t_audio_8 double precision,
  v_audio_7 double precision,
  u_audio_7 double precision,
  t_audio_7 double precision,
  v_audio_6 double precision,
  u_audio_6 double precision,
  t_audio_6 double precision,
  v_audio_5 double precision,
  u_audio_5 double precision,
  t_audio_5 double precision,
  v_audio_4 double precision,
  u_audio_4 double precision,
  t_audio_4 double precision,
  v_audio_3 double precision,
  u_audio_3 double precision,
  t_audio_3 double precision,
  v_audio_2 double precision,
  u_audio_2 double precision,
  t_audio_2 double precision,
  v_audio_1 double precision,
  u_audio_1 double precision,
  t_audio_1 double precision,
  v_audio_0 double precision,
  u_audio_0 double precision,
  t_audio_0 double precision,
--  geom geometry(Point),
--  geom28992 geometry(Point,28992),
--  flag_date timestamp with time zone,
--  flag_code character varying(16),
--  flag_value character varying(255),
--  flag_remarks character varying(255),
  CONSTRAINT intemo_detail_import_pkey PRIMARY KEY (gid)
)
WITH (
  OIDS=FALSE
);
ALTER TABLE public.intemo_detail_import
  OWNER TO postgres;

-- Index: public.intemo_detail_import_device_id_idx

-- DROP INDEX public.intemo_detail_import_device_id_idx;

CREATE INDEX intemo_detail_import_device_id_idx
  ON public.intemo_detail_import
  USING btree
  (device_id COLLATE pg_catalog."default", measurement_date);

-- Index: public.intemo_detail_import_geom_gist

/*
-- DROP INDEX public.intemo_detail_import_geom_gist;

CREATE INDEX intemo_detail_import_geom_gist
  ON public.intemo_detail_import
  USING gist
  (geom);

-- Index: public.idx_intemo_detail_import_geom28992

-- DROP INDEX public.idx_intemo_detail_import_geom28992;

CREATE INDEX idx_intemo_detail_import_geom28992
  ON public.intemo_detail_import
  USING gist
  (geom28992);
*/
