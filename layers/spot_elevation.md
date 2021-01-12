---
category: layer
title: spot_elevation
etl_graph: media/etl_spot_elevation.png
mapping_graph: media/mapping_spot_elevation.png
sql_query: SELECT the_geom, class, ele, ele_ft, lake_depth, lake_depth_ft FROM lbm.layer_spot_elevation(ST_SetSRID('BOX3D(-20037508.34 -20037508.34, 20037508.34 20037508.34)'::box3d, 3857 ), 14)
---
spot elevation.

## Fields

### class

class can be used to allow different styling of elevation points.

Possible values:

- `spot_elevation`
- `lake_elevation`
- `sinkhole`
- `sinkhole_rock`
- `sinkhole_scree`
- `sinkhole_ice`
- `sinkhole_water`


### ele

elevation in meters, measured in reference system LV95, srid 2056.

### ele_ft

elevation in feet, measured in reference system LV95, srid 2056.

### lake_depth

the maximum depth of the lake in meters.

### lake_depth_ft

the maximum depth of the lake in feet.




