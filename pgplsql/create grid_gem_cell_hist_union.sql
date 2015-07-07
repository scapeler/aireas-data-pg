
--drop table grid_gem_cell_hist_union;
--CREATE SEQUENCE public.grid_gem_cell_hist_union_gid_seq
--  INCREMENT 1
--  MINVALUE 1
--  MAXVALUE 9223372036854775807
--  START 1
--  CACHE 1;
--ALTER TABLE public.grid_gem_cell_hist_union_gid_seq
--  OWNER TO postgres;
create table public.grid_gem_cell_hist_union (
  gid integer NOT NULL DEFAULT nextval('grid_gem_cell_hist_union_gid_seq'::regclass),
  grid_gem_cell_gid integer NOT NULL,
  hist_year smallint,
  hist_month smallint,
  hist_day smallint,
  hist_count numeric,
  avg_type character varying(60),
  avg_avg numeric NOT NULL,  
  creation_date timestamp with time zone,
  union_geom geometry,
  CONSTRAINT grid_gem_cell_hist_union_pkey PRIMARY KEY (gid)
)
WITH (
  OIDS=FALSE
);
ALTER TABLE public.grid_gem_cell_hist_union
  OWNER TO postgres;
CREATE INDEX grid_gem_cell_hist_union_grid_gem_cell_gid_idx
  ON public.grid_gem_cell_hist_union
  USING btree
  (grid_gem_cell_gid);
 
CREATE INDEX grid_gem_cell_hist_union_geom_gist
  ON public.grid_gem_cell_hist_union
  USING gist
  (union_geom);
  
-- Index: public.grid_gem_cell_hist_union_period_idx

-- DROP INDEX public.grid_gem_cell_hist_union_period_idx;

CREATE INDEX grid_gem_cell_hist_union_period_idx
  ON public.grid_gem_cell_hist_union
  USING btree
  (hist_year, hist_month, hist_day);    