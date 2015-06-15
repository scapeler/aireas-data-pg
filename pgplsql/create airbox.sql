--drop table airbox;
--CREATE SEQUENCE public.airbox_gid_seq
--  INCREMENT 1
--  MINVALUE 1
--  MAXVALUE 9223372036854775807
--  START 1
--  CACHE 1;
--ALTER TABLE public.airbox_gid_seq
--  OWNER TO postgres;
create table public.airbox (
  gid integer NOT NULL DEFAULT nextval('airbox_gid_seq'::regclass),
  airbox character varying(255) NOT NULL,
  airbox_location_desc character varying(255) NOT NULL,
  airbox_type character varying(255),
  lat double precision,
  lng double precision,
  lat_calculated double precision,
  lng_calculated double precision,
  geom geometry(Point) NOT NULL,
  mutation_date timestamp with time zone  NOT NULL,
  creation_date timestamp with time zone  NOT NULL,
  CONSTRAINT airbox_pkey PRIMARY KEY (gid)
)
WITH (
  OIDS=FALSE
);
ALTER TABLE public.airbox
  OWNER TO postgres;
CREATE INDEX airbox_airbox_idx
  ON public.airbox
  USING btree
  (airbox);
CREATE INDEX airbox_geom_gist
  ON public.airbox
  USING gist
  (geom);