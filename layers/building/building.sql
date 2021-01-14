-- etldoc: layer_building[shape=record fillcolor=lightpink, style="rounded,filled",
-- etldoc:     label="layer_building | <z13_> z13+ " ] ;

DROP VIEW IF EXISTS lbm.all_buildings CASCADE;
CREATE OR REPLACE VIEW lbm.all_buildings AS
(
SELECT
    -- Standalone buildings
    the_geom,
    render_height,
    render_min_height
FROM lbm.building
WHERE ST_GeometryType(the_geom) IN ('ST_Polygon', 'ST_MultiPolygon')
    );

DROP FUNCTION IF EXISTS lbm.layer_building(geometry, int);
CREATE OR REPLACE FUNCTION lbm.layer_building(bbox geometry, zoom_level int)
    RETURNS TABLE
            (
                the_geom          geometry,
                render_height     int,
                render_min_height int
            )
AS
$$
SELECT the_geom,
       render_height,
       render_min_height
FROM (
         SELECT
             -- etldoc: building -> layer_building:z13_
             the_geom,
             render_height,
             render_min_height
         FROM lbm.all_buildings
         WHERE zoom_level >= 13
           AND the_geom && bbox
     ) AS zoom_levels
ORDER BY render_height ASC, ST_YMin(the_geom) DESC;
$$ LANGUAGE SQL STABLE
                -- STRICT
                PARALLEL SAFE
                ;

-- not handled: where a building outline covers building parts
