DROP MATERIALIZED VIEW IF EXISTS lbm.area_name_pt_subset CASCADE;
CREATE MATERIALIZED VIEW lbm.area_name_pt_subset AS
(SELECT the_geom,
        class,
        subclass,
        name,
        name_de,
        name_fr,
        name_it,
        name_rm,
        name_latin,
        minzoom
 FROM lbm.area_name_pt
    WHERE subclass IN ('glacier','massif')
    ) /* DELAY_MATERIALIZED_VIEW_CREATION */;
CREATE INDEX IF NOT EXISTS area_name_pt_subset_idx ON lbm.area_name_pt_subset USING gist (the_geom);

DROP MATERIALIZED VIEW IF EXISTS lbm.area_name_z11 CASCADE;
CREATE MATERIALIZED VIEW lbm.area_name_z11 AS
(SELECT the_geom,
        class,
        subclass,
        name,
        name_de,
        name_fr,
        name_it,
        name_rm,
        name_latin,
        minzoom
 FROM lbm.area_name
    WHERE minzoom <= 11 AND subclass = 'glacier'
    ) /* DELAY_MATERIALIZED_VIEW_CREATION */;
CREATE INDEX IF NOT EXISTS area_name_z11_idx ON lbm.area_name_z11 USING gist (the_geom);

DROP MATERIALIZED VIEW IF EXISTS lbm.area_name_z12 CASCADE;
CREATE MATERIALIZED VIEW lbm.area_name_z12 AS
(SELECT the_geom,
        class,
        subclass,
        name,
        name_de,
        name_fr,
        name_it,
        name_rm,
        name_latin,
        minzoom
 FROM lbm.area_name
    WHERE minzoom <= 12 AND subclass = 'glacier'
    ) /* DELAY_MATERIALIZED_VIEW_CREATION */;
CREATE INDEX IF NOT EXISTS area_name_z12_idx ON lbm.area_name_z12 USING gist (the_geom);

-- etldoc: layer_area_name[shape=record fillcolor=lightpink, style="rounded,filled",
-- etldoc:     label="<sql> layer_area_name |<z11_> z11+ |<z13_> z13+"]
DROP FUNCTION IF EXISTS lbm.layer_area_name(geometry, integer);
CREATE OR REPLACE FUNCTION lbm.layer_area_name(bbox geometry, zoom_level integer)
    RETURNS TABLE
            (
                the_geom geometry,
                class text,
                subclass text,
                name text,
                "name:latin" text,
                "name:de" text,
                "name:fr" text,
                "name:it" text,
                "name:rm" text
            )
AS
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
    COALESCE(NULLIF(name_latin, ''), name)  AS "name:latin"
FROM (
        --etldoc: lbm_area_name_polyline -> glacier_polyline -> layer_area_name:z11_
        --etldoc: lbm_area_name_point -> massif_point -> layer_area_name:z11_
        --etldoc: lbm_area_name_point -> glacier_point -> layer_area_name:z13_
        SELECT 
            the_geom,
            class,
            subclass,
            name,
            name_de,
            name_fr,
            name_it,
            name_rm,
            name_latin
        FROM lbm.area_name_pt_subset
        WHERE the_geom && bbox
            AND subclass = 'massif'
            AND zoom_level >= 11

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
            name_latin
        FROM lbm.area_name_z11
        WHERE the_geom && bbox
            AND zoom_level = 11

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
            name_latin
        FROM lbm.area_name_z12
        WHERE the_geom && bbox
            AND zoom_level = 12

        UNION ALL

        SELECT  the_geom,
                class,
                subclass,
                name,
                name_de,
                name_fr,
                name_it,
                name_rm,
                name_latin
        FROM lbm.area_name
        WHERE the_geom && bbox
            AND zoom_level >= 13
            AND subclass = 'glacier'

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
            name_latin
        FROM lbm.area_name_pt_subset
        WHERE the_geom && bbox
            AND subclass = 'glacier'
            AND zoom_level >= 13
        ) AS zoom_levels;
$$ LANGUAGE SQL STABLE
                -- STRICT
                PARALLEL SAFE;