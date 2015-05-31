--drop table smoke_risc_marker;
--CREATE SEQUENCE public.smoke_risc_marker_gid_seq
--  INCREMENT 1
--  MINVALUE 1
--  MAXVALUE 9223372036854775807
--  START 1
--  CACHE 1;
--ALTER TABLE public.smoke_risc_marker_gid_seq
--  OWNER TO postgres;
create table public.smoke_risc_marker (
  gid integer NOT NULL DEFAULT nextval('smoke_risc_marker_gid_seq'::regclass),
  marker_date timestamp with time zone,
  geom geometry('POINT'),
  creation_date timestamp with time zone,
  CONSTRAINT smoke_risc_marker_pkey PRIMARY KEY (gid)
)
WITH (
  OIDS=FALSE
);
ALTER TABLE public.smoke_risc_marker
  OWNER TO postgres;
CREATE INDEX smoke_risc_marker_geom_gist
  ON public.smoke_risc_marker
  USING gist
  (geom);   
