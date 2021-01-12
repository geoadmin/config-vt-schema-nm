---
category: layer
title: park
etl_graph: media/etl_park.png
mapping_graph: media/mapping_park.png
sql_query: SELECT the_geom, class, name, "name:latin", "name:de", "name:fr", "name:it", "name:rm" FROM lbm.layer_park(ST_SetSRID('BOX3D(-20037508.34 -20037508.34, 20037508.34 20037508.34)'::box3d, 3857 ), 14, 1)
---
The park layer contains parks from national park and protected areas. contains polygons for area and points for labelling

## Fields

### class

Use the **class** to differentiate between different parks.

Possible values:

- `national_park`


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




