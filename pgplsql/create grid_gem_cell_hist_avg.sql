--drop table grid_gem_cell_hist_avg;
--CREATE SEQUENCE public.grid_gem_cell_hist_avg_gid_seq
--  INCREMENT 1
--  MINVALUE 1
--  MAXVALUE 9223372036854775807
--  START 1
--  CACHE 1;
--ALTER TABLE public.grid_gem_cell_hist_avg_gid_seq
--  OWNER TO postgres;
create table public.grid_gem_cell_hist_avg (
  gid integer NOT NULL DEFAULT nextval('grid_gem_cell_hist_avg_gid_seq'::regclass),
  grid_gem_cell_gid integer NOT NULL,
  hist_year smallint,
  hist_month smallint,
  hist_day smallint,
  hist_count numeric,
  avg_type varchar(60) NOT NULL,
  avg_avg numeric NOT NULL,
  creation_date timestamp with time zone,
  CONSTRAINT grid_gem_cell_hist_avg_pkey PRIMARY KEY (gid)
)
WITH (
  OIDS=FALSE
);
ALTER TABLE public.grid_gem_cell_hist_avg
  OWNER TO postgres;
CREATE INDEX grid_gem_cell_hist_avg_grid_gem_cell_gid_idx
  ON public.grid_gem_cell_hist_avg
  USING btree
  (grid_gem_cell_gid);
  
-- Index: public.grid_gem_cell_hist_avg_period_idx

-- DROP INDEX public.grid_gem_cell_hist_avg_period_idx;

CREATE INDEX grid_gem_cell_hist_avg_period_idx
  ON public.grid_gem_cell_hist_avg
  USING btree
  (hist_year, hist_month, hist_day);  
  