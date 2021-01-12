---
category: layer
title: transportation
etl_graph: media/etl_transportation.png
mapping_graph: media/mapping_transportation.png
sql_query: SELECT the_geom, class, subclass, brunnel, ramp, oneway, layer, surface, sac_scale, service FROM lbm.layer_transportation(ST_SetSRID('BOX3D(-20037508.34 -20037508.34, 20037508.34 20037508.34)'::box3d, 3857 ), 14)
---
**transportation** contains roads, railways, aerialways, and ferry lines.
It contains all roads from motorways to primary, secondary and
tertiary roads to residential roads and
foot paths. Styling the roads is the most essential part of the map.

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

- `avalanche_protector`
- `avalanche_protector_bridge`
- `covered_bridge`
- `steps`
- `tram`
- `subway`
- `funicular`
- `rail`
- `narrow_gauge`


### brunnel

Mark whether it is a bridge or tunnel or ford.

Possible values:

- `bridge`
- `tunnel`
- `ford`


### ramp

Mark with `1` whether way is a ramp (link or steps)
or not with `0`.

Possible values:

- `0`
- `1`


### oneway

Mark with `1` whether way is a oneway in the direction of the way,
not a oneway with `0`.

Possible values:

- `0`
- `1`


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


### surface

Used to describe the surface type of roads.

Possible values:

- `paved`
- `unpaved`


### sac_scale

Different kinds of hiking trails.

Possible values:

- `mountain_hiking`
- `hiking`
- `alpine_hiking`


### service

Mark railways that are dead-ends.

Possible values:

- `siding`





