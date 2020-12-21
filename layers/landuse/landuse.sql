DROP FUNCTION IF EXISTS public.layer_landuse (geometry, int);

DROP VIEW IF EXISTS lbm.landuse_z12;
DROP VIEW IF EXISTS lbm.landuse_z13;
DROP MATERIALIZED VIEW IF EXISTS lbm.landuse_subset;

CREATE MATERIALIZED VIEW lbm.landuse_subset AS
(
SELECT the_geom, class 
FROM lbm.landuse 
WHERE class IN ('landfill', 'cemetery', 'quarry', 'parking', 'pitch')
    );
CREATE INDEX ON lbm.landuse_subset using gist (the_geom);

CREATE OR REPLACE VIEW lbm.landuse_z12 AS
(
SELECT ST_Simplify(the_geom,10) as the_geom,
       class
FROM lbm.landuse_subset
    );

CREATE OR REPLACE VIEW lbm.landuse_z13 AS
(
SELECT ST_Simplify(the_geom,5) as the_geom,
       class
FROM lbm.landuse_subset
    );

-- etldoc: layer_landuse[shape=record fillcolor=lightpink, style="rounded,filled",
-- etldoc:     label="layer_landuse |<z12_> z12+ |<z13_> z13+ |<z14_> z14+" ] ;
DROP FUNCTION IF EXISTS lbm.layer_landuse(geometry,int);
CREATE OR REPLACE FUNCTION lbm.layer_landuse(bbox geometry, zoom_level int)
    RETURNS TABLE
            (
                the_geom geometry,
                class    text
            )
AS
$$
SELECT the_geom,
       class
FROM (

         -- etldoc: lbm_landuse -> cemetery -> layer_landuse:z12_
         SELECT *
         FROM lbm.landuse_z12
         WHERE zoom_level = 12
            AND class = 'cemetery'
         UNION ALL
         -- etldoc: lbm_landuse -> landfill,quarry,pitch -> layer_landuse:z13_
         SELECT *
         FROM lbm.landuse_z13
         WHERE zoom_level = 13
            AND class IN ('landfill','quarry','pitch')
         UNION ALL
         -- etldoc: lbm_landuse -> parking -> layer_landuse:z14_
         SELECT the_geom, class
         FROM lbm.landuse_subset
         WHERE zoom_level >= 14
     ) AS zoom_levels
WHERE the_geom && bbox;
$$ LANGUAGE SQL STABLE
                -- STRICT
                PARALLEL SAFE;
