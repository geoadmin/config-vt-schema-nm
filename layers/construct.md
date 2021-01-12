---
category: layer
title: construct
etl_graph: media/etl_construct.png
mapping_graph: media/mapping_construct.png
sql_query: SELECT the_geom, class FROM lbm.layer_construct(ST_SetSRID('BOX3D(-20037508.34 -20037508.34, 20037508.34 20037508.34)'::box3d, 3857 ), 14)
---
manmade structures not suitable for the layer building.

## Fields

### class

use class to differentiate between different manmade structures.

Possible values:

- `dam`
- `lock`
- `platform`





