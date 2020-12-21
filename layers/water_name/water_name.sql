-- etldoc: layer_water_name[shape=record fillcolor=lightpink, style="rounded,filled",
-- etldoc:     label="layer_water_name |<z8_> z8+ |<z12_> z12+" ] ;


DROP MATERIALIZED VIEW IF EXISTS lbm.water_name_ln_subset CASCADE;
CREATE MATERIALIZED VIEW lbm.water_name_ln_subset AS
(
SELECT  the_geom,
        class,
        name,
        name_latin,
        name_de,
        name_fr,
        name_it,
        name_rm
FROM lbm.water_name_ln
WHERE class = 'lake'
    );
CREATE INDEX ON lbm.water_name_ln_subset USING gist (the_geom);


-- etldoc: lbm_water_name -> water_name_polygon -> layer_water_name:z8_
DROP VIEW IF EXISTS lbm.water_name_ln_z8 CASCADE;
CREATE OR REPLACE VIEW lbm.water_name_ln_z8 AS
(
SELECT ST_Simplify(the_geom, 80) as the_geom_line,
        class,
        name,
        name_latin,
        name_de,
        name_fr,
        name_it,
        name_rm
FROM lbm.water_name_ln_subset
WHERE ST_LENGTH(the_geom) > 50000
    );

DROP VIEW IF EXISTS lbm.water_name_ln_z9 CASCADE;
CREATE OR REPLACE VIEW lbm.water_name_ln_z9 AS
(
SELECT ST_Simplify(the_geom, 40) as the_geom_line,
        class,
        name,
        name_latin,
        name_de,
        name_fr,
        name_it,
        name_rm
FROM lbm.water_name_ln_subset
WHERE ST_LENGTH(the_geom) > 10000
    );

DROP VIEW IF EXISTS lbm.water_name_ln_z10 CASCADE;
CREATE OR REPLACE VIEW lbm.water_name_ln_z10 AS
(
SELECT ST_Simplify(the_geom, 20) as the_geom_line,
        class,
        name,
        name_latin,
        name_de,
        name_fr,
        name_it,
        name_rm
FROM lbm.water_name_ln_subset
WHERE ST_LENGTH(the_geom) > 5000
    );

DROP VIEW IF EXISTS lbm.water_name_ln_z11 CASCADE;
CREATE OR REPLACE VIEW lbm.water_name_ln_z11 AS
(
SELECT ST_Simplify(the_geom, 10) as the_geom_line,
        class,
        name,
        name_latin,
        name_de,
        name_fr,
        name_it,
        name_rm
FROM lbm.water_name_ln_subset
WHERE ST_LENGTH(the_geom) > 2500
    );

DROP VIEW IF EXISTS lbm.water_name_ln_z12 CASCADE;
CREATE OR REPLACE VIEW lbm.water_name_ln_z12 AS
(
SELECT  the_geom as the_geom_line,
        class,
        name,
        name_latin,
        name_de,
        name_fr,
        name_it,
        name_rm
FROM lbm.water_name_ln_subset
WHERE ST_LENGTH(the_geom) > 500
    );

DROP VIEW IF EXISTS lbm.water_name_ln_z13_14 CASCADE;
CREATE OR REPLACE VIEW lbm.water_name_ln_z13_14 AS
(
SELECT  the_geom as the_geom_line,
        class,
        name,
        name_latin,
        name_de,
        name_fr,
        name_it,
        name_rm
FROM lbm.water_name_ln_subset
    );

DROP MATERIALIZED VIEW IF EXISTS lbm.water_name_pt_subset CASCADE;
CREATE MATERIALIZED VIEW lbm.water_name_pt_subset AS
(
SELECT  the_geom,
        class,
        name,
        name_latin,
        name_de,
        name_fr,
        name_it,
        name_rm,
        minzoom
FROM lbm.water_name_pt
WHERE class = 'lake'
    );
CREATE INDEX ON lbm.water_name_pt_subset USING gist (the_geom);

-- etldoc: lbm_water_name -> water_name_point -> layer_water_name:z12_
DROP VIEW IF EXISTS lbm.water_name_pt_z12 CASCADE;
CREATE OR REPLACE VIEW lbm.water_name_pt_z12 AS
(
SELECT the_geom as the_geom_point,
       class,
       name,
       name_latin,
       name_de,
       name_fr,
       name_it,
       name_rm
FROM lbm.water_name_pt_subset
WHERE minzoom <= 12
    );

DROP VIEW IF EXISTS lbm.water_name_pt_z13 CASCADE;
CREATE OR REPLACE VIEW lbm.water_name_pt_z13 AS
(
SELECT the_geom as the_geom_point,
       class,
       name,
       name_latin,
       name_de,
       name_fr,
       name_it,
       name_rm
FROM lbm.water_name_pt_subset
WHERE minzoom <= 13
    );

DROP VIEW IF EXISTS lbm.water_name_pt_z14 CASCADE;
CREATE OR REPLACE VIEW lbm.water_name_pt_z14 AS
(
SELECT the_geom as the_geom_point,
       class,
       name,
       name_latin,
       name_de,
       name_fr,
       name_it,
       name_rm
FROM lbm.water_name_pt_subset
    );

DROP FUNCTION IF EXISTS lbm.layer_water_name(geometry, int, numeric);
CREATE OR REPLACE FUNCTION lbm.layer_water_name(bbox geometry, zoom_level int, pixel_width numeric)
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
                  SELECT the_geom_line AS the_geom,
                         class,
                         name,
                         COALESCE(NULLIF(name_latin, ''), name)      AS "name:latin",
                         COALESCE(NULLIF(name_de, ''), name)         AS "name:de",
                         COALESCE(NULLIF(name_fr, ''), name)         AS "name:fr",
                         COALESCE(NULLIF(name_it, ''), name)         AS "name:it",
                         COALESCE(NULLIF(name_rm, ''), name)         AS "name:rm"
                  FROM lbm.water_name_ln_z8
                  WHERE zoom_level = 8
                    AND the_geom_line && bbox
                  UNION ALL

                  SELECT the_geom_line AS the_geom,
                         class,
                         name,
                         COALESCE(NULLIF(name_latin, ''), name)      AS "name:latin",
                         COALESCE(NULLIF(name_de, ''), name)         AS "name:de",
                         COALESCE(NULLIF(name_fr, ''), name)         AS "name:fr",
                         COALESCE(NULLIF(name_it, ''), name)         AS "name:it",
                         COALESCE(NULLIF(name_rm, ''), name)         AS "name:rm"
                  FROM lbm.water_name_ln_z9
                  WHERE zoom_level = 9
                    AND the_geom_line && bbox
                  UNION ALL

                  SELECT the_geom_line AS the_geom,
                         class,
                         name,
                         COALESCE(NULLIF(name_latin, ''), name)      AS "name:latin",
                         COALESCE(NULLIF(name_de, ''), name)         AS "name:de",
                         COALESCE(NULLIF(name_fr, ''), name)         AS "name:fr",
                         COALESCE(NULLIF(name_it, ''), name)         AS "name:it",
                         COALESCE(NULLIF(name_rm, ''), name)         AS "name:rm"
                  FROM lbm.water_name_ln_z10
                  WHERE zoom_level = 10
                    AND the_geom_line && bbox
                  UNION ALL

                  SELECT the_geom_line AS the_geom,
                         class,
                         name,
                         COALESCE(NULLIF(name_latin, ''), name)      AS "name:latin",
                         COALESCE(NULLIF(name_de, ''), name)         AS "name:de",
                         COALESCE(NULLIF(name_fr, ''), name)         AS "name:fr",
                         COALESCE(NULLIF(name_it, ''), name)         AS "name:it",
                         COALESCE(NULLIF(name_rm, ''), name)         AS "name:rm"
                  FROM lbm.water_name_ln_z11
                  WHERE zoom_level = 11
                    AND the_geom_line && bbox
                  UNION ALL

                  SELECT the_geom_line AS the_geom,
                         class,
                         name,
                         COALESCE(NULLIF(name_latin, ''), name)      AS "name:latin",
                         COALESCE(NULLIF(name_de, ''), name)         AS "name:de",
                         COALESCE(NULLIF(name_fr, ''), name)         AS "name:fr",
                         COALESCE(NULLIF(name_it, ''), name)         AS "name:it",
                         COALESCE(NULLIF(name_rm, ''), name)         AS "name:rm"
                  FROM lbm.water_name_ln_z12
                  WHERE zoom_level = 12
                    AND the_geom_line && bbox
                  UNION ALL

                  SELECT the_geom_line AS the_geom,
                         class,
                         name,
                         COALESCE(NULLIF(name_latin, ''), name)      AS "name:latin",
                         COALESCE(NULLIF(name_de, ''), name)         AS "name:de",
                         COALESCE(NULLIF(name_fr, ''), name)         AS "name:fr",
                         COALESCE(NULLIF(name_it, ''), name)         AS "name:it",
                         COALESCE(NULLIF(name_rm, ''), name)         AS "name:rm"
                  FROM lbm.water_name_ln_z13_14
                  WHERE zoom_level >= 13
                    AND the_geom_line && bbox
              ) AS water_name_polygon

         UNION ALL

         SELECT the_geom, class, name, "name:latin", "name:de", "name:fr", "name:it", "name:rm"
         FROM (

                  SELECT the_geom_point AS the_geom,
                         class,
                         name,
                         COALESCE(NULLIF(name_latin, ''), name)      AS "name:latin",
                         COALESCE(NULLIF(name_de, ''), name)         AS "name:de",
                         COALESCE(NULLIF(name_fr, ''), name)         AS "name:fr",
                         COALESCE(NULLIF(name_it, ''), name)         AS "name:it",
                         COALESCE(NULLIF(name_rm, ''), name)         AS "name:rm"
                  FROM lbm.water_name_pt_z12
                  WHERE zoom_level = 12
                    AND the_geom_point && bbox
                  UNION ALL

                  SELECT the_geom_point AS the_geom,
                         class,
                         name,
                         COALESCE(NULLIF(name_latin, ''), name)      AS "name:latin",
                         COALESCE(NULLIF(name_de, ''), name)         AS "name:de",
                         COALESCE(NULLIF(name_fr, ''), name)         AS "name:fr",
                         COALESCE(NULLIF(name_it, ''), name)         AS "name:it",
                         COALESCE(NULLIF(name_rm, ''), name)         AS "name:rm"
                  FROM lbm.water_name_pt_z13
                  WHERE zoom_level = 13
                    AND the_geom_point && bbox
                  UNION ALL

                  SELECT the_geom_point AS the_geom,
                         class,
                         name,
                         COALESCE(NULLIF(name_latin, ''), name)      AS "name:latin",
                         COALESCE(NULLIF(name_de, ''), name)         AS "name:de",
                         COALESCE(NULLIF(name_fr, ''), name)         AS "name:fr",
                         COALESCE(NULLIF(name_it, ''), name)         AS "name:it",
                         COALESCE(NULLIF(name_rm, ''), name)         AS "name:rm"
                  FROM lbm.water_name_pt_z14
                  WHERE zoom_level >= 14
                    AND the_geom_point && bbox
              ) AS water_name_point
     ) AS water_name_all;
$$ LANGUAGE SQL STABLE
                PARALLEL SAFE;
-- TODO: Check if the above can be made STRICT -- i.e. if pixel_width could be NULL
