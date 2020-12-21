-- etldoc: layer_mountain_peak[shape=record fillcolor=lightpink, style="rounded,filled", label="layer_mountain_peak | <z9_> z9+ |<z11_> z11+ |<z12_> z12+ |<z13_> z13+" ] ;
DROP FUNCTION IF EXISTS lbm.layer_mountain_peak(geometry, integer, numeric);
CREATE OR REPLACE FUNCTION lbm.layer_mountain_peak(bbox geometry,
                                               zoom_level integer,
                                               pixel_width numeric)
    RETURNS TABLE
            (
                the_geom geometry,
                name          text,
                "name:latin"  text,
                "name:de"     text,
                "name:fr"     text,
                "name:it"     text,
                "name:rm"     text,
                class    text,
                ele      double precision,
                ele_ft   double precision,
                "rank"   double precision
            )
AS
$$
SELECT
    the_geom,
    name,
    "name:latin",
    "name:de",
    "name:fr",
    "name:it",
    "name:rm",
    class,
    ele,
    ele_ft,
    "rank"
FROM (
        -- etldoc: lbm_mountain_peak -> alpine_peak -> layer_mountain_peak:z9_
        (SELECT the_geom,
                name,
                COALESCE(NULLIF(name_latin, ''), name)                               AS "name:latin",
                COALESCE(NULLIF(name_de, ''), name)                                  AS "name:de",
                COALESCE(NULLIF(name_fr, ''), name)                                  AS "name:fr",
                COALESCE(NULLIF(name_it, ''), name)                                  AS "name:it",
                COALESCE(NULLIF(name_rm, ''), name)                                  AS "name:rm",
                class,
                ele,
                ele_ft,
                row_number() OVER (
                    PARTITION BY LabelGrid(the_geom, 100 * pixel_width)
                    ORDER BY (
                            ele +
                            (CASE WHEN NULLIF(name, '') IS NOT NULL THEN 10000 ELSE 0 END)
                        ) DESC
                    )::double precision                                             AS "rank"
        FROM lbm.mountain_peak
        WHERE the_geom && bbox
            AND zoom_level BETWEEN 9 AND 10
            AND class = 'alpine_peak'
        ORDER BY ele DESC)

        UNION ALL

        -- etldoc: lbm_mountain_peak -> main_peak,saddle -> layer_mountain_peak:z11_
        (SELECT the_geom,
                name,
                COALESCE(NULLIF(name_latin, ''), name)                               AS "name:latin",
                COALESCE(NULLIF(name_de, ''), name)                                  AS "name:de",
                COALESCE(NULLIF(name_fr, ''), name)                                  AS "name:fr",
                COALESCE(NULLIF(name_it, ''), name)                                  AS "name:it",
                COALESCE(NULLIF(name_rm, ''), name)                                  AS "name:rm",
                class,
                ele,
                ele_ft,
                row_number() OVER (
                    PARTITION BY LabelGrid(the_geom, 100 * pixel_width)
                    ORDER BY (
                            ele +
                            (CASE WHEN NULLIF(name, '') IS NOT NULL THEN 10000 ELSE 0 END)
                        ) DESC
                    )::double precision                                             AS "rank"
        FROM lbm.mountain_peak
        WHERE the_geom && bbox
            AND zoom_level = 11
            AND class IN ('alpine_peak', 'main_peak', 'saddle')
        ORDER BY ele DESC)

        UNION ALL

        -- etldoc: lbm_mountain_peak -> rocky_knoll,peak,main_hill,mountain_pass -> layer_mountain_peak:z12_
        (SELECT the_geom,
                name,
                COALESCE(NULLIF(name_latin, ''), name)                               AS "name:latin",
                COALESCE(NULLIF(name_de, ''), name)                                  AS "name:de",
                COALESCE(NULLIF(name_fr, ''), name)                                  AS "name:fr",
                COALESCE(NULLIF(name_it, ''), name)                                  AS "name:it",
                COALESCE(NULLIF(name_rm, ''), name)                                  AS "name:rm",
                class,
                ele,
                ele_ft,
                row_number() OVER (
                    PARTITION BY LabelGrid(the_geom, 100 * pixel_width)
                    ORDER BY (
                            ele +
                            (CASE WHEN NULLIF(name, '') IS NOT NULL THEN 10000 ELSE 0 END)
                        ) DESC
                    )::double precision                                             AS "rank"
        FROM lbm.mountain_peak
        WHERE the_geom && bbox
            AND zoom_level = 12
            AND class IN   ('alpine_peak', 
                            'main_peak', 
                            'saddle', 
                            'rocky_knoll', 
                            'peak', 
                            'main_hill', 
                            'mountain_pass')
        ORDER BY ele DESC)

        UNION ALL

        -- etldoc: lbm_mountain_peak -> hill -> layer_mountain_peak:z13_
        SELECT the_geom,
                name,
                COALESCE(NULLIF(name_latin, ''), name)                               AS "name:latin",
                COALESCE(NULLIF(name_de, ''), name)                                  AS "name:de",
                COALESCE(NULLIF(name_fr, ''), name)                                  AS "name:fr",
                COALESCE(NULLIF(name_it, ''), name)                                  AS "name:it",
                COALESCE(NULLIF(name_rm, ''), name)                                  AS "name:rm",
                class,
                ele,
                ele_ft,
                row_number() OVER (
                    PARTITION BY LabelGrid(the_geom, 100 * pixel_width)
                    ORDER BY (
                            ele +
                            (CASE WHEN NULLIF(name, '') IS NOT NULL THEN 10000 ELSE 0 END)
                        ) DESC
                    )::double precision                                             AS "rank"
        FROM lbm.mountain_peak
        WHERE the_geom && bbox
            AND zoom_level >= 13
     ) AS ranked_peaks
-- WHERE zoom_level >= 7 --AND (rank <= 5 OR zoom_level >= 14)
ORDER BY "rank" ASC;

$$ LANGUAGE SQL STABLE
                PARALLEL SAFE;
-- TODO: Check if the above can be made STRICT -- i.e. if pixel_width could be NULL