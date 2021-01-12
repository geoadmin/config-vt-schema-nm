---
category: layer
title: boundary
etl_graph: media/etl_boundary.png
mapping_graph: media/mapping_boundary.png
sql_query: SELECT the_geom, admin_level, disputed, maritime FROM lbm.layer_boundary(ST_SetSRID('BOX3D(-20037508.34 -20037508.34, 20037508.34 20037508.34)'::box3d, 3857 ), 14)
---
Contains administrative boundaries as linestrings.

## Fields

### admin_level

[`admin_level`](https://wiki.openstreetmap.org/wiki/Tag:boundary%3Dadministrative#10_admin_level_values_for_specific_countries) indicating the level of importance of this boundary.
The `admin_level` corresponds to the lowest `admin_level` the line participates in.

### disputed

wether the boundary is disputed or not

### maritime

wether the boundary is in the sea or not




