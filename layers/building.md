---
category: layer
title: building
etl_graph: media/etl_building.png
mapping_graph: media/mapping_building.png
sql_query: SELECT the_geom, render_height, render_min_height FROM lbm.layer_building(ST_SetSRID('BOX3D(-20037508.34 -20037508.34, 20037508.34 20037508.34)'::box3d, 3857 ), 14)
---
buildings including roofs without sidewalls

## Fields

### render_height

the average height of a building

### render_min_height

the height of the bottom of the building




