---
category: layer
title: water
etl_graph: media/etl_water.png
mapping_graph: media/mapping_water.png
sql_query: SELECT the_geom, class FROM lbm.layer_water(ST_SetSRID('BOX3D(-20037508.34 -20037508.34, 20037508.34 20037508.34)'::box3d, 3857 ), 14)
---
Water polygons representing rivers and lakes but also artificial constructions such as pools

## Fields

### class

Water bodies are classified as `lake` or `river`.

Possible values:

- `lake`
- `river`





