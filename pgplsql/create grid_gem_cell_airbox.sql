--drop table grid_gem_cell_airbox;
--CREATE SEQUENCE public.grid_gem_cell_airbox_gid_seq
--  INCREMENT 1
--  MINVALUE 1
--  MAXVALUE 9223372036854775807
--  START 1
--  CACHE 1;
--ALTER TABLE public.grid_gem_cell_airbox_gid_seq
--  OWNER TO postgres;
create table public.grid_gem_cell_airbox (
  gid integer NOT NULL DEFAULT nextval('grid_gem_cell_airbox_gid_seq'::regclass),
  grid_gem_cell_gid integer NOT NULL,
  airbox character varying(255) NOT NULL,
  airbox_geom geometry(Point),
  factor_location numeric NOT NULL,
  factor_distance numeric NOT NULL,
  creation_date timestamp with time zone,
  CONSTRAINT grid_gem_cell_airbox_pkey PRIMARY KEY (gid)
)
WITH (
  OIDS=FALSE
);
ALTER TABLE public.grid_gem_cell_airbox
  OWNER TO postgres;
CREATE INDEX grid_gem_grid_cell_airbox_cell_gid_idx
  ON public.grid_gem_cell_airbox
  USING btree
  (grid_gem_cell_gid);
CREATE INDEX grid_gem_grid_cell_airbox_airbox_idx
  ON public.grid_gem_cell_airbox
  USING btree
  (airbox);