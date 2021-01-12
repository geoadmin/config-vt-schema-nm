---
category: layer
title: area_name
etl_graph: media/etl_area_name.png
mapping_graph: media/mapping_area_name.png
sql_query: SELECT the_geom, class, subclass, name, "name:de", "name:fr", "name:it", "name:rm", "name:latin" FROM lbm.layer_area_name(ST_SetSRID('BOX3D(-20037508.34 -20037508.34, 20037508.34 20037508.34)'::box3d, 3857 ), 14)
---
area_name layer for the LBM

## Fields

### class

area names

Possible values:

- `place`


### subclass

different classes of areas

Possible values:

- `massif`
- `glacier`


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




