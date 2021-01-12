---
category: layer
title: housenumber
etl_graph: media/etl_housenumber.png
mapping_graph: media/mapping_housenumber.png
sql_query: SELECT bgdi_id, the_geom, stn_strname_de, gde_gdename, ein_deinr, ein_edid FROM lbm.layer_housenumber(ST_SetSRID('BOX3D(-20037508.34 -20037508.34, 20037508.34 20037508.34)'::box3d, 3857 ), 14)
---
Housenumber from BGDI database, bfs.gwr_addresses table

## Fields

### stn_strname_de

Street name

### gde_gdename

City name

### ein_deinr

house number

### ein_edid

evidence number




