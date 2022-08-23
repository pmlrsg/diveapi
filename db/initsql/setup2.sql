-- Adminer 4.8.1 PostgreSQL 11.12 (Debian 11.12-1.pgdg90+1) dump
create database dive;

\connect "dive";

CREATE SEQUENCE region_id_seq INCREMENT 1 MINVALUE 1 MAXVALUE 2147483647 CACHE 1;

CREATE TABLE "public"."region" (
    "id" integer DEFAULT nextval('region_id_seq') NOT NULL,
    "name" character varying NOT NULL,
    "description" text NOT NULL,
    "status" text DEFAULT 'new' NOT NULL,
    "create_time" timestamp DEFAULT now(),
    "minx" real,
    "miny" real,
    "maxx" real,
    "maxy" real,
    CONSTRAINT "region_pkey" PRIMARY KEY ("id")
) WITH (oids = false);

CREATE SEQUENCE score_id_seq INCREMENT 1 MINVALUE 1 MAXVALUE 2147483647 START 281 CACHE 1;

CREATE TABLE "public"."score" (
    "id" integer DEFAULT nextval('score_id_seq') NOT NULL,
    "site_id" integer,
    "value" double precision,
    "create_time" timestamp DEFAULT now(),
    "score_date" date DEFAULT now(),
    CONSTRAINT "score_pkey" PRIMARY KEY ("id"),
    CONSTRAINT "unique_score_date" UNIQUE ("site_id", "score_date")
) WITH (oids = false);

CREATE SEQUENCE site_id_seq INCREMENT 1 MINVALUE 1 MAXVALUE 2147483647 START 72 CACHE 1;

CREATE OR REPLACE FUNCTION score_changed() RETURNS TRIGGER
    LANGUAGE plpgsql
    AS $$
BEGIN
    NEW.create_time := now();
    RETURN NEW;
END;
$$;

CREATE TRIGGER "trigger_updated" BEFORE UPDATE ON "public"."score" FOR EACH ROW EXECUTE PROCEDURE score_changed();;



CREATE TABLE "public"."site" (
    "id" integer DEFAULT nextval('site_id_seq') NOT NULL,
    "name" character varying NOT NULL,
    "description" text NOT NULL,
    "region" integer DEFAULT '0',
    "latitude" double precision,
    "longitude" double precision,
    "create_time" timestamp DEFAULT now(),
    "modify_time" timestamp,
    "latest_score" double precision,
    "score_time" timestamp,
    "status" text DEFAULT 'new' NOT NULL,
    "zoom_level" integer DEFAULT 0,
    CONSTRAINT "site_pkey" PRIMARY KEY ("id")
) WITH (oids = false);



CREATE OR REPLACE FUNCTION site_changed() RETURNS TRIGGER
    LANGUAGE plpgsql
    AS $$
BEGIN
    NEW.modify_time := now();
    RETURN NEW;
END;
$$;

CREATE TRIGGER "trigger_updated" BEFORE UPDATE ON "public"."site" FOR EACH ROW EXECUTE PROCEDURE site_changed();;

CREATE TABLE "public"."valid_record_status" (
    "status" text NOT NULL,
    CONSTRAINT "valid_record_status_pk" PRIMARY KEY ("status")
) WITH (oids = false);

INSERT INTO "valid_record_status" ("status") VALUES
('new'),
('updated'),
('public'),
('deleted');

CREATE SEQUENCE parameter_id_seq INCREMENT 1 MINVALUE 1 MAXVALUE 2147483647 CACHE 1;

CREATE TABLE "public"."parameter" (
    "id" integer DEFAULT nextval('parameter_id_seq') NOT NULL,
    "site_id" integer NOT NULL,
    "name" character varying NOT NULL,
    "float_value" double precision,
    "string_value" character varying,
    "sample_time" timestamp NOT NULL,
    "update_time" timestamp DEFAULT now() NOT NULL,
    CONSTRAINT "parameter_site_id_name_sample_time" PRIMARY KEY ("site_id", "name", "sample_time")
) WITH (oids = false);

CREATE OR REPLACE FUNCTION parameter_changed() RETURNS TRIGGER
    LANGUAGE plpgsql
    AS $$
BEGIN
    NEW.update_time := now();
    RETURN NEW;
END;
$$;

CREATE TRIGGER "trigger_updated" BEFORE UPDATE ON "public"."parameter" FOR EACH ROW EXECUTE PROCEDURE parameter_changed();;


ALTER TABLE ONLY "public"."parameter" ADD CONSTRAINT "parameter_site_id_fkey" FOREIGN KEY (site_id) REFERENCES site(id) NOT DEFERRABLE;

ALTER TABLE ONLY "public"."region" ADD CONSTRAINT "region_status_fkey" FOREIGN KEY (status) REFERENCES valid_record_status(status) ON UPDATE CASCADE NOT DEFERRABLE;

ALTER TABLE ONLY "public"."score" ADD CONSTRAINT "score_site_fkey" FOREIGN KEY (site_id) REFERENCES site(id) NOT DEFERRABLE;

ALTER TABLE ONLY "public"."site" ADD CONSTRAINT "site_location_fkey" FOREIGN KEY (region) REFERENCES region(id) ON UPDATE CASCADE NOT DEFERRABLE;
ALTER TABLE ONLY "public"."site" ADD CONSTRAINT "site_status_fkey" FOREIGN KEY (status) REFERENCES valid_record_status(status) ON UPDATE CASCADE NOT DEFERRABLE;

-- 2021-08-17 11:05:55.393056+00
create role diveapi with login password 'installpw' ;
REVOKE ALL ON DATABASE dive from public ;
REVOKE ALL on SCHEMA public from public ;
GRANT ALL ON SCHEMA public to diveapi ;
alter default privileges in schema public grant all on tables to diveapi ;
grant CONNECT on DATABASE dive to diveapi ;
grant ALL ON ALL TABLES IN SCHEMA public to diveapi ;
grant ALL ON ALL SEQUENCES IN SCHEMA public to diveapi ;
grant ALL ON ALL FUNCTIONS IN SCHEMA public to diveapi ;

