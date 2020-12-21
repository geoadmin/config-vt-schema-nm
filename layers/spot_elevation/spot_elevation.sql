DROP MATERIALIZED VIEW IF EXISTS lbm.spot_elevation_gen1 CASCADE;
CREATE MATERIALIZED VIEW lbm.spot_elevation_gen1 AS
(SELECT the_geom, "class", ele, ele_ft, lake_depth, lake_depth_ft 
 FROM lbm.spot_elevation 
 	WHERE minzoom <= 13
	) /* DELAY_MATERIALIZED_VIEW_CREATION */;
CREATE INDEX IF NOT EXISTS spot_elevation_gen1_idx ON lbm.spot_elevation_gen1 USING gist (the_geom);

DROP MATERIALIZED VIEW IF EXISTS lbm.spot_elevation_gen2 CASCADE;
CREATE MATERIALIZED VIEW lbm.spot_elevation_gen2 AS
(SELECT the_geom, "class", ele, ele_ft, lake_depth, lake_depth_ft 
 FROM lbm.spot_elevation 
 	WHERE minzoom <= 12
	) /* DELAY_MATERIALIZED_VIEW_CREATION */;
CREATE INDEX IF NOT EXISTS spot_elevation_gen2_idx ON lbm.spot_elevation_gen2 USING gist (the_geom);

DROP MATERIALIZED VIEW IF EXISTS lbm.spot_elevation_gen3 CASCADE;
CREATE MATERIALIZED VIEW lbm.spot_elevation_gen3 AS
(SELECT the_geom, "class", ele, ele_ft, lake_depth, lake_depth_ft 
 FROM lbm.spot_elevation 
 	WHERE minzoom <= 11
	) /* DELAY_MATERIALIZED_VIEW_CREATION */;
CREATE INDEX IF NOT EXISTS spot_elevation_gen3_idx ON lbm.spot_elevation_gen3 USING gist (the_geom);

DROP MATERIALIZED VIEW IF EXISTS lbm.spot_elevation_gen4 CASCADE;
CREATE MATERIALIZED VIEW lbm.spot_elevation_gen4 AS
(SELECT the_geom, "class", ele, ele_ft, lake_depth, lake_depth_ft 
 FROM lbm.spot_elevation 
 	WHERE minzoom <= 10
	) /* DELAY_MATERIALIZED_VIEW_CREATION */;
CREATE INDEX IF NOT EXISTS spot_elevation_gen4_idx ON lbm.spot_elevation_gen4 USING gist (the_geom);

DROP MATERIALIZED VIEW IF EXISTS lbm.spot_elevation_gen5 CASCADE;
CREATE MATERIALIZED VIEW lbm.spot_elevation_gen5 AS
(SELECT the_geom, "class", ele, ele_ft, lake_depth, lake_depth_ft 
 FROM lbm.spot_elevation 
 	WHERE minzoom <= 9
	) /* DELAY_MATERIALIZED_VIEW_CREATION */;
CREATE INDEX IF NOT EXISTS spot_elevation_gen5_idx ON lbm.spot_elevation_gen5 USING gist (the_geom);

-- etldoc: layer_spot_elevation[shape=record fillcolor=lightpink, style="rounded,filled",
-- etldoc:     label="<sql> layer_spot_elevation |<z9_> z9+"]
CREATE OR REPLACE FUNCTION lbm.layer_spot_elevation(bbox geometry, zoom_level integer)
	RETURNS TABLE
			(
				the_geom		geometry,
				"class"			text,
				ele				double precision,
				ele_ft 			double precision,
				lake_depth		double precision,
				lake_depth_ft 	double precision
			)
AS
$$
SELECT
	the_geom,
	"class",
	ele,
	ele_ft,
	lake_depth,
	lake_depth_ft
FROM (
        -- etldoc: lbm_spot_elevation -> layer_spot_elevation:z9_
		SELECT *
		FROM lbm.spot_elevation_gen5
		WHERE the_geom && bbox
			AND zoom_level = 9
		UNION ALL
		SELECT *
		FROM lbm.spot_elevation_gen4
		WHERE the_geom && bbox
			AND zoom_level = 10
		UNION ALL
		SELECT *
		FROM lbm.spot_elevation_gen3
		WHERE the_geom && bbox
			AND zoom_level = 11
		UNION ALL
		SELECT *
		FROM lbm.spot_elevation_gen2
		WHERE the_geom && bbox
			AND zoom_level = 12
		UNION ALL
		SELECT *
		FROM lbm.spot_elevation_gen1
		WHERE the_geom && bbox
			AND zoom_level = 13
		UNION ALL
		SELECT the_geom, "class", ele, ele_ft, lake_depth, lake_depth_ft
		FROM lbm.spot_elevation
		WHERE the_geom && bbox
			AND zoom_level >= 14
		) AS zoom_levels;
$$ LANGUAGE SQL STABLE
				-- STRICT
				PARALLEL SAFE;