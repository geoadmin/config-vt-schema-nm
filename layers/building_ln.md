---
category: layer
title: building_ln
etl_graph: media/etl_building_ln.png
mapping_graph: media/mapping_building_ln.png
sql_query: SELECT the_geom, name, "name:latin", "name:de", "name:fr", "name:it", "name:rm", class FROM lbm.layer_building_ln(ST_SetSRID('BOX3D(-20037508.34 -20037508.34, 20037508.34 20037508.34)'::box3d, 3857 ), 14)
---
building_line layer for the LBM

## Fields

### name

common name

### name:latin

common name, latin alphabet

### name:de

german name, if unavailable uses default name

### name:fr

french name, if unavailable uses default name

### name:it

italien name, if unavailable uses default name

### name:rm

romansh name, if unavailable uses default name

### class

Distinguish between classes of geometries.

Possible values:

- `horse_racing`
- `ski_jump`
- `toboggan`
- `track`
- `weir`





