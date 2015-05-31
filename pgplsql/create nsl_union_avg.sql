--drop table nsl_union_avg;
--CREATE SEQUENCE public.nsl_union_avg_gid_seq
--  INCREMENT 1
--  MINVALUE 1
--  MAXVALUE 9223372036854775807
--  START 1
--  CACHE 1;
--ALTER TABLE public.nsl_union_avg_gid_seq
--  OWNER TO postgres;
create table public.nsl_union_avg (
  gid integer NOT NULL DEFAULT nextval('nsl_union_avg_gid_seq'::regclass),
  mronde character varying(6),
  rekenjaar character varying(4),
  spmi_avg numeric NOT NULL,
  geom geometry,
  creation_date timestamp with time zone,
  CONSTRAINT nsl_union_avg_pkey PRIMARY KEY (gid)
)
WITH (
  OIDS=FALSE
);
ALTER TABLE public.nsl_union_avg
  OWNER TO postgres;
CREATE INDEX nsl_union_avg_rekenjaar_idx
  ON public.nsl_union_avg
  USING btree
  (rekenjaar);
CREATE INDEX nsl_union_avg_geom_gist
  ON public.nsl_union_avg
  USING gist
  (geom);   
