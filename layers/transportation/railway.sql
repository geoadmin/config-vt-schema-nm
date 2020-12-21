-- etldoc: lbm_transportation ->  rail
-- etldoc: lbm_transportation ->  transit
DROP MATERIALIZED VIEW IF EXISTS lbm.railway_merge CASCADE;
CREATE MATERIALIZED VIEW lbm.railway_merge AS
(
SELECT (ST_Dump(the_geom)).geom AS the_geom,
       class,
       subclass,
       is_route
FROM (
         SELECT ST_LineMerge(ST_Collect(the_geom)) AS the_geom,
                class,
                subclass,
                is_route
         FROM lbm.transportation
         WHERE subclass = 'rail' AND is_route = 99
           AND ST_IsValid(the_geom)
         GROUP BY class, subclass, is_route
	) as railway_union
    ) /* DELAY_MATERIALIZED_VIEW_CREATION */;
CREATE INDEX IF NOT EXISTS railway_merge_idx ON lbm.railway_merge USING gist (the_geom);
CREATE INDEX IF NOT EXISTS railway_merge_partial_idx ON lbm.railway_merge (class, subclass, is_route);

DROP MATERIALIZED VIEW IF EXISTS lbm.railway_z8 CASCADE;
CREATE MATERIALIZED VIEW lbm.railway_z8 AS
(
SELECT ST_Simplify(the_geom, 120) AS the_geom, 
       class, 
       subclass
FROM lbm.railway_merge
    ) /* DELAY_MATERIALIZED_VIEW_CREATION */;
CREATE INDEX IF NOT EXISTS railway_z8_idx ON lbm.railway_z8 USING gist (the_geom);

DROP MATERIALIZED VIEW IF EXISTS lbm.railway_z9 CASCADE;
CREATE MATERIALIZED VIEW lbm.railway_z9 AS
(
SELECT ST_Simplify(the_geom, 40) AS the_geom, 
       class, 
       subclass
FROM lbm.railway_merge
    ) /* DELAY_MATERIALIZED_VIEW_CREATION */;
CREATE INDEX IF NOT EXISTS railway_z9_idx ON lbm.railway_z9 USING gist (the_geom);

DROP MATERIALIZED VIEW IF EXISTS lbm.railway_z10 CASCADE;
CREATE MATERIALIZED VIEW lbm.railway_z10 AS
(
SELECT ST_SimplifyPreserveTopology(the_geom, 30) AS the_geom, 
       class, 
       subclass,
       brunnel,
       layer,
       service,
       is_route
FROM lbm.transportation
WHERE subclass = 'rail' AND is_route = 99
    ) /* DELAY_MATERIALIZED_VIEW_CREATION */;
CREATE INDEX IF NOT EXISTS railway_z10_idx ON lbm.railway_z10 USING gist (the_geom);

DROP MATERIALIZED VIEW IF EXISTS lbm.railway_z11 CASCADE;
CREATE MATERIALIZED VIEW lbm.railway_z11 AS
(
SELECT ST_SimplifyPreserveTopology(the_geom, 20) AS the_geom, 
       class, 
       subclass,
       brunnel,
       layer,
       service,
       is_route
FROM lbm.transportation
WHERE (subclass = 'rail' AND is_route = 99) OR subclass IN ('narrow_gauge','funicular')
    ) /* DELAY_MATERIALIZED_VIEW_CREATION */;
CREATE INDEX IF NOT EXISTS railway_z11_idx ON lbm.railway_z11 USING gist (the_geom);

DROP MATERIALIZED VIEW IF EXISTS lbm.railway_z12 CASCADE;
CREATE MATERIALIZED VIEW lbm.railway_z12 AS
(
SELECT ST_SimplifyPreserveTopology(the_geom, 10) AS the_geom, 
       class, 
       subclass,
       brunnel,
       layer,
       service,
       is_route
FROM lbm.transportation
WHERE (subclass = 'rail' AND is_route = 99) OR subclass IN ('narrow_gauge','funicular')
    ) /* DELAY_MATERIALIZED_VIEW_CREATION */;
CREATE INDEX IF NOT EXISTS railway_z12_idx ON lbm.railway_z12 USING gist (the_geom);

DROP MATERIALIZED VIEW IF EXISTS lbm.railway_z13 CASCADE;
CREATE MATERIALIZED VIEW lbm.railway_z13 AS
(
SELECT the_geom, 
       class, 
       subclass,
       brunnel,
       layer,
       service,
       is_route
FROM lbm.transportation
WHERE (subclass = 'rail' AND is_route = 99) OR subclass IN ('narrow_gauge','tram','subway','funicular')
    ) /* DELAY_MATERIALIZED_VIEW_CREATION */;
CREATE INDEX IF NOT EXISTS railway_z13_idx ON lbm.railway_z13 USING gist (the_geom);

DROP MATERIALIZED VIEW IF EXISTS lbm.railway_z14 CASCADE;
CREATE MATERIALIZED VIEW lbm.railway_z14 AS
(
SELECT the_geom, 
       class, 
       subclass,
       brunnel,
       layer,
       service,
       is_route
FROM lbm.transportation
WHERE class IN ('rail','transit')
    ) /* DELAY_MATERIALIZED_VIEW_CREATION */;
CREATE INDEX IF NOT EXISTS railway_z14_idx ON lbm.railway_z14 USING gist (the_geom);