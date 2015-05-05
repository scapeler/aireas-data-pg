--drop table grid_gem_cell;
--CREATE SEQUENCE public.grid_gem_cell_gid_seq
--  INCREMENT 1
--  MINVALUE 1
--  MAXVALUE 9223372036854775807
--  START 1
--  CACHE 1;
--ALTER TABLE public.grid_gem_cell_gid_seq
--  OWNER TO postgres;
create table public.grid_gem_cell (
  gid integer NOT NULL DEFAULT nextval('grid_gem_cell_gid_seq'::regclass),
  grid_code character varying(15) NOT NULL,
  cell_geom geometry,
  cell_centroid_geom geometry(Point),
  cell_x integer,
  cell_y integer,
  wk_code character varying(15),
  bu_code character varying(15),
  creation_date timestamp with time zone,
  CONSTRAINT grid_gem_cell_pkey PRIMARY KEY (gid)
)
WITH (
  OIDS=FALSE
);
ALTER TABLE public.grid_gem_cell
  OWNER TO postgres;
CREATE INDEX grid_gem_grid_cell_id_idx
  ON public.grid_gem_cell
  USING btree
  (grid_code);
CREATE INDEX grid_gem_grid_cell_wk_code_idx
  ON public.grid_gem_cell
  USING btree
  (wk_code);  
CREATE INDEX grid_gem_grid_cell_bu_code_idx
  ON public.grid_gem_cell
  USING btree
  (bu_code);  
CREATE INDEX grid_gem_cell_geom_gist
  ON public.grid_gem_cell
  USING gist
  (cell_geom);  
CREATE INDEX grid_gem_cell_centroid_geom_gist
  ON public.grid_gem_cell
  USING gist
  (cell_centroid_geom);


