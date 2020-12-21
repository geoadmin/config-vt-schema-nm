DROP MATERIALIZED VIEW IF EXISTS lbm.waterway_subset CASCADE;
CREATE MATERIALIZED VIEW lbm.waterway_subset AS
(
SELECT  the_geom,
        class,
        name,
        name_latin,
        name_de,
        name_fr,
        name_it,
        name_rm,
        intermittent,
        width,
        minzoom
FROM lbm.waterway
WHERE underground != 1
    );
CREATE INDEX ON lbm.waterway_subset USING gist (the_geom);

DROP VIEW IF EXISTS lbm.waterway_z9;
CREATE OR REPLACE VIEW lbm.waterway_z9 AS
(
SELECT ST_Simplify(the_geom, 80) as the_geom,
       class,
       name,
       name_latin,
       name_de,
       name_fr,
       name_it,
       name_rm,
       intermittent,
       width
FROM lbm.waterway_subset
WHERE minzoom <= 9
    );

DROP VIEW IF EXISTS lbm.waterway_z10;
CREATE OR REPLACE VIEW lbm.waterway_z10 AS
(
SELECT ST_Simplify(the_geom, 40) as the_geom,
       class,
       name,
       name_latin,
       name_de,
       name_fr,
       name_it,
       name_rm,
       intermittent,
       width
FROM lbm.waterway_subset
WHERE minzoom <= 10
    );

DROP VIEW IF EXISTS lbm.waterway_z11;
CREATE OR REPLACE VIEW lbm.waterway_z11 AS
(
SELECT ST_Simplify(the_geom, 20) as the_geom,
       class,
       name,
       name_latin,
       name_de,
       name_fr,
       name_it,
       name_rm,
       intermittent,
       width
FROM lbm.waterway_subset
WHERE minzoom <= 11
    );

DROP VIEW IF EXISTS lbm.waterway_z12;
CREATE OR REPLACE VIEW lbm.waterway_z12 AS
(
SELECT ST_Simplify(the_geom, 10) as the_geom,
       class,
       name,
       name_latin,
       name_de,
       name_fr,
       name_it,
       name_rm,
       intermittent,
       width
FROM lbm.waterway_subset
WHERE minzoom <= 12
    );

DROP VIEW IF EXISTS lbm.waterway_z13;
CREATE OR REPLACE VIEW lbm.waterway_z13 AS
(
SELECT ST_Simplify(the_geom, 5) as the_geom,
       class,
       name,
       name_latin,
       name_de,
       name_fr,
       name_it,
       name_rm,
       intermittent,
       width
FROM lbm.waterway_subset
WHERE minzoom <= 13
    );


-- etldoc: layer_waterway [shape=record fillcolor=lightpink, style="rounded,filled", label="layer_waterway |<z9_> z9+" ];

DROP FUNCTION IF EXISTS lbm.layer_waterway(geometry, int);
CREATE OR REPLACE FUNCTION lbm.layer_waterway(bbox geometry, zoom_level int)
    RETURNS TABLE
            (
                the_geom      geometry,
                class         text,
                name          text,
                "name:latin"  text,
                "name:de"     text,
                "name:fr"     text,
                "name:it"     text,
                "name:rm"     text,
                intermittent  integer,
                width         integer                
            )
AS
$$
SELECT the_geom,
       class,
       name,
       COALESCE(NULLIF(name_latin, ''), name)  AS "name:latin",
       COALESCE(NULLIF(name_de, ''), name)     AS "name:de",
       COALESCE(NULLIF(name_fr, ''), name)     AS "name:fr",
       COALESCE(NULLIF(name_it, ''), name)     AS "name:it",
       COALESCE(NULLIF(name_rm, ''), name)     AS "name:rm",
       intermittent,
       width
FROM (
         -- etldoc: lbm_waterway -> not_underground -> layer_waterway:z9_
         SELECT *
         FROM lbm.waterway_z9
         WHERE zoom_level = 9
         UNION ALL

         SELECT *
         FROM lbm.waterway_z10
         WHERE zoom_level = 10
         UNION ALL

         SELECT *
         FROM lbm.waterway_z11
         WHERE zoom_level = 11
         UNION ALL

         SELECT *
         FROM lbm.waterway_z12
         WHERE zoom_level = 12
         UNION ALL

         SELECT *
         FROM lbm.waterway_z13
         WHERE zoom_level = 13
         UNION ALL

         SELECT the_geom,
                class,
                name,
                COALESCE(NULLIF(name_latin, ''), name)  AS "name:latin",
                COALESCE(NULLIF(name_de, ''), name)     AS "name:de",
                COALESCE(NULLIF(name_fr, ''), name)     AS "name:fr",
                COALESCE(NULLIF(name_it, ''), name)     AS "name:it",
                COALESCE(NULLIF(name_rm, ''), name)     AS "name:rm",
                intermittent,
                width
         FROM lbm.waterway_subset
         WHERE zoom_level >= 14
     ) AS zoom_levels
WHERE the_geom && bbox;
$$ LANGUAGE SQL STABLE
                -- STRICT
                PARALLEL SAFE;
