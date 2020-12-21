-- etldoc: layer_park[shape=record fillcolor=lightpink, style="rounded,filled",
-- etldoc:     label="layer_park |<z7_> z7+" ] ;

DROP MATERIALIZED VIEW IF EXISTS lbm.park_subset CASCADE;
CREATE MATERIALIZED VIEW lbm.park_subset AS
(
SELECT  the_geom,
        class
FROM lbm.park
WHERE class = 'national_park'
    );
CREATE INDEX ON lbm.park_subset USING gist (the_geom);


DROP VIEW IF EXISTS lbm.park_z7 CASCADE;
CREATE OR REPLACE VIEW lbm.park_z7 AS
(
SELECT ST_Simplify(the_geom, 600) as the_geom_poly,
       class
FROM lbm.park_subset
    );

DROP VIEW IF EXISTS lbm.park_z8 CASCADE;
CREATE OR REPLACE VIEW lbm.park_z8 AS
(
SELECT ST_Simplify(the_geom, 200) as the_geom_poly,
       class
FROM lbm.park_subset
    );

DROP VIEW IF EXISTS lbm.park_z9 CASCADE;
CREATE OR REPLACE VIEW lbm.park_z9 AS
(
SELECT ST_Simplify(the_geom, 50) as the_geom_poly,
       class
FROM lbm.park_subset
    );

DROP VIEW IF EXISTS lbm.park_z10 CASCADE;
CREATE OR REPLACE VIEW lbm.park_z10 AS
(
SELECT ST_Simplify(the_geom, 10) as the_geom_poly,
       class
FROM lbm.park_subset
    );

DROP VIEW IF EXISTS lbm.park_z11 CASCADE;
CREATE OR REPLACE VIEW lbm.park_z11 AS
(
SELECT the_geom as the_geom_poly,
       class
FROM lbm.park_subset
    );

DROP VIEW IF EXISTS lbm.park_pt_z7_14 CASCADE;
CREATE OR REPLACE VIEW lbm.park_pt_z7_14 AS
(
SELECT the_geom as the_geom_point,
       class,
       name,
       name_latin,
       name_de,
       name_fr,
       name_it,
       name_rm
FROM lbm.park_pt
WHERE class = 'national_park'
    );

DROP FUNCTION IF EXISTS lbm.layer_park(geometry, int, numeric);
CREATE OR REPLACE FUNCTION lbm.layer_park(bbox geometry, zoom_level int, pixel_width numeric)
    RETURNS TABLE
            (
                the_geom      geometry,
                class         text,
                name          text,
                "name:latin"  text,
                "name:de"     text,
                "name:fr"     text,
                "name:it"     text,
                "name:rm"     text
                )
AS
$$
SELECT the_geom, class, name, "name:latin", "name:de", "name:fr", "name:it", "name:rm"
FROM (
         SELECT the_geom, class, name, "name:latin", "name:de", "name:fr", "name:it", "name:rm"
         FROM (
                  -- etldoc: lbm_park_polygon -> layer_park:z7_
                  SELECT the_geom_poly AS the_geom,
                         class,
                         NULL::text      AS name,
                         NULL::text      AS "name:latin",
                         NULL::text      AS "name:de",
                         NULL::text      AS "name:it",
                         NULL::text      AS "name:fr",
                         NULL::text      AS "name:rm"
                  FROM lbm.park_z7
                  WHERE zoom_level = 7
                    AND the_geom_poly && bbox
                  UNION ALL
                  SELECT the_geom_poly AS the_geom,
                         class,
                         NULL::text      AS name,
                         NULL::text      AS "name:latin",
                         NULL::text      AS "name:de",
                         NULL::text      AS "name:it",
                         NULL::text      AS "name:fr",
                         NULL::text      AS "name:rm"
                  FROM lbm.park_z8
                  WHERE zoom_level = 8
                    AND the_geom_poly && bbox
                  UNION ALL
                  SELECT the_geom_poly AS the_geom,
                         class,
                         NULL::text      AS name,
                         NULL::text      AS "name:latin",
                         NULL::text      AS "name:de",
                         NULL::text      AS "name:it",
                         NULL::text      AS "name:fr",
                         NULL::text      AS "name:rm"
                  FROM lbm.park_z9
                  WHERE zoom_level = 9
                    AND the_geom_poly && bbox
                  UNION ALL
                  SELECT the_geom_poly AS the_geom,
                         class,
                         NULL::text      AS name,
                         NULL::text      AS "name:latin",
                         NULL::text      AS "name:de",
                         NULL::text      AS "name:it",
                         NULL::text      AS "name:fr",
                         NULL::text      AS "name:rm"
                  FROM lbm.park_z10
                  WHERE zoom_level = 10
                    AND the_geom_poly && bbox
                  UNION ALL
                  SELECT the_geom_poly AS the_geom,
                         class,
                         NULL::text      AS name,
                         NULL::text      AS "name:latin",
                         NULL::text      AS "name:de",
                         NULL::text      AS "name:it",
                         NULL::text      AS "name:fr",
                         NULL::text      AS "name:rm"
                  FROM lbm.park_z11
                  WHERE zoom_level >= 11
                    AND the_geom_poly && bbox

              ) AS park_polygon

         UNION ALL

         SELECT the_geom, class, name, "name:latin", "name:de", "name:fr", "name:it", "name:rm"
         FROM (
                  -- etldoc: lbm_park_point -> layer_park:z7_
                  SELECT the_geom_point AS the_geom,
                         class,
                         name,
                         COALESCE(NULLIF(name_latin, ''), name)      AS "name:latin",
                         COALESCE(NULLIF(name_de, ''), name)         AS "name:de",
                         COALESCE(NULLIF(name_fr, ''), name)         AS "name:fr",
                         COALESCE(NULLIF(name_it, ''), name)         AS "name:it",
                         COALESCE(NULLIF(name_rm, ''), name)         AS "name:rm"
                  FROM lbm.park_pt_z7_14
                  WHERE zoom_level BETWEEN 7 AND 14
                    AND the_geom_point && bbox
              ) AS park_point
     ) AS park_all;
$$ LANGUAGE SQL STABLE
                PARALLEL SAFE;
-- TODO: Check if the above can be made STRICT -- i.e. if pixel_width could be NULL
