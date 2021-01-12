---
category: layer
title: mountain_peak
etl_graph: media/etl_mountain_peak.png
mapping_graph: media/mapping_mountain_peak.png
sql_query: SELECT the_geom, name, "name:latin", "name:de", "name:fr", "name:it", "name:rm", class, ele, ele_ft, rank FROM lbm.layer_mountain_peak(ST_SetSRID('BOX3D(-20037508.34 -20037508.34, 20037508.34 20037508.34)'::box3d, 3857 ), 14, 1)
---
peaks or other topographical landmarks.

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

Use the **class** to differentiate between different topographic landmarks.

Possible values:

- `alpine_peak`
- `main_peak`
- `peak`
- `main_hill`
- `hill`
- `rocky_knoll`
- `mountain_pass`
- `saddle`


### ele

elevation in meters, measured in reference system LV95, srid 2056.

### ele_ft

elevation in feet, measured in reference system LV95, srid 2056.

### rank

order of peaks




