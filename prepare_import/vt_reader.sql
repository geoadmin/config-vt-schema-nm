-- Grant read-only privileges in lbm schema to vt_reader user
GRANT USAGE ON SCHEMA lbm TO vt_reader;
GRANT SELECT ON ALL TABLES IN SCHEMA lbm TO vt_reader;
ALTER DEFAULT PRIVILEGES IN SCHEMA lbm GRANT SELECT ON TABLES TO vt_reader;
