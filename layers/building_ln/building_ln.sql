DROP MATERIALIZED VIEW IF EXISTS lbm.building_ln_subset CASCADE;
CREATE MATERIALIZED VIEW lbm.building_ln_subset AS
(
SELECT  the_geom,
        name,
        name_de,
        name_fr,
        name_it,
        name_rm,
        name_latin,
        class
FROM lbm.building_ln
    -- select only data that will be visible in the LBM
    WHERE class IN (
                    'track',
                    'horse_racing',
                    'toboggan',
                    'ski_jump',
                    'weir'
                    )      
    )/* DELAY_MATERIALIZED_VIEW_CREATION */;
CREATE INDEX IF NOT EXISTS building_ln_subset_idx ON lbm.building_ln_subset USING gist (the_geom);

-- etldoc: layer_building_ln[shape=record fillcolor=lightpink, style="rounded,filled", label="layer_building_ln |<z13_> z13+" ];
-- etldoc: lbm_building_ln -> layer_building_ln:z13_
DROP FUNCTION IF EXISTS lbm.layer_building_ln(geometry, integer);
CREATE OR REPLACE FUNCTION lbm.layer_building_ln(bbox geometry, zoom_level integer)
    RETURNS TABLE
            (
                the_geom            geometry,
                name                text,
                "name:de"           text,
                "name:fr"           text,
                "name:it"           text,
                "name:rm"           text,
                "name:latin"        text,
                class               text
             )
AS
$$
SELECT  the_geom,
        name,
        COALESCE(NULLIF(name_de, ''), name)     AS "name:de",
        COALESCE(NULLIF(name_fr, ''), name)     AS "name:fr",
        COALESCE(NULLIF(name_it, ''), name)     AS "name:it",
        COALESCE(NULLIF(name_rm, ''), name)     AS "name:rm",
        COALESCE(NULLIF(name_latin, ''), name)  AS "name:latin",
        class
FROM lbm.building_ln_subset  
WHERE the_geom && bbox
    AND zoom_level >=13;
$$ LANGUAGE SQL STABLE
                -- STRICT
                PARALLEL SAFE;