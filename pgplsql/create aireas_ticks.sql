-- Table: public.aireas_ticks

-- DROP TABLE public.aireas_ticks;
--CREATE SEQUENCE public.aireas_ticks_gid_seq
--  INCREMENT 1
--  MINVALUE 1
--  MAXVALUE 9223372036854775807
--  START 1
--  CACHE 1;
--ALTER TABLE public.aireas_ticks_gid_seq
--  OWNER TO postgres;

CREATE TABLE public.aireas_ticks
(
  gid integer NOT NULL DEFAULT nextval('aireas_ticks_gid_seq'::regclass),
  airbox character varying(255),
  tickdate timestamp with time zone,
  CONSTRAINT aireas_ticks_pkey PRIMARY KEY (gid)
)
WITH (
  OIDS=FALSE
);
ALTER TABLE public.aireas_ticks
  OWNER TO postgres;

-- Index: public.aireas_airbox_ticks_idx

-- DROP INDEX public.aireas_airbox_ticks_idx;

CREATE UNIQUE INDEX aireas_airbox_ticks_idx
  ON public.aireas_ticks
  USING btree
  (airbox COLLATE pg_catalog."default", tickdate);


