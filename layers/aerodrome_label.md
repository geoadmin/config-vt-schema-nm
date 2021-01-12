---
category: layer
title: aerodrome_label
etl_graph: media/etl_aerodrome_label.png
mapping_graph: media/mapping_aerodrome_label.png
sql_query: SELECT the_geom, name, "name:latin", "name:de", "name:fr", "name:it", "name:rm", class, ele, ele_ft, iata, icao FROM lbm.layer_aerodrome_label(ST_SetSRID('BOX3D(-20037508.34 -20037508.34, 20037508.34 20037508.34)'::box3d, 3857 ), 14)
---
[Aerodrome labels](http://wiki.openstreetmap.org/wiki/Tag:aeroway%3Daerodrome)

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

Distinguish between more and less important aerodromes.

Possible values:

- `international`
- `helipad`
- `regional`
- `other`


### ele

elevation in meters, measured in reference system LV95, srid 2056.

### ele_ft

elevation in feet, measured in reference system LV95, srid 2056.

### iata

iata-code

### icao

icao-code




