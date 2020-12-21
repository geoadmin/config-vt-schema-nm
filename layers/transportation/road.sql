-- etldoc: lbm_transportation ->  motorway
-- etldoc: lbm_transportation ->  trunk
-- etldoc: lbm_transportation ->  primary
-- etldoc: lbm_transportation ->  secondary
-- etldoc: lbm_transportation ->  tertiary
-- etldoc: lbm_transportation ->  minor
-- etldoc: lbm_transportation ->  path
-- etldoc: lbm_transportation ->  track
-- etldoc: lbm_transportation ->  service
-- etldoc: lbm_transportation ->  via_ferrata
DROP MATERIALIZED VIEW IF EXISTS lbm.road_merge CASCADE;
CREATE MATERIALIZED VIEW lbm.road_merge AS
(
SELECT (ST_Dump(the_geom)).geom AS the_geom,
       class,
       ramp,
       is_route
FROM (
         SELECT ST_LineMerge(ST_Collect(the_geom)) AS the_geom,
                class,
                ramp,
                is_route
         FROM lbm.transportation
         WHERE class IN ('motorway','trunk') OR is_route IN (5, 6, 7, 8, 10)
           AND ST_IsValid(the_geom)
         GROUP BY class, ramp, is_route
	) as road_union
    ) /* DELAY_MATERIALIZED_VIEW_CREATION */;
CREATE INDEX IF NOT EXISTS road_merge_idx ON lbm.road_merge USING gist (the_geom);
CREATE INDEX IF NOT EXISTS road_merge_partial_idx ON lbm.road_merge (class, ramp, is_route);

DROP MATERIALIZED VIEW IF EXISTS lbm.road_z7 CASCADE;
CREATE MATERIALIZED VIEW lbm.road_z7 AS
(
SELECT ST_Simplify(the_geom, 200) AS the_geom, 
       class, 
       ramp,
       is_route
FROM lbm.road_merge
WHERE class IN ('motorway','trunk') OR is_route IN (5, 10)
    ) /* DELAY_MATERIALIZED_VIEW_CREATION */;
CREATE INDEX IF NOT EXISTS road_z7_idx ON lbm.road_z7 USING gist (the_geom);

DROP MATERIALIZED VIEW IF EXISTS lbm.road_z8 CASCADE;
CREATE MATERIALIZED VIEW lbm.road_z8 AS
(
SELECT ST_Simplify(the_geom, 120) AS the_geom, 
       class, 
       ramp,
       is_route
FROM lbm.road_merge
WHERE class IN ('motorway','trunk') OR is_route IN (5, 10)
    ) /* DELAY_MATERIALIZED_VIEW_CREATION */;
CREATE INDEX IF NOT EXISTS road_z8_idx ON lbm.road_z8 USING gist (the_geom);

DROP MATERIALIZED VIEW IF EXISTS lbm.road_z9 CASCADE;
CREATE MATERIALIZED VIEW lbm.road_z9 AS
(
SELECT ST_Simplify(the_geom, 40) AS the_geom, 
       class, 
       ramp,
       is_route
FROM lbm.road_merge
    ) /* DELAY_MATERIALIZED_VIEW_CREATION */;
CREATE INDEX IF NOT EXISTS road_z9_idx ON lbm.road_z9 USING gist (the_geom);

DROP MATERIALIZED VIEW IF EXISTS lbm.road_z10 CASCADE;
CREATE MATERIALIZED VIEW lbm.road_z10 AS
(
SELECT ST_SimplifyPreserveTopology(the_geom, 30) AS the_geom, 
       class,
       subclass,
       brunnel,
       ramp,
       oneway,
       layer,
       surface,
       sac_scale,
       is_route
FROM lbm.transportation
WHERE class IN ('motorway','trunk') OR is_route IN (5, 6, 7, 8, 10)
    ) /* DELAY_MATERIALIZED_VIEW_CREATION */;
CREATE INDEX IF NOT EXISTS road_z10_idx ON lbm.road_z10 USING gist (the_geom);

DROP MATERIALIZED VIEW IF EXISTS lbm.road_z11 CASCADE;
CREATE MATERIALIZED VIEW lbm.road_z11 AS
(
SELECT ST_SimplifyPreserveTopology(the_geom, 20) AS the_geom, 
       class,
       subclass,
       brunnel,
       ramp,
       oneway,
       layer,
       surface,
       sac_scale,
       is_route
FROM lbm.transportation
WHERE class IN ('motorway','trunk') OR is_route IN (5, 6, 7, 8, 10, 11)
    ) /* DELAY_MATERIALIZED_VIEW_CREATION */;
CREATE INDEX IF NOT EXISTS road_z11_idx ON lbm.road_z11 USING gist (the_geom);

DROP MATERIALIZED VIEW IF EXISTS lbm.road_z12 CASCADE;
CREATE MATERIALIZED VIEW lbm.road_z12 AS
(
SELECT ST_SimplifyPreserveTopology(the_geom, 10) AS the_geom, 
       class,
       subclass,
       brunnel,
       ramp,
       oneway,
       layer,
       surface,
       sac_scale,
       is_route
FROM lbm.transportation
WHERE class IN ('motorway','trunk','primary','secondary','tertiary','minor') OR is_route IN (5, 6, 7, 8, 10, 11)
    ) /* DELAY_MATERIALIZED_VIEW_CREATION */;
CREATE INDEX IF NOT EXISTS road_z12_idx ON lbm.road_z12 USING gist (the_geom);

DROP MATERIALIZED VIEW IF EXISTS lbm.road_z13 CASCADE;
CREATE MATERIALIZED VIEW lbm.road_z13 AS
(
SELECT the_geom, 
       class,
       subclass,
       brunnel,
       ramp,
       oneway,
       layer,
       surface,
       sac_scale,
       is_route
FROM lbm.transportation
WHERE class IN ('motorway','trunk','primary','secondary','tertiary','minor') OR is_route IN (5, 6, 7, 8, 10, 11)
    ) /* DELAY_MATERIALIZED_VIEW_CREATION */;
CREATE INDEX IF NOT EXISTS road_z13_idx ON lbm.road_z13 USING gist (the_geom);

DROP MATERIALIZED VIEW IF EXISTS lbm.road_z14 CASCADE;
CREATE MATERIALIZED VIEW lbm.road_z14 AS
(
SELECT the_geom, 
       class,
       subclass,
       brunnel,
       ramp,
       oneway,
       layer,
       surface,
       sac_scale,
       is_route
FROM lbm.transportation
WHERE class IN ('motorway','trunk','primary','secondary','tertiary','minor','path','track','service','via_ferrata') OR is_route IN (5, 6, 7, 8, 10, 11)
    ) /* DELAY_MATERIALIZED_VIEW_CREATION */;
CREATE INDEX IF NOT EXISTS road_z14_idx ON lbm.road_z14 USING gist (the_geom);