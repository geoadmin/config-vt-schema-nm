DROP VIEW IF EXISTS lbm.water_z5;
CREATE OR REPLACE VIEW lbm.water_z5 AS
(
SELECT ST_Simplify(the_geom, 1200) as the_geom,
       class
FROM lbm.water
WHERE minzoom <= 5
    );

DROP VIEW IF EXISTS lbm.water_z6;
CREATE OR REPLACE VIEW lbm.water_z6 AS
(
SELECT ST_Simplify(the_geom, 600) as the_geom,
       class
FROM lbm.water
WHERE minzoom <= 6
    );

DROP VIEW IF EXISTS lbm.water_z7;
CREATE OR REPLACE VIEW lbm.water_z7 AS
(
SELECT ST_Simplify(the_geom, 300) as the_geom,
       class
FROM lbm.water
WHERE minzoom <= 7
    );

DROP VIEW IF EXISTS lbm.water_z8;
CREATE OR REPLACE VIEW lbm.water_z8 AS
(
SELECT ST_Simplify(the_geom, 160) as the_geom,
       class
FROM lbm.water
WHERE minzoom <= 8
    );

DROP VIEW IF EXISTS lbm.water_z9;
CREATE OR REPLACE VIEW lbm.water_z9 AS
(
SELECT ST_Simplify(the_geom, 80) as the_geom,
       class
FROM lbm.water
WHERE minzoom <= 9
    );

DROP VIEW IF EXISTS lbm.water_z10;
CREATE OR REPLACE VIEW lbm.water_z10 AS
(
SELECT ST_Simplify(the_geom, 40) as the_geom,
       class
FROM lbm.water
WHERE minzoom <= 10
    );

DROP VIEW IF EXISTS lbm.water_z11;
CREATE OR REPLACE VIEW lbm.water_z11 AS
(
SELECT ST_Simplify(the_geom, 20) as the_geom,
       class
FROM lbm.water
WHERE minzoom <= 11
    );

DROP VIEW IF EXISTS lbm.water_z12;
CREATE OR REPLACE VIEW lbm.water_z12 AS
(
SELECT ST_Simplify(the_geom, 10) as the_geom,
       class
FROM lbm.water
WHERE minzoom <= 12
    );

DROP VIEW IF EXISTS lbm.water_z13;
CREATE OR REPLACE VIEW lbm.water_z13 AS
(
SELECT ST_Simplify(the_geom, 5) as the_geom,
       class
FROM lbm.water
WHERE minzoom <= 13
    );


-- etldoc: layer_water [shape=record fillcolor=lightpink, style="rounded,filled",
-- etldoc:     label="layer_water |<z5_> z5+" ] ;

DROP FUNCTION IF EXISTS lbm.layer_water(geometry, int);
CREATE OR REPLACE FUNCTION lbm.layer_water(bbox geometry, zoom_level int)
    RETURNS TABLE
            (
                the_geom     geometry,
                class        text
            )
AS
$$
SELECT the_geom,
       class
FROM (
         -- etldoc: lbm_water -> layer_water:z5_
         SELECT *
         FROM lbm.water_z5
         WHERE zoom_level = 5
         UNION ALL
         SELECT *
         FROM lbm.water_z6
         WHERE zoom_level = 6
         UNION ALL
         SELECT *
         FROM lbm.water_z7
         WHERE zoom_level = 7
         UNION ALL
         SELECT *
         FROM lbm.water_z8
         WHERE zoom_level = 8
         UNION ALL
         SELECT *
         FROM lbm.water_z9
         WHERE zoom_level = 9
         UNION ALL
         SELECT *
         FROM lbm.water_z10
         WHERE zoom_level = 10
         UNION ALL
         SELECT *
         FROM lbm.water_z11
         WHERE zoom_level = 11
         UNION ALL
         SELECT *
         FROM lbm.water_z12
         WHERE zoom_level = 12
         UNION ALL
         SELECT *
         FROM lbm.water_z13
         WHERE zoom_level = 13
         UNION ALL
         SELECT the_geom,
                class
         FROM lbm.water
         WHERE zoom_level >= 14
     ) AS zoom_levels
WHERE the_geom && bbox;
$$ LANGUAGE SQL STABLE
                -- STRICT
                PARALLEL SAFE;
