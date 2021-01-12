---
category: layer
title: landcover
etl_graph: media/etl_landcover.png
mapping_graph: media/mapping_landcover.png
sql_query: SELECT the_geom, class, subclass FROM lbm.layer_landcover(ST_SetSRID('BOX3D(-20037508.34 -20037508.34, 20037508.34 20037508.34)'::box3d, 3857 ), 14)
---
Landcover is used to describe the physical material at the surface of the earth.

## Fields

### class

Use the **class** to assign natural colors for **landcover**.

Possible values:

- `farmland`
- `ice`
- `wood`
- `rock`
- `grass`
- `wetland`


### subclass

Use **subclass** to do more precise styling.

Possible values:

- `allotments`
- `forest`
- `glacier`
- `golf_course`
- `orchard`
- `park`
- `plant_nursery`
- `recreation_ground`
- `scrub`
- `swamp`
- `vineyard`





