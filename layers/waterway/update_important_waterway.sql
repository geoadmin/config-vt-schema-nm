-- We merge the waterways by name like the highways
-- This helps to drop not important rivers (since they do not have a name)
-- and also makes it possible to filter out too short rivers

CREATE INDEX IF NOT EXISTS waterway_linestring_class_partial_idx
    ON lbm.waterway (class)
    WHERE class = 'river';

CREATE INDEX IF NOT EXISTS waterway_linestring_name_partial_idx
    ON lbm.waterway (name)
    WHERE name <> '';

-- etldoc: waterway ->  important_waterway_linestring
CREATE TABLE IF NOT EXISTS lbm.important_waterway_linestring AS
SELECT (ST_Dump(the_geom)).geom AS the_geom,
       name,
       name_en
FROM (
         SELECT ST_LineMerge(ST_Union(the_geom)) AS the_geom,
                name,
                name_en

         FROM lbm.waterway
         WHERE name <> ''
           AND class = 'river'
           AND ST_IsValid(the_geom)
         GROUP BY name, name_en
     ) AS waterway_union;
CREATE INDEX IF NOT EXISTS important_waterway_linestring_names ON lbm.important_waterway_linestring (name);
CREATE INDEX IF NOT EXISTS important_waterway_linestring_geometry_idx ON lbm.important_waterway_linestring USING gist (the_geom);

-- etldoc: important_waterway_linestring -> important_waterway_linestring_gen1
CREATE OR REPLACE VIEW lbm.important_waterway_linestring_gen1_view AS
SELECT ST_Simplify(the_geom, 60) AS the_geom, name, name_en
FROM lbm.important_waterway_linestring
WHERE ST_Length(the_geom) > 1000;

CREATE TABLE IF NOT EXISTS lbm.important_waterway_linestring_gen1 AS
SELECT *
FROM lbm.important_waterway_linestring_gen1_view;
CREATE INDEX IF NOT EXISTS important_waterway_linestring_gen1_name_idx ON lbm.important_waterway_linestring_gen1 (name);
CREATE INDEX IF NOT EXISTS important_waterway_linestring_gen1_geometry_idx ON lbm.important_waterway_linestring_gen1 USING gist (the_geom);

-- etldoc: important_waterway_linestring_gen1 -> important_waterway_linestring_gen2
CREATE OR REPLACE VIEW lbm.important_waterway_linestring_gen2_view AS
SELECT ST_Simplify(the_geom, 100) AS the_geom, name, name_en
FROM lbm.important_waterway_linestring_gen1
WHERE ST_Length(the_geom) > 4000;

CREATE TABLE IF NOT EXISTS lbm.important_waterway_linestring_gen2 AS
SELECT *
FROM lbm.important_waterway_linestring_gen2_view;
CREATE INDEX IF NOT EXISTS important_waterway_linestring_gen2_name_idx ON lbm.important_waterway_linestring_gen2 (name);
CREATE INDEX IF NOT EXISTS important_waterway_linestring_gen2_geometry_idx ON lbm.important_waterway_linestring_gen2 USING gist (the_geom);

-- etldoc: important_waterway_linestring_gen2 -> important_waterway_linestring_gen3
CREATE OR REPLACE VIEW lbm.important_waterway_linestring_gen3_view AS
SELECT ST_Simplify(the_geom, 200) AS the_geom, name, name_en
FROM lbm.important_waterway_linestring_gen2
WHERE ST_Length(the_geom) > 8000;

CREATE TABLE IF NOT EXISTS lbm.important_waterway_linestring_gen3 AS
SELECT *
FROM lbm.important_waterway_linestring_gen3_view;
CREATE INDEX IF NOT EXISTS important_waterway_linestring_gen3_name_idx ON lbm.important_waterway_linestring_gen3 (name);
CREATE INDEX IF NOT EXISTS important_waterway_linestring_gen3_geometry_idx ON lbm.important_waterway_linestring_gen3 USING gist (the_geom);