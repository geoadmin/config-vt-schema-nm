DROP MATERIALIZED VIEW IF EXISTS lbm.boundary_subset CASCADE;
CREATE MATERIALIZED VIEW lbm.boundary_subset AS
(
SELECT  the_geom,
        admin_level,
        disputed,
        maritime
FROM lbm.boundary
WHERE admin_level IN (2,4)
    );
CREATE INDEX ON lbm.boundary_subset USING gist (the_geom);

DROP MATERIALIZED VIEW IF EXISTS lbm.border_gen_z12 CASCADE;
CREATE MATERIALIZED VIEW lbm.border_gen_z12 AS
(
SELECT ST_Simplify(the_geom, 10) AS the_geom, admin_level, disputed, maritime
FROM lbm.boundary_subset
WHERE admin_level <= 4
    ) /* DELAY_MATERIALIZED_VIEW_CREATION */ ;
CREATE INDEX IF NOT EXISTS border_gen_z12_idx ON lbm.border_gen_z12 USING gist (the_geom);

DROP MATERIALIZED VIEW IF EXISTS lbm.border_gen_z11 CASCADE;
CREATE MATERIALIZED VIEW lbm.border_gen_z11 AS
(
SELECT ST_Simplify(the_geom, 20) AS the_geom, admin_level, disputed, maritime
FROM lbm.boundary_subset
WHERE admin_level <= 4
    ) /* DELAY_MATERIALIZED_VIEW_CREATION */ ;
CREATE INDEX IF NOT EXISTS border_gen_z11_idx ON lbm.border_gen_z11 USING gist (the_geom);

DROP MATERIALIZED VIEW IF EXISTS lbm.border_gen_z10 CASCADE;
CREATE MATERIALIZED VIEW lbm.border_gen_z10 AS
(
SELECT ST_Simplify(the_geom, 40) AS the_geom, admin_level, disputed, maritime
FROM lbm.boundary_subset
WHERE admin_level <= 4
    ) /* DELAY_MATERIALIZED_VIEW_CREATION */ ;
CREATE INDEX IF NOT EXISTS border_gen_z10_idx ON lbm.border_gen_z10 USING gist (the_geom);

DROP MATERIALIZED VIEW IF EXISTS lbm.border_gen_z9 CASCADE;
CREATE MATERIALIZED VIEW lbm.border_gen_z9 AS
(
SELECT ST_Simplify(the_geom, 80) AS the_geom, admin_level, disputed, maritime
FROM lbm.boundary_subset
WHERE admin_level <= 4
    ) /* DELAY_MATERIALIZED_VIEW_CREATION */ ;
CREATE INDEX IF NOT EXISTS border_gen_z9_idx ON lbm.border_gen_z9 USING gist (the_geom);

DROP MATERIALIZED VIEW IF EXISTS lbm.border_gen_z8 CASCADE;
CREATE MATERIALIZED VIEW lbm.border_gen_z8 AS
(
SELECT ST_Simplify(the_geom, 160) AS the_geom, admin_level, disputed, maritime
FROM lbm.boundary_subset
WHERE admin_level <= 4
    ) /* DELAY_MATERIALIZED_VIEW_CREATION */ ;
CREATE INDEX IF NOT EXISTS border_gen_z8_idx ON lbm.border_gen_z8 USING gist (the_geom);

DROP MATERIALIZED VIEW IF EXISTS lbm.border_gen_z7 CASCADE;
CREATE MATERIALIZED VIEW lbm.border_gen_z7 AS
(
SELECT ST_Simplify(the_geom, 300) AS the_geom, admin_level, disputed, maritime
FROM lbm.boundary_subset
WHERE admin_level <= 4
    ) /* DELAY_MATERIALIZED_VIEW_CREATION */ ;
CREATE INDEX IF NOT EXISTS border_gen_z7_idx ON lbm.border_gen_z7 USING gist (the_geom);

DROP MATERIALIZED VIEW IF EXISTS lbm.border_gen_z6 CASCADE;
CREATE MATERIALIZED VIEW lbm.border_gen_z6 AS
(
SELECT ST_Simplify(the_geom, 600) AS the_geom, admin_level, disputed, maritime
FROM lbm.boundary_subset
WHERE admin_level <= 4
    ) /* DELAY_MATERIALIZED_VIEW_CREATION */ ;
CREATE INDEX IF NOT EXISTS border_gen_z6_idx ON lbm.border_gen_z6 USING gist (the_geom);

DROP MATERIALIZED VIEW IF EXISTS lbm.border_gen_z5 CASCADE;
CREATE MATERIALIZED VIEW lbm.border_gen_z5 AS
(
SELECT ST_Simplify(the_geom, 1200) AS the_geom, admin_level, disputed, maritime
FROM lbm.boundary_subset
WHERE admin_level <= 4
    ) /* DELAY_MATERIALIZED_VIEW_CREATION */ ;
CREATE INDEX IF NOT EXISTS border_gen_z5_idx ON lbm.border_gen_z5 USING gist (the_geom);

DROP MATERIALIZED VIEW IF EXISTS lbm.border_gen_z1_4 CASCADE;
CREATE MATERIALIZED VIEW lbm.border_gen_z1_4 AS
(
SELECT ST_Simplify(the_geom, 2400) AS the_geom, admin_level, disputed, maritime
FROM lbm.boundary_subset
WHERE admin_level <= 2
    ) /* DELAY_MATERIALIZED_VIEW_CREATION */ ;
CREATE INDEX IF NOT EXISTS border_gen_z1_4_idx ON lbm.border_gen_z1_4 USING gist (the_geom);

DROP MATERIALIZED VIEW IF EXISTS lbm.border_gen_z0 CASCADE;
CREATE MATERIALIZED VIEW lbm.border_gen_z0 AS
(
SELECT ST_Simplify(the_geom, 4800) AS the_geom, admin_level, disputed, maritime
FROM lbm.boundary_subset
WHERE admin_level <= 2
    ) /* DELAY_MATERIALIZED_VIEW_CREATION */ ;
CREATE INDEX IF NOT EXISTS border_gen_z0_idx ON lbm.border_gen_z0 USING gist (the_geom);



-- etldoc: layer_boundary[shape=record fillcolor=lightpink, style="rounded,filled",
-- etldoc:     label="<sql> layer_boundary |<z0_> z0+ |<z5_> z5+"]
DROP FUNCTION IF EXISTS lbm.layer_boundary(geometry, int);
CREATE OR REPLACE FUNCTION lbm.layer_boundary(bbox geometry, zoom_level int)
    RETURNS TABLE
            (
                the_geom      geometry,
                admin_level   int,
                disputed      int,
                maritime      int
            )
AS
$$
SELECT the_geom, admin_level, disputed, maritime
FROM (
        -- etldoc: lbm_boundary -> admin_level_2 -> layer_boundary:z0_
         SELECT *
         FROM lbm.border_gen_z0
         WHERE the_geom && bbox
           AND zoom_level = 0
         UNION ALL
         SELECT *
         FROM lbm.border_gen_z1_4
         WHERE the_geom && bbox
           AND zoom_level BETWEEN 1 AND 4
         UNION ALL
        -- etldoc: lbm_boundary -> admin_level_4 -> layer_boundary:z5_
         SELECT *
         FROM lbm.border_gen_z5
         WHERE the_geom && bbox
           AND zoom_level = 5
         UNION ALL
         SELECT *
         FROM lbm.border_gen_z6
         WHERE the_geom && bbox
           AND zoom_level = 6
         UNION ALL
         SELECT *
         FROM lbm.border_gen_z7
         WHERE the_geom && bbox
           AND zoom_level = 7
         UNION ALL
         SELECT *
         FROM lbm.border_gen_z8
         WHERE the_geom && bbox
           AND zoom_level = 8
         UNION ALL
         SELECT *
         FROM lbm.border_gen_z9
         WHERE the_geom && bbox
           AND zoom_level = 9
         UNION ALL
         SELECT *
         FROM lbm.border_gen_z10
         WHERE the_geom && bbox
           AND zoom_level = 10
         UNION ALL
         SELECT *
         FROM lbm.border_gen_z11
         WHERE the_geom && bbox
           AND zoom_level = 11
         UNION ALL
         SELECT *
         FROM lbm.border_gen_z12
         WHERE the_geom && bbox
           AND zoom_level = 12
         UNION ALL
         SELECT the_geom, admin_level, disputed, maritime
         FROM lbm.boundary_subset
         WHERE the_geom && bbox
           AND zoom_level >= 13
     ) AS zoom_levels;
$$ LANGUAGE SQL STABLE
                -- STRICT
                PARALLEL SAFE;
