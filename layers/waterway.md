---
category: layer
title: waterway
etl_graph: media/etl_waterway.png
mapping_graph: media/mapping_waterway.png
sql_query: SELECT the_geom, class, name, "name:latin", "name:de", "name:fr", "name:it", "name:rm", intermittent, width FROM lbm.layer_waterway(ST_SetSRID('BOX3D(-20037508.34 -20037508.34, 20037508.34 20037508.34)'::box3d, 3857 ), 14)
---
waterway.

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

stream/river are classified by [Strahler-order](https://en.wikipedia.org/wiki/Strahler_number). Upstream rivers are classified as streams, once they reach a certain Strahler number, they are classified as rivers.

Possible values:

- `stream`
- `river`
- `pressurised`
- `drain`


### intermittent

Mark with `1` if it is an [intermittent](http://wiki.openstreetmap.org/wiki/Key:intermittent) waterway.

Possible values:

- `0`
- `1`


### width

used to symbolize downstream rivers wider than upstream.




