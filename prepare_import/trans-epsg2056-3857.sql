-- Create temporary table to store text variable (:schema) for use in functions
DROP TABLE IF EXISTS temp_schema;
create temporary table temp_schema (schema_name text);
insert into temp_schema values (:'schema');

CREATE OR REPLACE FUNCTION transform_table(table_name TEXT, geom_column TEXT, from_proj TEXT, to_proj TEXT) RETURNS VOID
AS $$
DECLARE
    index_name TEXT;
    index_create_sql TEXT;
    schema_name TEXT := (SELECT schema_name from temp_schema);
BEGIN
    -- Get geometry index name of table 
    SELECT
        i.relname
    INTO index_name
    FROM
        pg_class t,
        pg_class i,
        pg_index ix,
        pg_attribute a
    WHERE
        t.oid = ix.indrelid
        AND i.oid = ix.indexrelid
        AND a.attrelid = t.oid
        AND a.attnum = ANY(ix.indkey)
        AND t.relkind = 'r'
        AND t.relname =  table_name
        AND a.attname = geom_column
    ORDER BY
        t.relname,
        i.relname
    LIMIT 1;

    -- Get SQL to recreate index
    SELECT indexdef INTO index_create_sql
    FROM pg_indexes
    WHERE
        indexname = index_name
        AND schemaname = schema_name
    LIMIT 1;

    RAISE NOTICE 'Check table %', table_name;

    -- if there is no index there is also no geom column made by imposm3
    IF index_name IS NOT NULL THEN
        RAISE NOTICE ' - drop CONSTRAINT enforce_srid_the_geom (2056) table %.% ...', schema_name, table_name;
        EXECUTE format('ALTER TABLE %I.%I DROP CONSTRAINT IF EXISTS enforce_srid_the_geom', schema_name, table_name);
        RAISE NOTICE ' - drop index %.% ...', schema_name, index_name;
        EXECUTE format('DROP INDEX IF EXISTS %I.%I', schema_name, index_name);
        RAISE NOTICE ' - transforming table %.% with index % ...', schema_name, table_name, index_name;
        EXECUTE format('ALTER TABLE %I.%I ALTER COLUMN %I TYPE Geometry(Geometry, 3857) USING ST_SetSRID(ST_Transform(%I, %L, %L), 3857)', schema_name, table_name, geom_column, geom_column, from_proj, to_proj);
        RAISE NOTICE ' - validating invalid geometries ...';
        EXECUTE format('UPDATE %I.%I SET %I=ST_MakeValid(%I) WHERE NOT ST_IsValid(%I);', schema_name, table_name, geom_column, geom_column, geom_column);
        RAISE NOTICE ' - creating index %.% ...', schema_name, index_name;
        EXECUTE format(index_create_sql);

    ELSE
        RAISE NOTICE '!!!! TABLE %.% NOT CHECK', schema_name, table_name;
    END IF;
    RAISE NOTICE ' DONE ';
END;
$$ LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION :schema.translate_all_tables(from_proj TEXT, to_proj TEXT) RETURNS VOID AS $$
DECLARE
    schema_name TEXT := (SELECT schema_name from temp_schema);
BEGIN
    -- Transform tables osm_
    PERFORM transform_table(
        table_name,
        'the_geom',
        from_proj, to_proj
    )
    FROM information_schema.tables
    WHERE table_schema=schema_name
    ORDER BY table_name;

END;
$$ language plpgsql;

--execute it
BEGIN;
--'+proj=lcc +lat_1=49 +lat_2=44 +lat_0=46.5 +lon_0=3 +x_0=700000 +y_0=6600000 +ellps=GRS80 +towgs84=0,0,0,0,0,0,0 +units=m +no_defs'
SELECT :schema.translate_all_tables(
    '+proj=somerc +lat_0=46.95240555555556 +lon_0=7.439583333333333 +k_0=1 +x_0=2600000 +y_0=1200000 +ellps=bessel +towgs84=674.374,15.056,405.346,0,0,0,0 +units=m +no_defs',
    '+proj=merc +a=6378137 +b=6378137 +lat_ts=0.0 +lon_0=0.0 +x_0=0.0 +y_0=0 +k=1.0 +units=m +nadgrids=@null +wktext +no_defs'
);

-- ROLLBACK;
COMMIT;
