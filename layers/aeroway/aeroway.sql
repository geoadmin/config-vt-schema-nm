-- etldoc: layer_aeroway[shape=record fillcolor=lightpink, style="rounded,filled",
-- etldoc: label="layer_aeroway |<z11_> z11+ |<z13_> z13+" ];

DROP FUNCTION IF EXISTS lbm.layer_aeroway(geometry, integer);
CREATE OR REPLACE FUNCTION lbm.layer_aeroway(bbox geometry,
                                                 zoom_level integer)
    RETURNS TABLE
            (
                the_geom geometry,
                class    text
            )
AS
$$
SELECT the_geom, class

FROM(   
    -- etldoc: lbm_aeroway -> runway -> layer_aeroway:z11_
    SELECT the_geom, class
    FROM lbm.aeroway
    WHERE the_geom && bbox
      AND class = 'runway'
      AND zoom_level >= 11
  
    UNION ALL

    -- etldoc: lbm_aeroway -> runway_grass -> layer_aeroway:z13_
    SELECT the_geom, class
    FROM lbm.aeroway
    WHERE the_geom && bbox
      AND class = 'runway_grass'
      AND zoom_level >= 13

    ) AS zoom_levels
$$ LANGUAGE SQL STABLE
                -- STRICT
                PARALLEL SAFE;
