
--drop table grid_gem_cell_union;
--CREATE SEQUENCE public.grid_gem_cell_union_gid_seq
--  INCREMENT 1
--  MINVALUE 1
--  MAXVALUE 9223372036854775807
--  START 1
--  CACHE 1;
--ALTER TABLE public.grid_gem_cell_union_gid_seq
--  OWNER TO postgres;
create table public.grid_gem_cell_union (
  gid integer NOT NULL DEFAULT nextval('grid_gem_cell_union_gid_seq'::regclass),
  grid_gem_cell_gid integer NOT NULL,
  retrieveddate timestamp with time zone,
  avg_pm1_hr numeric NOT NULL,
  avg_pm25_hr numeric NOT NULL,
  avg_pm10_hr numeric NOT NULL,
  avg_pm_all_hr numeric NOT NULL,
  creation_date timestamp with time zone,
  union_geom geometry,
  CONSTRAINT grid_gem_cell_union_pkey PRIMARY KEY (gid)
)
WITH (
  OIDS=FALSE
);
ALTER TABLE public.grid_gem_cell_union
  OWNER TO postgres;
CREATE INDEX grid_gem_cell_union_grid_gem_cell_gid_idx
  ON public.grid_gem_cell_union
  USING btree
  (grid_gem_cell_gid);
CREATE INDEX grid_gem_cell_union_retrieveddate_idx
  ON public.grid_gem_cell_union
  USING btree
  (retrieveddate);  
CREATE INDEX grid_gem_cell_union_geom_gist
  ON public.grid_gem_cell_union
  USING gist
  (union_geom);