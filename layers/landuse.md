---
category: layer
title: landuse
etl_graph: media/etl_landuse.png
mapping_graph: media/mapping_landuse.png
sql_query: SELECT the_geom, class FROM lbm.layer_landuse(ST_SetSRID('BOX3D(-20037508.34 -20037508.34, 20037508.34 20037508.34)'::box3d, 3857 ), 14)
---
Landuse is used to describe use of land by humans.

## Fields

### class

Use the **class** to assign special colors to areas.

Possible values:

- `cemetery`
- `landfill`
- `parking`
- `pitch`





