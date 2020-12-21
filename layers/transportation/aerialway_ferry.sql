-- etldoc: lbm_transportation -> cable_car
-- etldoc: lbm_transportation -> gondola
-- etldoc: lbm_transportation -> chair_lift
-- etldoc: lbm_transportation -> ferry
-- etldoc: lbm_transportation -> car_ferry
-- etldoc: lbm_transportation -> cable_car
DROP MATERIALIZED VIEW IF EXISTS lbm.aerialway_ferry_z9 CASCADE;
CREATE MATERIALIZED VIEW lbm.aerialway_ferry_z9 AS
(
SELECT ST_Simplify(the_geom, 40) AS the_geom,
       class
FROM lbm.transportation
WHERE class = 'car_ferry'
    );
CREATE INDEX IF NOT EXISTS aerialway_ferry_z9_idx ON lbm.aerialway_ferry_z9 USING gist (the_geom);

DROP MATERIALIZED VIEW IF EXISTS lbm.aerialway_ferry_z10 CASCADE;
CREATE MATERIALIZED VIEW lbm.aerialway_ferry_z10 AS
(
SELECT ST_SimplifyPreserveTopology(the_geom, 30) AS the_geom,
       class
FROM lbm.transportation
WHERE class = 'car_ferry'
    );
CREATE INDEX IF NOT EXISTS aerialway_ferry_z10_idx ON lbm.aerialway_ferry_z10 USING gist (the_geom);

DROP MATERIALIZED VIEW IF EXISTS lbm.aerialway_ferry_z11 CASCADE;
CREATE MATERIALIZED VIEW lbm.aerialway_ferry_z11 AS
(
SELECT ST_SimplifyPreserveTopology(the_geom, 20) AS the_geom,
       class
FROM lbm.transportation
WHERE class = 'car_ferry'
    );
CREATE INDEX IF NOT EXISTS aerialway_ferry_z11_idx ON lbm.aerialway_ferry_z11 USING gist (the_geom);

DROP MATERIALIZED VIEW IF EXISTS lbm.aerialway_ferry_z12 CASCADE;
CREATE MATERIALIZED VIEW lbm.aerialway_ferry_z12 AS
(
SELECT ST_SimplifyPreserveTopology(the_geom, 10) AS the_geom,
       class
FROM lbm.transportation
WHERE class IN ('car_ferry', 'ferry', 'cable_car', 'gondola')
    );
CREATE INDEX IF NOT EXISTS aerialway_ferry_z12_idx ON lbm.aerialway_ferry_z12 USING gist (the_geom);

DROP MATERIALIZED VIEW IF EXISTS lbm.aerialway_ferry_z13_14 CASCADE;
CREATE MATERIALIZED VIEW lbm.aerialway_ferry_z13_14 AS
(
SELECT the_geom,
       class
FROM lbm.transportation
WHERE class IN ('car_ferry', 'ferry', 'cable_car', 'gondola', 'chair_lift')
    );
CREATE INDEX IF NOT EXISTS aerialway_ferry_z13_14_idx ON lbm.aerialway_ferry_z13_14 USING gist (the_geom);