---
category: layer
title: aeroway
etl_graph: media/etl_aeroway.png
mapping_graph: media/mapping_aeroway.png
sql_query: SELECT the_geom, class FROM lbm.layer_aeroway(ST_SetSRID('BOX3D(-20037508.34 -20037508.34, 20037508.34 20037508.34)'::box3d, 3857 ), 14)
---
Airport buildings are contained in the **building** layer but all
other airport related polygons can be found in the **aeroway** layer.

## Fields

### class

polygon of surfaces used for aerial operations

Possible values:

- `runway`
- `runway_grass`





