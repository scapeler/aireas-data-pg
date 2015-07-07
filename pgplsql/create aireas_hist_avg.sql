-- Table: public.aireas_hist_avg

-- DROP TABLE public.aireas_hist_avg;
--CREATE SEQUENCE public.aireas_hist_avg_gid_seq
--  INCREMENT 1
--  MINVALUE 1
--  MAXVALUE 9223372036854775807
--  START 1
--  CACHE 1;
--ALTER TABLE public.aireas_hist_avg_gid_seq
--  OWNER TO postgres;

CREATE TABLE public.aireas_hist_avg
(
  gid integer NOT NULL DEFAULT nextval('aireas_hist_avg_gid_seq'::regclass),
  airbox character varying(255),
  hist_year smallint,
  hist_month smallint,
  hist_day smallint,
  hist_count numeric,
  last_measuredate timestamp with time zone,
  avg_type varchar(60) NOT NULL,
  avg_avg numeric NOT NULL,
  geom geometry(Point),
  creation_date timestamp with time zone,
  CONSTRAINT aireas_hist_avg_pkey PRIMARY KEY (gid)
)
WITH (
  OIDS=FALSE
);
ALTER TABLE public.aireas_hist_avg
  OWNER TO postgres;

-- Index: public.aireas_hist_avg_airbox_idx

-- DROP INDEX public.aireas_hist_avg_airbox_idx;

CREATE INDEX aireas_hist_avg_airbox_idx
  ON public.aireas_hist_avg
  USING btree
  (airbox COLLATE pg_catalog."default");

-- Index: public.aireas_hist_avg_period_idx

-- DROP INDEX public.aireas_hist_avg_period_idx;

CREATE INDEX aireas_hist_avg_period_idx
  ON public.aireas_hist_avg
  USING btree
  (hist_year, hist_month, hist_day);

-- Index: public.aireas_hist_avg_geom_gist

-- DROP INDEX public.aireas_hist_avg_geom_gist;

CREATE INDEX aireas_hist_avg_geom_gist
  ON public.aireas_hist_avg
  USING gist
  (geom);
