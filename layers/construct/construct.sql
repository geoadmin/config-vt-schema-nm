-- etldoc: layer_construct[shape=record fillcolor=lightpink, style="rounded,filled",
-- etldoc: label="layer_construct |<z13_> z13+ |<z14_> z14+" ];

-- possible enhancement for lower zoom levels
/*CREATE EXTENSION postgis_sfcgal;
CREATE MATERIALIZED VIEW lbm.construct_gen1 AS
(
SELECT bgdi_id, ST_ApproximateMedialAxis(the_geom) as the_geom, class
FROM lbm.construct
    );
CREATE INDEX ON lbm.construct_gen1 USING gist (the_geom);
*/
DROP FUNCTION IF EXISTS lbm.layer_construct(geometry,int);
CREATE OR REPLACE FUNCTION lbm.layer_construct(bbox geometry, zoom_level int)
    RETURNS TABLE
            (
                the_geom geometry,
                class    text
            )
AS
$$
SELECT the_geom, class
FROM (
         -- etldoc:  lbm_construct -> dam -> layer_construct:z13_
         SELECT the_geom, class
         FROM lbm.construct
         WHERE zoom_level = 13
           AND class = 'dam'

        UNION ALL

         -- etldoc:  lbm_construct -> platform -> layer_construct:z14_
         -- etldoc:  lbm_construct -> lock -> layer_construct:z14_
         SELECT the_geom, class
         FROM lbm.construct
         WHERE zoom_level >= 14
           AND class IN ('platform','dam','lock')
     ) AS zoom_levels
WHERE the_geom && bbox;
$$ LANGUAGE SQL STABLE
                -- STRICT
                PARALLEL SAFE;
