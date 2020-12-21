-- etldoc: layer_place[shape=record fillcolor=lightpink, style="rounded,filled",
-- etldoc:     label="layer_place | <z0_7> z0-7| <z4_> z4+ |<z6_> z6+|<z7_> z7+| <z8_> z8+| <z9_> z9+| <z10_> z10+| <z11_> z11+| <z12_> z12+| <z13_> z13+| <z14_> z14+" ] ;

DROP FUNCTION IF EXISTS lbm.layer_place(geometry, int, numeric);
CREATE OR REPLACE FUNCTION lbm.layer_place(bbox geometry, zoom_level int, pixel_width numeric)
    RETURNS TABLE
            (
                the_geom geometry,
                name     text,
                "name:latin"  text,
                "name:de"  text,
                "name:fr"  text,
                "name:it"  text,
                "name:rm"  text,
                class    text,
                "rank"   integer,
                capital  integer,
                iso_a2   text,
                code     text,
                population integer
            )
AS
$$
SELECT *
FROM (
         (SELECT
             -- etldoc: lbm_place -> country -> layer_place:z0_7
             the_geom,
             name,
             COALESCE(NULLIF(name_latin, ''), name)      AS "name:latin",
             COALESCE(NULLIF(name_de, ''), name)         AS "name:de",
             COALESCE(NULLIF(name_fr, ''), name)         AS "name:fr",
             COALESCE(NULLIF(name_it, ''), name)         AS "name:it",
             COALESCE(NULLIF(name_rm, ''), name)         AS "name:rm",
             class,
             1                                            AS "rank",
             NULL::int                                    AS capital,
             iso_a2,
             NULL::text                                   AS code,
             population
         FROM lbm.place
         WHERE the_geom && bbox
           AND class = 'country'
           AND zoom_level < 8)

         UNION ALL

-- don't select canton, district, municipality for lbm but keep code for LK

--         SELECT
--             -- etldoc: lbm_place -> canton -> layer_place:z5_10
--             the_geom,
--             name,
--             COALESCE(NULLIF(name_latin, ''), name)      AS "name:latin",
--             COALESCE(NULLIF(name_de, ''), name)         AS "name:de",
--             COALESCE(NULLIF(name_fr, ''), name)         AS "name:fr",
--             COALESCE(NULLIF(name_it, ''), name)         AS "name:it",
--             COALESCE(NULLIF(name_rm, ''), name)         AS "name:rm",
--             class,
--             "rank",
--             NULL::int                                    AS capital,
--             NULL::text                                   AS iso_a2,
--             code,
--             population
--         FROM lbm.place
--         WHERE the_geom && bbox
--          
--           AND class = 'canton'
--           AND zoom_level BETWEEN 5 AND 10 

--         UNION ALL

--         SELECT
--             -- etldoc: lbm_place -> district -> layer_place:z8_
--             the_geom,
--             name,
--             COALESCE(NULLIF(name_latin, ''), name)      AS "name:latin",
--             COALESCE(NULLIF(name_de, ''), name)         AS "name:de",
--             COALESCE(NULLIF(name_fr, ''), name)         AS "name:fr",
--             COALESCE(NULLIF(name_it, ''), name)         AS "name:it",
--             COALESCE(NULLIF(name_rm, ''), name)         AS "name:rm",
--             class,
--             "rank",
--             NULL::int                                    AS capital,
--             NULL::text                                   AS iso_a2,
--             NULL::text                                   AS code,
--             population
--         FROM lbm.place
--         WHERE the_geom && bbox
--          
--           AND class = 'district'
--           AND zoom_level >= 8 

--         UNION ALL

--         SELECT
--             -- etldoc: lbm_place -> municipality -> layer_place:z10_
--             the_geom,
--             name,
--             COALESCE(NULLIF(name_latin, ''), name)      AS "name:latin",
--             COALESCE(NULLIF(name_de, ''), name)         AS "name:de",
--             COALESCE(NULLIF(name_fr, ''), name)         AS "name:fr",
--             COALESCE(NULLIF(name_it, ''), name)         AS "name:it",
--             COALESCE(NULLIF(name_rm, ''), name)         AS "name:rm",
--             class,
--             "rank",
--             NULL::int                                    AS capital,
--             NULL::text                                   AS iso_a2,
--             NULL::text                                   AS code,
             --population
--         FROM lbm.place
--         WHERE the_geom && bbox
          
--           AND class = 'municipality'
--           AND zoom_level >= 10 

--         UNION ALL

         (SELECT
            -- etldoc: lbm_place -> city -> layer_place:z4_
             the_geom,
             name,
             COALESCE(NULLIF(name_latin, ''), name)      AS "name:latin",
             COALESCE(NULLIF(name_de, ''), name)         AS "name:de",
             COALESCE(NULLIF(name_fr, ''), name)         AS "name:fr",
             COALESCE(NULLIF(name_it, ''), name)         AS "name:it",
             COALESCE(NULLIF(name_rm, ''), name)         AS "name:rm",
             class,
             "rank",
             capital,
             NULL::text                                   AS iso_a2,
             NULL::text                                   AS code,
             population
         FROM lbm.place
         WHERE the_geom && bbox
           AND class = 'city' AND "rank" <= 3
           AND zoom_level >= 4
         ORDER BY population DESC,"rank" ASC)

         UNION ALL

         (SELECT
            -- etldoc: city -> layer_place:z6_
             the_geom,
             name,
             COALESCE(NULLIF(name_latin, ''), name)      AS "name:latin",
             COALESCE(NULLIF(name_de, ''), name)         AS "name:de",
             COALESCE(NULLIF(name_fr, ''), name)         AS "name:fr",
             COALESCE(NULLIF(name_it, ''), name)         AS "name:it",
             COALESCE(NULLIF(name_rm, ''), name)         AS "name:rm",
             class,
             "rank",
             capital,
             NULL::text                                   AS iso_a2,
             NULL::text                                   AS code,
             population
         FROM lbm.place
         WHERE the_geom && bbox
          
           AND class = 'city' AND "rank" = 4
           AND zoom_level >= 6
         ORDER BY population DESC,"rank" ASC)

         UNION ALL

         (SELECT
            -- etldoc: lbm_place -> town -> layer_place:z7_
            -- etldoc: lbm_place -> village -> layer_place:z7_
             the_geom,
             name,
             COALESCE(NULLIF(name_latin, ''), name)      AS "name:latin",
             COALESCE(NULLIF(name_de, ''), name)         AS "name:de",
             COALESCE(NULLIF(name_fr, ''), name)         AS "name:fr",
             COALESCE(NULLIF(name_it, ''), name)         AS "name:it",
             COALESCE(NULLIF(name_rm, ''), name)         AS "name:rm",
             class,
             "rank",
             capital,
             NULL::text                                   AS iso_a2,
             NULL::text                                   AS code,
             population
         FROM lbm.place
         WHERE the_geom && bbox
           AND "rank" IN (5,10)
           AND zoom_level >= 7
         ORDER BY population DESC,"rank" ASC)

         UNION ALL

         (SELECT
            -- etldoc: town -> layer_place:z8_
            -- etldoc: village -> layer_place:z8_
             the_geom,
             name,
             COALESCE(NULLIF(name_latin, ''), name)      AS "name:latin",
             COALESCE(NULLIF(name_de, ''), name)         AS "name:de",
             COALESCE(NULLIF(name_fr, ''), name)         AS "name:fr",
             COALESCE(NULLIF(name_it, ''), name)         AS "name:it",
             COALESCE(NULLIF(name_rm, ''), name)         AS "name:rm",
             class,
             "rank",
             capital,
             NULL::text                                   AS iso_a2,
             NULL::text                                   AS code,
             population
         FROM lbm.place
         WHERE the_geom && bbox
           AND class IN ('town','village') AND "rank" BETWEEN 11 AND 13
           AND zoom_level >= 8
         ORDER BY population DESC,"rank" ASC)

         UNION ALL

         (SELECT
            -- etldoc: village -> layer_place:z9_
             the_geom,
             name,
             COALESCE(NULLIF(name_latin, ''), name)      AS "name:latin",
             COALESCE(NULLIF(name_de, ''), name)         AS "name:de",
             COALESCE(NULLIF(name_fr, ''), name)         AS "name:fr",
             COALESCE(NULLIF(name_it, ''), name)         AS "name:it",
             COALESCE(NULLIF(name_rm, ''), name)         AS "name:rm",
             class,
             "rank",
             capital,
             NULL::text                                   AS iso_a2,
             NULL::text                                   AS code,
             population
         FROM lbm.place
         WHERE the_geom && bbox
           AND class NOT IN ('suburb','neighbourhood') AND "rank" = 14
           AND zoom_level >= 9
         ORDER BY population DESC,"rank" ASC)

         UNION ALL

         (SELECT
            -- etldoc: village -> layer_place:z10_
             the_geom,
             name,
             COALESCE(NULLIF(name_latin, ''), name)      AS "name:latin",
             COALESCE(NULLIF(name_de, ''), name)         AS "name:de",
             COALESCE(NULLIF(name_fr, ''), name)         AS "name:fr",
             COALESCE(NULLIF(name_it, ''), name)         AS "name:it",
             COALESCE(NULLIF(name_rm, ''), name)         AS "name:rm",
             class,
             "rank",
             capital,
             NULL::text                                   AS iso_a2,
             NULL::text                                   AS code,
             population
         FROM lbm.place
         WHERE the_geom && bbox
           AND class NOT IN ('suburb','neighbourhood') AND "rank" BETWEEN 15 AND 17
           AND zoom_level >= 10
         ORDER BY population DESC,"rank" ASC)

         UNION ALL

         (SELECT
            -- etldoc: village -> layer_place:z11_
             the_geom,
             name,
             COALESCE(NULLIF(name_latin, ''), name)      AS "name:latin",
             COALESCE(NULLIF(name_de, ''), name)         AS "name:de",
             COALESCE(NULLIF(name_fr, ''), name)         AS "name:fr",
             COALESCE(NULLIF(name_it, ''), name)         AS "name:it",
             COALESCE(NULLIF(name_rm, ''), name)         AS "name:rm",
             class,
             "rank",
             capital,
             NULL::text                                   AS iso_a2,
             NULL::text                                   AS code,
             population
         FROM lbm.place
         WHERE the_geom && bbox
           AND class = 'village' AND "rank" BETWEEN 18 AND 27
           AND zoom_level >= 11
         ORDER BY population DESC,"rank" ASC)

         UNION ALL

         (SELECT
            -- etldoc: village -> layer_place:z12_
            -- etldoc: lbm_place -> hamlet -> layer_place:z12_
             the_geom,
             name,
             COALESCE(NULLIF(name_latin, ''), name)      AS "name:latin",
             COALESCE(NULLIF(name_de, ''), name)         AS "name:de",
             COALESCE(NULLIF(name_fr, ''), name)         AS "name:fr",
             COALESCE(NULLIF(name_it, ''), name)         AS "name:it",
             COALESCE(NULLIF(name_rm, ''), name)         AS "name:rm",
             class,
             "rank",
             capital,
             NULL::text                                   AS iso_a2,
             NULL::text                                   AS code,
             population
         FROM lbm.place
         WHERE the_geom && bbox
           AND class IN ('village','hamlet') AND "rank" BETWEEN 28 AND 29
           AND zoom_level >= 12
         ORDER BY population DESC,"rank" ASC)

         UNION ALL

         (SELECT
            -- etldoc: hamlet -> layer_place:z13_
             the_geom,
             name,
             COALESCE(NULLIF(name_latin, ''), name)      AS "name:latin",
             COALESCE(NULLIF(name_de, ''), name)         AS "name:de",
             COALESCE(NULLIF(name_fr, ''), name)         AS "name:fr",
             COALESCE(NULLIF(name_it, ''), name)         AS "name:it",
             COALESCE(NULLIF(name_rm, ''), name)         AS "name:rm",
             class,
             "rank",
             capital,
             NULL::text                                   AS iso_a2,
             NULL::text                                   AS code,
             population
         FROM lbm.place
         WHERE the_geom && bbox
           AND class IN ('hamlet','isolated_dwelling') AND "rank" BETWEEN 30 AND 32
           AND zoom_level >= 13
         ORDER BY population DESC,"rank" ASC)

         UNION ALL

         (SELECT
            -- etldoc: lbm_place -> suburb -> layer_place:z12_
             the_geom,
             name,
             COALESCE(NULLIF(name_latin, ''), name)      AS "name:latin",
             COALESCE(NULLIF(name_de, ''), name)         AS "name:de",
             COALESCE(NULLIF(name_fr, ''), name)         AS "name:fr",
             COALESCE(NULLIF(name_it, ''), name)         AS "name:it",
             COALESCE(NULLIF(name_rm, ''), name)         AS "name:rm",
             class,
             "rank",
             capital,
             NULL::text                                   AS iso_a2,
             NULL::text                                   AS code,
             population
         FROM lbm.place
         WHERE the_geom && bbox
           AND class = 'suburb'
           AND zoom_level >= 12)

         UNION ALL

         (SELECT
            -- etldoc: lbm_place -> neighbourhood -> layer_place:z14_
             the_geom,
             name,
             COALESCE(NULLIF(name_latin, ''), name)      AS "name:latin",
             COALESCE(NULLIF(name_de, ''), name)         AS "name:de",
             COALESCE(NULLIF(name_fr, ''), name)         AS "name:fr",
             COALESCE(NULLIF(name_it, ''), name)         AS "name:it",
             COALESCE(NULLIF(name_rm, ''), name)         AS "name:rm",
             class,
             "rank",
             capital,
             NULL::text                                   AS iso_a2,
             NULL::text                                   AS code,
             population
         FROM lbm.place
         WHERE the_geom && bbox
           AND class = 'neighbourhood'
           AND zoom_level >= 14)

    ) AS zoom_levels
$$ LANGUAGE SQL STABLE
                PARALLEL SAFE;
-- TODO: Check if the above can be made STRICT -- i.e. if pixel_width could be NULL
