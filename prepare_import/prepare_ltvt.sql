-- We dump whole lbm.schema so CREATE SCHEMA command is already there
--CREATE SCHEMA IF NOT EXISTS lbm;'
-- Create users that are required for import ltvt and bgdi
--CREATE USER postgres;
--CREATE USER readwrite;
--CREATE USER "www-data";
--CREATE USER vt_writer;
-- These extensions are already loaded by the parent docker
CREATE EXTENSION IF NOT EXISTS postgis;
CREATE EXTENSION IF NOT EXISTS fuzzystrmatch;
-- Extensions needed for OpenMapTiles
CREATE EXTENSION IF NOT EXISTS hstore;
CREATE EXTENSION IF NOT EXISTS unaccent;
CREATE EXTENSION IF NOT EXISTS osml10n;
CREATE EXTENSION IF NOT EXISTS gzip;
CREATE EXTENSION IF NOT EXISTS dblink;