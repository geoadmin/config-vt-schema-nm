-- etldoc: lbm_contour_line -> contour_line_100
DROP MATERIALIZED VIEW IF EXISTS lbm.contour_line_z13 CASCADE;
CREATE MATERIALIZED VIEW lbm.contour_line_z13 AS
(
SELECT ST_SimplifyPreserveTopology(the_geom, 10) AS the_geom,
        class,
        ele,
        ele_ft
 FROM lbm.contour_line 
    -- get only contour lines where (ele % 100) = 0 for z13
    WHERE mod(CAST(ele AS NUMERIC), 100::numeric) = 0 AND (class != 'rock' OR class IS NULL)
    ) /* DELAY_MATERIALIZED_VIEW_CREATION */;
CREATE INDEX IF NOT EXISTS contour_line_z13_idx ON lbm.contour_line_z13 USING gist (the_geom);

DROP MATERIALIZED VIEW IF EXISTS lbm.contour_line_z14 CASCADE;
CREATE MATERIALIZED VIEW lbm.contour_line_z14 AS
(
SELECT ST_SimplifyPreserveTopology(the_geom, 2) AS the_geom,
        class,
        ele,
        ele_ft
 FROM lbm.contour_line 
    WHERE (class != 'rock' OR class IS NULL)
    ) /* DELAY_MATERIALIZED_VIEW_CREATION */;
CREATE INDEX IF NOT EXISTS contour_line_z14_idx ON lbm.contour_line_z14 USING gist (the_geom);


-- etldoc: layer_contour_line[shape=record fillcolor=lightpink, style="rounded,filled", label="<sql> layer_contour_line | <z13> z13 | <z14> z14+"];
CREATE OR REPLACE FUNCTION lbm.layer_contour_line(bbox geometry, zoom_level integer)
    RETURNS TABLE
            (
                the_geom        geometry,
                class           text,
                ele             double precision,
                ele_ft          double precision
            )
AS
$$
SELECT the_geom,
       class,
       ele,
       ele_ft
FROM (
        -- etldoc:  contour_line_100 -> layer_contour_line:z13
        SELECT *
        FROM lbm.contour_line_z13
        WHERE zoom_level = 13
            AND the_geom && bbox
        UNION ALL
        --etldoc: lbm_contour_line -> layer_contour_line:z14
        SELECT *
        FROM lbm.contour_line_z14
        WHERE zoom_level >= 14
            AND the_geom && bbox
        ) AS zoom_levels;
$$ LANGUAGE SQL STABLE
                -- STRICT
                PARALLEL SAFE;