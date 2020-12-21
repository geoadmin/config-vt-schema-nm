-- etldoc: layer_poi[shape=record fillcolor=lightpink, style="rounded,filled", label="layer_poi |<z13_> z13+ |<z14_> z14+" ];

DROP MATERIALIZED VIEW IF EXISTS lbm.poi_subset CASCADE;
-- create a subset of all the data available in ltvt_master
CREATE MATERIALIZED VIEW lbm.poi_subset AS
(
SELECT  the_geom,
        class,
        subclass,
        name,
        COALESCE(NULLIF(name_de, ''), name)     AS "name:de",
        COALESCE(NULLIF(name_fr, ''), name)     AS "name:fr",
        COALESCE(NULLIF(name_it, ''), name)     AS "name:it",
        COALESCE(NULLIF(name_rm, ''), name)     AS "name:rm",
        COALESCE(NULLIF(name_latin, ''), name)  AS "name:latin",
        direction
FROM lbm.poi
WHERE subclass IN ( 
                    'allotments',
                    'alpine_hut',
                    'attraction',
                    'boundary_stone',
                    'building',
                    'bus_stop',
                    'camp_site',
                    'caravan_site',
                    'castle',
                    'cave',
                    'church_tower',
                    'cemetery',
                    'communications_tower',
                    'dam',
                    'elevator',
                    'entry_exit',
                    'exit',
                    'fairground',
                    'ferry_terminal',
                    'fuel',
                    'funicular_stop',
                    'golf_course',
                    'horse_racing',
                    'hospital',
                    'incineration_plant',
                    'junction',
                    'lock',
                    'military',
                    'monument',
                    'museum',
                    'observation',
                    'park',
                    'power_plant',
                    'prison',
                    'ruins',
                    'sports_centre',
                    'spring',
                    'stadium',
                    'station',
                    'stone',
                    'survey_point',
                    'swimming_pool',
                    'telescope',
                    'tower',
                    'tram_stop',
                    'wastewater_plant',
                    'water_tank',
                    'waterfall',
                    'weir',
                    'wind_turbine',
                    'wilderness_hut',
                    'zoo'
                    ) 
                OR class IN ('place_of_worship','monastery','pitch','school','college')
    )/* DELAY_MATERIALIZED_VIEW_CREATION */;
CREATE INDEX IF NOT EXISTS poi_subset_idx ON lbm.poi_subset USING gist (the_geom);


DROP MATERIALIZED VIEW IF EXISTS lbm.poi_z13 CASCADE;
CREATE MATERIALIZED VIEW lbm.poi_z13 AS
(
SELECT  the_geom,
        class,
        subclass,
        name,
        "name:de",
        "name:fr",
        "name:it",
        "name:rm",
        "name:latin",
        direction
FROM lbm.poi_subset 
WHERE subclass IN ('castle', 'communications_tower', 'wind_turbine')
      OR 
      (class = 'railway' AND subclass = 'station')
)/* DELAY_MATERIALIZED_VIEW_CREATION */;
CREATE INDEX IF NOT EXISTS poi_z13_idx ON lbm.poi_z13 USING gist (the_geom);


DROP FUNCTION IF EXISTS lbm.layer_poi(geometry, integer);
CREATE OR REPLACE FUNCTION lbm.layer_poi(bbox geometry, zoom_level integer)
    RETURNS TABLE 
                    (the_geom               geometry,
                     class                  text,
                     subclass               text,
                     name                   text,
                     "name:de"              text,
                     "name:fr"              text,
                     "name:it"              text,
                     "name:rm"              text,
                     "name:latin"           text,
                     direction              integer
                     )
AS
$$
SELECT 
        the_geom,
        class,
        subclass,
        name,
        "name:de",
        "name:fr",
        "name:it",
        "name:rm",
        "name:latin",
        direction
FROM (
    SELECT *
    -- etldoc: lbm_poi -> lbm_poi_subset -> layer_poi:z13_
    FROM lbm.poi_z13
    WHERE the_geom && bbox
        AND zoom_level = 13
    UNION ALL
    SELECT  the_geom,
            class,
            subclass,
            name,
            "name:de",
            "name:fr",
            "name:it",
            "name:rm",
            "name:latin",
            direction
    -- etldoc: lbm_poi -> layer_poi:z14_
    FROM lbm.poi_subset
    WHERE the_geom && bbox
        AND zoom_level >= 14
) AS zoom_levels;
$$ LANGUAGE SQL STABLE
                --STRICT
                PARALLEL SAFE;