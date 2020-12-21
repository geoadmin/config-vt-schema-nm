-- etldoc: layer_transportation[shape=record fillcolor=lightpink, style="rounded,filled",
-- etldoc:     label="<sql> layer_transportation |<z7_> z7+ |<z8_> z8+ |<z10_> z10+ |<z11_> z11+ |<z12_> z12+ |<z13_> z13+ |<z14_> z14+" ] ;

DROP FUNCTION IF EXISTS lbm.layer_transportation(geometry, int);
CREATE OR REPLACE FUNCTION lbm.layer_transportation(bbox geometry, zoom_level int)
    RETURNS TABLE
            (
                the_geom  geometry,
                class     text,
                subclass  text,
                brunnel   text,
                ramp      int,
                oneway    int,
                layer     int,
                surface   text,
                sac_scale text,
                service   text
            )
AS
$$
SELECT the_geom,
       class,
       subclass,
       brunnel,
       ramp,
       oneway,
       layer,
       surface,
       sac_scale,
       service
FROM (
        -- etldoc: motorway -> layer_transportation:z7_
        -- etldoc: trunk -> layer_transportation:z7_
        -- etldoc: lbm_transportation -> primary_subset -> layer_transportation:z7_
         SELECT the_geom,
                class,
                NULL::text    AS subclass,
                NULL::text    AS brunnel,
                ramp,
                NULL::int     AS oneway,
                NULL::int     AS layer,
                NULL::text    AS surface,
                NULL::text    AS sac_scale,
                NULL::text    AS service
         FROM lbm.road_z7
         WHERE zoom_level = 7
         UNION ALL

         SELECT the_geom,
                class,
                NULL::text    AS subclass,
                NULL::text    AS brunnel,
                ramp,
                NULL::int     AS oneway,
                NULL::int     AS layer,
                NULL::text    AS surface,
                NULL::text    AS sac_scale,
                NULL::text    AS service
         FROM lbm.road_z8
         WHERE zoom_level = 8
         UNION ALL

        -- etldoc: lbm_transportation -> rail_subset -> layer_transportation:z8_
         SELECT the_geom,
                class,
                subclass,
                NULL::text    AS brunnel,
                NULL::int     AS ramp,
                NULL::int     AS oneway,
                NULL::int     AS layer,
                NULL::text    AS surface,
                NULL::text    AS sac_scale,
                NULL::text    AS service
         FROM lbm.railway_z8
         WHERE zoom_level = 8
         UNION ALL

         SELECT the_geom,
                class,
                NULL::text    AS subclass,
                NULL::text    AS brunnel,
                ramp,
                NULL::int     AS oneway,
                NULL::int     AS layer,
                NULL::text    AS surface,
                NULL::text    AS sac_scale,
                NULL::text    AS service
         FROM lbm.road_z9
         WHERE zoom_level = 9
         UNION ALL

         SELECT the_geom,
                class,
                subclass,
                NULL::text    AS brunnel,
                NULL::int     AS ramp,
                NULL::int     AS oneway,
                NULL::int     AS layer,
                NULL::text    AS surface,
                NULL::text    AS sac_scale,
                NULL::text    AS service
         FROM lbm.railway_z9
         WHERE zoom_level = 9
         UNION ALL

         SELECT the_geom,
                class,
                NULL::text    AS subclass,
                NULL::text    AS brunnel,
                NULL::int     AS ramp,
                NULL::int     AS oneway,
                NULL::int     AS layer,
                NULL::text    AS surface,
                NULL::text    AS sac_scale,
                NULL::text    AS service
         FROM lbm.aerialway_ferry_z9
         WHERE zoom_level = 9
         UNION ALL

         SELECT the_geom,
                class,
                subclass,
                brunnel,
                ramp,
                oneway,
                layer,
                surface,
                sac_scale,
                NULL::text    AS service
         FROM lbm.road_z10
         WHERE zoom_level = 10
         UNION ALL

         SELECT the_geom,
                class,
                subclass,
                brunnel,
                NULL::int     AS ramp,
                NULL::int     AS oneway,
                layer,
                NULL::text    AS surface,
                NULL::text    AS sac_scale,
                service
         FROM lbm.railway_z10
         WHERE zoom_level = 10
         UNION ALL

         -- etldoc: car_ferry -> layer_transportation:z10_
         SELECT the_geom,
                class,
                NULL::text    AS subclass,
                NULL::text    AS brunnel,
                NULL::int     AS ramp,
                NULL::int     AS oneway,
                NULL::int     AS layer,
                NULL::text    AS surface,
                NULL::text    AS sac_scale,
                NULL::text    AS service
         FROM lbm.aerialway_ferry_z10
         WHERE zoom_level = 10
         UNION ALL

         SELECT the_geom,
                class,
                subclass,
                brunnel,
                ramp,
                oneway,
                layer,
                surface,
                sac_scale,
                NULL::text    AS service
         FROM lbm.road_z11
         WHERE zoom_level = 11
         UNION ALL

        -- etldoc: rail -> layer_transportation:z11_
         SELECT the_geom,
                class,
                subclass,
                brunnel,
                NULL::int     AS ramp,
                NULL::int     AS oneway,
                layer,
                NULL::text    AS surface,
                NULL::text    AS sac_scale,
                service
         FROM lbm.railway_z11
         WHERE zoom_level = 11
         UNION ALL

         SELECT the_geom,
                class,
                NULL::text    AS subclass,
                NULL::text    AS brunnel,
                NULL::int     AS ramp,
                NULL::int     AS oneway,
                NULL::int     AS layer,
                NULL::text    AS surface,
                NULL::text    AS sac_scale,
                NULL::text    AS service
         FROM lbm.aerialway_ferry_z11
         WHERE zoom_level = 11
         UNION ALL

        -- etldoc: primary -> layer_transportation:z12_
        -- etldoc: secondary -> layer_transportation:z12_
        -- etldoc: tertiary -> layer_transportation:z12_
        -- etldoc: minor -> layer_transportation:z12_
         SELECT the_geom,
                class,
                subclass,
                brunnel,
                ramp,
                oneway,
                layer,
                surface,
                sac_scale,
                NULL::text    AS service
         FROM lbm.road_z12
         WHERE zoom_level = 12
         UNION ALL

         SELECT the_geom,
                class,
                subclass,
                brunnel,
                NULL::int     AS ramp,
                NULL::int     AS oneway,
                layer,
                NULL::text    AS surface,
                NULL::text    AS sac_scale,
                service
         FROM lbm.railway_z12
         WHERE zoom_level = 12
         UNION ALL

         -- etldoc: ferry -> layer_transportation:z12_
         -- etldoc: cable_car -> layer_transportation:z12_
         -- etldoc: gondola -> layer_transportation:z12_
         SELECT the_geom,
                class,
                NULL::text    AS subclass,
                NULL::text    AS brunnel,
                NULL::int     AS ramp,
                NULL::int     AS oneway,
                NULL::int     AS layer,
                NULL::text    AS surface,
                NULL::text    AS sac_scale,
                NULL::text    AS service
         FROM lbm.aerialway_ferry_z12
         WHERE zoom_level = 12
         UNION ALL

         SELECT the_geom,
                class,
                subclass,
                brunnel,
                ramp,
                oneway,
                layer,
                surface,
                sac_scale,
                NULL::text    AS service
         FROM lbm.road_z13
         WHERE zoom_level = 13
         UNION ALL

        -- etldoc: transit -> layer_transportation:z13_
         SELECT the_geom,
                class,
                subclass,
                brunnel,
                NULL::int     AS ramp,
                NULL::int     AS oneway,
                layer,
                NULL::text    AS surface,
                NULL::text    AS sac_scale,
                service
         FROM lbm.railway_z13
         WHERE zoom_level = 13
         UNION ALL

         -- etldoc: chair_lift -> layer_transportation:z13_
         SELECT the_geom,
                class,
                NULL::text    AS subclass,
                NULL::text    AS brunnel,
                NULL::int     AS ramp,
                NULL::int     AS oneway,
                NULL::int     AS layer,
                NULL::text    AS surface,
                NULL::text    AS sac_scale,
                NULL::text    AS service
         FROM lbm.aerialway_ferry_z13_14
         WHERE zoom_level = 13
         UNION ALL

        -- etldoc: path -> layer_transportation:z14_
        -- etldoc: track -> layer_transportation:z14_
        -- etldoc: service -> layer_transportation:z14_
        -- etldoc: via_ferrata -> layer_transportation:z14_
         SELECT the_geom,
                class,
                subclass,
                brunnel,
                ramp,
                oneway,
                layer,
                surface,
                sac_scale,
                NULL::text    AS service
         FROM lbm.road_z14
         WHERE zoom_level >= 14
         UNION ALL

         SELECT the_geom,
                class,
                subclass,
                brunnel,
                NULL::int     AS ramp,
                NULL::int     AS oneway,
                layer,
                NULL::text    AS surface,
                NULL::text    AS sac_scale,
                service
         FROM lbm.railway_z14
         WHERE zoom_level >= 14
         UNION ALL

         SELECT the_geom,
                class,
                NULL::text    AS subclass,
                NULL::text    AS brunnel,
                NULL::int     AS ramp,
                NULL::int     AS oneway,
                NULL::int     AS layer,
                NULL::text    AS surface,
                NULL::text    AS sac_scale,
                NULL::text    AS service
         FROM lbm.aerialway_ferry_z13_14
         WHERE zoom_level >= 14

     ) AS zoom_levels
WHERE the_geom && bbox;
$$ LANGUAGE SQL STABLE
                -- STRICT
                PARALLEL SAFE;
