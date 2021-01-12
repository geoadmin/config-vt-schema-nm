---
category: layer
title: transportation_name
etl_graph: media/etl_transportation_name.png
mapping_graph: media/mapping_transportation_name.png
sql_query: SELECT the_geom, class, subclass, name, "name:de", "name:fr", "name:it", "name:rm", "name:latin", ref, ref_length, layer FROM lbm.layer_transportation_name(ST_SetSRID('BOX3D(-20037508.34 -20037508.34, 20037508.34 20037508.34)'::box3d, 3857 ), 14)
---
Labeling geometry for transportation layer.

## Fields

### class

Distinguish between more and less important roads or railways and roads.

Possible values:

- `motorway`
- `trunk`
- `primary`
- `secondary`
- `tertiary`
- `minor`
- `path`
- `service`
- `track`
- `ferry`
- `transit`
- `rail`
- `via_ferrata`
- `car_ferry`
- `cable_car`
- `gondola`
- `chair_lift`


### subclass

Distinguish more specific qualities.

Possible values:

- `covered`
- `steps`
- `tram`
- `subway`
- `funicular`
- `rail`
- `narrow_gauge`


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

### ref

Route number.

### ref_length

Length of ref field.

### layer

Used to describe vertical relationships between crossing or overlapping features.

Possible values:

- `-5`
- `-4`
- `-3`
- `-2`
- `-1`
- `1`
- `2`
- `3`
- `4`
- `5`





