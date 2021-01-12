---
category: layer
title: contour_line
etl_graph: media/etl_contour_line.png
mapping_graph: media/mapping_contour_line.png
sql_query: SELECT the_geom, class, ele, ele_ft FROM lbm.layer_contour_line(ST_SetSRID('BOX3D(-20037508.34 -20037508.34, 20037508.34 20037508.34)'::box3d, 3857 ), 14)
---
contour lines

## Fields

### class

use class attribute to assign differnt colors for contour_lines.

Possible values:

- `land`
- `ice`
- `scree`
- `water`


### ele

elevation in meters, measured in reference system LV95, srid 2056.

### ele_ft

elevation in feet, measured in reference system LV95, srid 2056.




