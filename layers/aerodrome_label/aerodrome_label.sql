
-- etldoc: layer_aerodrome_label[shape=record fillcolor=lightpink, style="rounded,filled", label="layer_aerodrome_label |<z11_> z11+ |<z12_> z12+|<z14_> z14+" ];

DROP FUNCTION IF EXISTS lbm.layer_aerodrome_label(geometry, integer);
CREATE OR REPLACE FUNCTION lbm.layer_aerodrome_label(bbox geometry,
                                                 zoom_level integer)
    RETURNS TABLE
            (
                the_geom      geometry,
                name          text,
                "name:latin"  text,
                "name:de"     text,
                "name:fr"     text,
                "name:it"     text,
                "name:rm"     text,
                class         text,
                ele           double precision,
                ele_ft        double precision,
                iata          text,
                icao          text
            )
AS
$$
SELECT *
FROM (
        SELECT
            -- etldoc: lbm_aerodrome_label -> international
            -- etldoc: lbm_aerodrome_label -> regional
            -- etldoc: international -> layer_aerodrome_label:z11_
            -- etldoc: regional -> layer_aerodrome_label:z11_
            the_geom,
            name,
            COALESCE(NULLIF(name_latin, ''), name)                               AS "name:latin",
            COALESCE(NULLIF(name_de, ''), name)                                  AS "name:de",
            COALESCE(NULLIF(name_fr, ''), name)                                  AS "name:fr",
            COALESCE(NULLIF(name_it, ''), name)                                  AS "name:it",
            COALESCE(NULLIF(name_rm, ''), name)                                  AS "name:rm",
            class,
            ele,
            ele_ft,
            iata,
            icao
        FROM lbm.aerodrome_label
        WHERE the_geom && bbox
          AND class IN ('international','regional') 
          AND zoom_level >= 11

        UNION ALL

        SELECT
            -- etldoc: lbm_aerodrome_label -> other
            -- etldoc: other -> layer_aerodrome_label:z12_
            the_geom,
            name,
            COALESCE(NULLIF(name_latin, ''), name)                               AS "name:latin",
            COALESCE(NULLIF(name_de, ''), name)                                  AS "name:de",
            COALESCE(NULLIF(name_fr, ''), name)                                  AS "name:fr",
            COALESCE(NULLIF(name_it, ''), name)                                  AS "name:it",
            COALESCE(NULLIF(name_rm, ''), name)                                  AS "name:rm",
            class,
            ele,
            ele_ft,
            iata,
            icao
        FROM lbm.aerodrome_label
        WHERE the_geom && bbox
          AND class = 'other'
          AND zoom_level >= 12

        UNION ALL

        SELECT
            -- etldoc: lbm_aerodrome_label -> helipad
            -- etldoc: helipad -> layer_aerodrome_label:z14_
            the_geom,
            name,
            COALESCE(NULLIF(name_latin, ''), name)                               AS "name:latin",
            COALESCE(NULLIF(name_de, ''), name)                                  AS "name:de",
            COALESCE(NULLIF(name_fr, ''), name)                                  AS "name:fr",
            COALESCE(NULLIF(name_it, ''), name)                                  AS "name:it",
            COALESCE(NULLIF(name_rm, ''), name)                                  AS "name:rm",
            class,
            ele,
            ele_ft,
            iata,
            icao
        FROM lbm.aerodrome_label
        WHERE the_geom && bbox
          AND class = 'helipad'
          AND zoom_level >= 14
    ) AS zoom_levels
$$ LANGUAGE SQL STABLE
                -- STRICT
                PARALLEL SAFE;
