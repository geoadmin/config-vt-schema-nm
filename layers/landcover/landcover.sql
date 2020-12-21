--TODO: Find a way to nicely generalize landcover
--CREATE TABLE IF NOT EXISTS landcover_grouped_gen2 AS (
--	SELECT osm_id, ST_Simplify((ST_Dump(geometry)).geom, 600) AS geometry, landuse, "natural", wetland
--	FROM (
--	  SELECT max(osm_id) AS osm_id, ST_Union(ST_Buffer(geometry, 600)) AS geometry, landuse, "natural", wetland
--	  FROM osm_landcover_polygon_gen1
--	  GROUP BY LabelGrid(geometry, 15000000), landuse, "natural", wetland
--	) AS grouped_measurements
--);
--CREATE INDEX IF NOT EXISTS landcover_grouped_gen2_geometry_idx ON landcover_grouped_gen2 USING gist(geometry);

DROP MATERIALIZED VIEW IF EXISTS lbm.landcover_subset CASCADE;
DROP MATERIALIZED VIEW IF EXISTS lbm.landcover_glacier CASCADE;
DROP MATERIALIZED VIEW IF EXISTS lbm.landcover_glacier_gen1 CASCADE;
DROP MATERIALIZED VIEW IF EXISTS lbm.landcover_z10 CASCADE;
DROP MATERIALIZED VIEW IF EXISTS lbm.landcover_z11 CASCADE;
DROP MATERIALIZED VIEW IF EXISTS lbm.landcover_z12 CASCADE;
DROP MATERIALIZED VIEW IF EXISTS lbm.landcover_z13 CASCADE;
DROP MATERIALIZED VIEW IF EXISTS lbm.landcover_z14 CASCADE;

-- select only landcover polygons relevant for the LBM
CREATE MATERIALIZED VIEW lbm.landcover_subset AS
(
SELECT  the_geom,
        class,
        subclass
FROM lbm.landcover
WHERE subclass IN ( 'scrub',
                    'glacier',
                    'swamp',
                    'forest',
                    'recreation_ground',
                    'golf_course',
                    'plant_nursery',
                    'orchard',
                    'park',
                    'vineyard',
                    'allotments')
    );
CREATE INDEX ON lbm.landcover_subset USING gist (the_geom);

CREATE MATERIALIZED VIEW lbm.landcover_glacier AS
(
SELECT ST_SimplifyPreserveTopology(the_geom, 1000) as the_geom, 
       class, 
       subclass
FROM lbm.landcover_subset
WHERE subclass = 'glacier'
    );
CREATE INDEX ON lbm.landcover_glacier USING gist (the_geom);

CREATE MATERIALIZED VIEW lbm.landcover_z10 AS
(
SELECT ST_SimplifyPreserveTopology(the_geom, 250) as the_geom,
       class,
       subclass
FROM lbm.landcover_subset
WHERE ST_Area(the_geom) > power(ZRES(8),2)
    AND subclass IN ('glacier', 'forest')
    );
CREATE INDEX ON lbm.landcover_z10 USING gist (the_geom);

CREATE MATERIALIZED VIEW lbm.landcover_z11 AS
(
SELECT ST_SimplifyPreserveTopology(the_geom, 100) as the_geom,
       class,
       subclass
FROM lbm.landcover_subset
WHERE ST_Area(the_geom) > power(ZRES(8),2)
    AND subclass IN ('glacier', 'forest', 'scrub', 'plant_nursery', 'orchard', 'vineyard')
    );
CREATE INDEX ON lbm.landcover_z11 USING gist (the_geom);

CREATE MATERIALIZED VIEW lbm.landcover_z12 AS
(
SELECT ST_SimplifyPreserveTopology(the_geom, 40) as the_geom,
       class,
       subclass
FROM lbm.landcover_subset
WHERE ST_Area(the_geom) > power(ZRES(9),2)
    AND subclass IN ('glacier',
                     'forest',
                     'scrub',
                     'plant_nursery',
                     'orchard',
                     'vineyard',
                     'golf_course')
    );
CREATE INDEX ON lbm.landcover_z12 USING gist (the_geom);

CREATE MATERIALIZED VIEW lbm.landcover_z13 AS
(
SELECT ST_SimplifyPreserveTopology(the_geom, 20) as the_geom,
       class,
       subclass
FROM lbm.landcover_subset
WHERE ST_Area(the_geom) > power(ZRES(10),2)
    AND subclass IN ('glacier',
                    'forest',
                    'scrub',
                    'plant_nursery',
                    'orchard',
                    'vineyard',
                    'golf_course',
                    'swamp',
                    'recreation_ground',
                    'allotments')
    );
CREATE INDEX ON lbm.landcover_z13 USING gist (the_geom);

CREATE MATERIALIZED VIEW lbm.landcover_z14 AS
(
SELECT ST_SimplifyPreserveTopology(the_geom, 5) as the_geom,
       class,
       subclass
FROM lbm.landcover_subset
    );
CREATE INDEX ON lbm.landcover_z14 USING gist (the_geom);

-- etldoc: layer_landcover[shape=record fillcolor=lightpink, style="rounded, filled", label="layer_landcover |<z5_> z5+ |<z10_> z10+ |<z11_> z11+ |<z12_> z12+|<z13_> z13+|<z14_> z14+" ] ;
DROP FUNCTION IF EXISTS lbm.layer_landcover(geometry,int);
CREATE OR REPLACE FUNCTION lbm.layer_landcover(bbox geometry, zoom_level int)
    RETURNS TABLE
            (
                the_geom geometry,
                class    text,
                subclass text
            )
AS
$$
SELECT the_geom,
       class,
       subclass
FROM (
         -- etldoc: lbm_landcover -> glacier -> layer_landcover:z5_
         SELECT *
         FROM lbm.landcover_glacier
         WHERE zoom_level BETWEEN 5 AND 9
           AND the_geom && bbox
         UNION ALL
         -- etldoc:  lbm_landcover -> forest -> layer_landcover:z10_
         SELECT *
         FROM lbm.landcover_z10
         WHERE zoom_level = 10
           AND the_geom && bbox
         UNION ALL
         -- etldoc:  lbm_landcover -> scrub,plant_nursery,orchard,vineyard -> layer_landcover:z11_
         SELECT *
         FROM lbm.landcover_z11
         WHERE zoom_level = 11
           AND the_geom && bbox
         UNION ALL
         -- etldoc:  lbm_landcover -> golf_course -> layer_landcover:z12_
         SELECT *
         FROM lbm.landcover_z12
         WHERE zoom_level = 12
           AND the_geom && bbox
         UNION ALL
         -- etldoc:  lbm_landcover -> swamp,allotments -> layer_landcover:z13_
         SELECT *
         FROM lbm.landcover_z13
         WHERE zoom_level = 13
           AND the_geom && bbox
         UNION ALL
         -- etldoc:  lbm_landcover -> recreation_ground,park -> layer_landcover:z14_
         SELECT *
         FROM lbm.landcover_z14
         WHERE zoom_level >= 14
           AND the_geom && bbox
     ) AS zoom_levels;
$$ LANGUAGE SQL STABLE
                -- STRICT
                PARALLEL SAFE;
