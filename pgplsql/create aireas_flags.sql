/*

flags:

INSERT INTO aireas_flags (flag_code,flag_description) VALUES ( 'Lifetime', 'lifetime exceeded');
INSERT INTO aireas_flags (flag_code,flag_description) VALUES ( 'CalcValLow', 'calculated value too low');
INSERT INTO aireas_flags (flag_code,flag_description) VALUES ( 'CalcValHigh', 'calculated value too high');
INSERT INTO aireas_flags (flag_code,flag_description) VALUES ( 'Outlyer','outlyer');
INSERT INTO aireas_flags (flag_code,flag_description) VALUES ( 'Shift','Shift');
INSERT INTO aireas_flags (flag_code,flag_description) VALUES ( 'RawValLow','raw sensor value too low');
INSERT INTO aireas_flags (flag_code,flag_description) VALUES ( 'RawValHigh','raw sensor value too high');
INSERT INTO aireas_flags (flag_code,flag_description) VALUES ( 'NoiseLow','noise level too low');
INSERT INTO aireas_flags (flag_code,flag_description) VALUES ( 'NoiseHigh','noise level too high');
INSERT INTO aireas_flags (flag_code,flag_description) VALUES ( 'ABTempRange','airbox temperature out of range');
INSERT INTO aireas_flags (flag_code,flag_description) VALUES ( 'ABRHumRange','airbox relative humidity out of range');
INSERT INTO aireas_flags (flag_code,flag_description) VALUES ( 'PHigh','too many particles');
INSERT INTO aireas_flags (flag_code,flag_description) VALUES ( 'PLow','not enough particles');
INSERT INTO aireas_flags (flag_code,flag_description) VALUES ( 'BaseLinePm','baseline issue PM');
INSERT INTO aireas_flags (flag_code,flag_description) VALUES ( 'BaseLineNo2','baseline issue NO2');
INSERT INTO aireas_flags (flag_code,flag_description) VALUES ( 'DiffRhNo2High','difference rH NO2 sensor too large');
INSERT INTO aireas_flags (flag_code,flag_description) VALUES ( 'NrSensOzonLow','not enough ozon sensors operational');


*/

-- select * from aireas_flags;


-- Table: public.aireas_flags

-- DROP TABLE public.aireas_flags;
--CREATE SEQUENCE public.aireas_flags_gid_seq
--  INCREMENT 1
--  MINVALUE 1
--  MAXVALUE 9223372036854775807
--  START 1
--  CACHE 1;
--ALTER TABLE public.aireas_flags_gid_seq
--  OWNER TO postgres;

CREATE TABLE public.aireas_flags
(
  gid integer NOT NULL DEFAULT nextval('aireas_flags_gid_seq'::regclass),
  flag_code character varying(255),
  flag_description character varying(255),
  CONSTRAINT aireas_flags_pkey PRIMARY KEY (gid)
)
WITH (
  OIDS=FALSE
);
ALTER TABLE public.aireas_flags
  OWNER TO postgres;

-- Index: public.aireas_flag_code_idx

-- DROP INDEX public.aireas_flag_code_idx;

CREATE UNIQUE INDEX aireas_flag_code_idx
  ON public.aireas_flags
  USING btree
  (flag_code COLLATE pg_catalog."default");


