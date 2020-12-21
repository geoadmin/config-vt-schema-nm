-- etldoc: layer_housenumber[shape=record fillcolor=lightpink, style="rounded,filled",
-- etldoc:     label="layer_housenumber | <z14_> z14+" ] ;
DROP MATERIALIZED VIEW IF EXISTS lbm.gwr_addresses;

CREATE MATERIALIZED VIEW lbm.gwr_addresses AS
  SELECT *
    FROM dblink('dbname=kogis_master user=openmaptiles password=openmaptiles',
                  'select bgdi_id, 
                          the_geom, 
                          stn_strname_de, 
                          gde_gdename, 
                          ein_deinr, 
                          ein_edid
                    FROM bfs.gwr_addresses
                    ;')
    AS view(
              bgdi_id           integer, 
              the_geom          geometry,
              stn_strname_de    text,
              gde_gdename       text,
              ein_deinr         character varying,
              ein_edid          smallint
            );
CREATE INDEX ON lbm.gwr_addresses USING gist (the_geom);


CREATE OR REPLACE FUNCTION lbm.layer_housenumber(bbox geometry, zoom_level integer)
    RETURNS TABLE
            (
                bgdi_id           integer, 
                the_geom          geometry,
                stn_strname_de    text,
                gde_gdename       text,
                ein_deinr         character varying,
                ein_edid          smallint
            )
AS
$$
SELECT
    -- etldoc: lbm_gwr_addresses -> layer_housenumber:z14_
    bgdi_id,       
    the_geom,      
    stn_strname_de,
    gde_gdename,   
    ein_deinr,     
    ein_edid      
FROM lbm.gwr_addresses
WHERE zoom_level >= 14
  AND the_geom && bbox;
$$ LANGUAGE SQL STABLE
                -- STRICT
                PARALLEL SAFE;