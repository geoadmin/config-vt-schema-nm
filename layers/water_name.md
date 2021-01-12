---
category: layer
title: water_name
etl_graph: media/etl_water_name.png
mapping_graph: media/mapping_water_name.png
sql_query: SELECT the_geom, class, name, "name:latin", "name:de", "name:fr", "name:it", "name:rm" FROM lbm.layer_water_name(ST_SetSRID('BOX3D(-20037508.34 -20037508.34, 20037508.34 20037508.34)'::box3d, 3857 ), 14, 1)
---
The water_name layer contains centerlines for larger waterbodies and centerpoints for smaller waterbodies for labelling

## Fields

### class

Curently only 1 **class** attribute available.

Possible values:

- `lake`


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




