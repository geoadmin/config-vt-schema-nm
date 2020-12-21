-- etldoc: layer_transportation_name[shape=record fillcolor=lightpink, style="rounded,filled",
-- etldoc:     label="<sql> layer_transportation_name |<z13_> z13+" ] ;

DROP MATERIALIZED VIEW IF EXISTS lbm.transportation_name_valid CASCADE;
CREATE MATERIALIZED VIEW lbm.transportation_name_valid AS
(SELECT the_geom,
        class,
        subclass,
        name,
        name_de,
        name_fr,
        name_it,
        name_rm,
        name_latin,
        ref,
        ref_length,
        layer
    FROM lbm.transportation_name WHERE validated = 1 
                                 OR validated IS NULL 
                                 OR ref IS NOT NULL);
CREATE INDEX IF NOT EXISTS transportation_name_valid_idx ON lbm.transportation_name_valid USING gist(the_geom);

DROP FUNCTION IF EXISTS lbm.layer_transportation_name(geometry, integer);
CREATE OR REPLACE FUNCTION lbm.layer_transportation_name(bbox geometry, zoom_level integer)
RETURNS TABLE (
    the_geom        geometry,
    class           text,
    subclass        text,
    name            text,
    "name:de"       text,
    "name:fr"       text,
    "name:it"       text,
    "name:rm"       text,
    "name:latin"    text,
    ref             text,
    ref_length      integer,
    layer           integer) AS
$$
SELECT
    the_geom,
    class,
    subclass,
    name,
    COALESCE(NULLIF(name_de, ''), name)     AS "name:de",
    COALESCE(NULLIF(name_fr, ''), name)     AS "name:fr",
    COALESCE(NULLIF(name_it, ''), name)     AS "name:it",
    COALESCE(NULLIF(name_rm, ''), name)     AS "name:rm",
    COALESCE(NULLIF(name_latin, ''), name)  AS "name:latin",
    ref,
    ref_length,
    layer
FROM (
        -- etldoc: lbm_transportation_name -> layer_transportation_name:z13_
        SELECT 
            the_geom,
            class,
            subclass,
            name,
            name_de,
            name_fr,
            name_it,
            name_rm,
            name_latin,
            ref,
            ref_length,
            layer
        FROM lbm.transportation_name_valid
        WHERE the_geom && bbox
          AND class NOT IN ('path','track')
          AND zoom_level = 13

        UNION ALL

        SELECT 
            the_geom,
            class,
            subclass,
            name,
            name_de,
            name_fr,
            name_it,
            name_rm,
            name_latin,
            ref,
            ref_length,
            layer
        FROM lbm.transportation_name_valid
        WHERE the_geom && bbox
          AND zoom_level >= 14
    ) AS zoom_levels;
$$ LANGUAGE SQL STABLE
                -- STRICT
                PARALLEL SAFE;
                