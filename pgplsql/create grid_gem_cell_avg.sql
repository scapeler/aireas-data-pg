--drop table grid_gem_cell_avg;
--CREATE SEQUENCE public.grid_gem_cell_avg_gid_seq
--  INCREMENT 1
--  MINVALUE 1
--  MAXVALUE 9223372036854775807
--  START 1
--  CACHE 1;
--ALTER TABLE public.grid_gem_cell_avg_gid_seq
--  OWNER TO postgres;
create table public.grid_gem_cell_avg (
  gid integer NOT NULL DEFAULT nextval('grid_gem_cell_avg_gid_seq'::regclass),
  grid_gem_cell_gid integer NOT NULL,
  retrieveddate timestamp with time zone,
  avg_pm1_hr numeric NOT NULL,
  avg_pm25_hr numeric NOT NULL,
  avg_pm10_hr numeric NOT NULL,
  avg_pm_all_hr numeric NOT NULL,
  creation_date timestamp with time zone,
  CONSTRAINT grid_gem_cell_avg_pkey PRIMARY KEY (gid)
)
WITH (
  OIDS=FALSE
);
ALTER TABLE public.grid_gem_cell_avg
  OWNER TO postgres;
CREATE INDEX grid_gem_cell_avg_grid_gem_cell_gid_idx
  ON public.grid_gem_cell_avg
  USING btree
  (grid_gem_cell_gid);
CREATE INDEX grid_gem_cell_avg_retrieveddate_idx
  ON public.grid_gem_cell_avg
  USING btree
  (retrieveddate);