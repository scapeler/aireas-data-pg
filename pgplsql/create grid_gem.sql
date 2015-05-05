-- Table: public.grid_gem

-- DROP TABLE public.grid_gem;

CREATE TABLE public.grid_gem
(
  grid_code character varying(15) NOT NULL,
  grid_desc character varying(60) NOT NULL,
  gm_code character varying(6) NOT NULL,
  gm_naam character varying(60) NOT NULL,
  mutation_date timestamp with time zone NOT NULL,
  creation_date timestamp with time zone NOT NULL,
  CONSTRAINT grid_gem_pkey PRIMARY KEY (grid_code)
)
WITH (
  OIDS=FALSE
);
ALTER TABLE public.grid_gem
  OWNER TO postgres;

-- Index: public.grid_gem_gm_code_idx

-- DROP INDEX public.grid_gem_gm_code_idx;

CREATE INDEX grid_gem_gm_code_idx
  ON public.grid_gem
  USING btree
  (gm_code COLLATE pg_catalog."default");

