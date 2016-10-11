--drop table grid_gem_foi_aqi;
--CREATE SEQUENCE public.grid_gem_foi_aqi_gid_seq
--  INCREMENT 1
--  MINVALUE 1
--  MAXVALUE 9223372036854775807
--  START 1
--  CACHE 1;
--ALTER TABLE public.grid_gem_foi_aqi_gid_seq
--  OWNER TO postgres;
create table public.grid_gem_foi_aqi (
  gid integer NOT NULL DEFAULT nextval('grid_gem_foi_aqi_gid_seq'::regclass),
  grid_code character varying(15) NOT NULL,
  feature_of_interest character varying(255) NOT NULL,
  retrieveddate timestamp with time zone,
  avg_aqi_type varchar(60) NOT NULL,
  avg_type varchar(60) NOT NULL,
  avg_period varchar(24) NOT NULL,  -- 30min, 1hr, 8hr, 12hr, 24hr
  avg_avg numeric,
  avg_aqi numeric NOT NULL,
  creation_date timestamp with time zone,
  CONSTRAINT grid_gem_foi_aqi_pkey PRIMARY KEY (gid)
)
WITH (
  OIDS=FALSE
);
ALTER TABLE public.grid_gem_foi_aqi
  OWNER TO postgres;
CREATE INDEX grid_gem_foi_aqi_foi_retrdate_idx
  ON public.grid_gem_foi_aqi
  USING btree
  (feature_of_interest, retrieveddate);
CREATE INDEX grid_gem_foi_aqi_retrieveddate_idx
  ON public.grid_gem_foi_aqi
  USING btree
  (retrieveddate);

