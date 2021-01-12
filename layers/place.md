---
category: layer
title: place
etl_graph: media/etl_place.png
mapping_graph: media/mapping_place.png
sql_query: SELECT the_geom, name, "name:latin", "name:de", "name:fr", "name:it", "name:rm", class, rank, capital, iso_a2, code, population FROM lbm.layer_place(ST_SetSRID('BOX3D(-20037508.34 -20037508.34, 20037508.34 20037508.34)'::box3d, 3857 ), 14, 1)
---
used to label places.

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

### capital

The **capital** field marks the
[`admin_level`](http://wiki.openstreetmap.org/wiki/Tag:boundary%3Dadministrative#admin_level)
of the boundary the place is a capital of.

Possible values:

- `2`
- `4`


### class

distinguish between different size and importance of labelled places.

Possible values:

- `country`
- `city`
- `town`
- `village`
- `hamlet`
- `isolated_dwelling`
- `neighbourhood`
- `suburb`


### iso_a2

Two-letter country code [ISO 3166-1 alpha-2](https://en.wikipedia.org/wiki/ISO_3166-1_alpha-2).

### code

Two-letter canton code.

### population

Approximate number of inhabitants. Can be used to prioritize labelling. Data is not validated and may not be used for analysis!

### rank

Countries, states and the most important cities all have a
**rank** to boost their importance on the map.
The **rank** field for counries and states ranges from
`1` to `6` while the **rank** field for cities ranges from
`1` to `10` for the most important cities
and continues from `10` serially based on the
local importance of the city (derived from population and city class).
You can use the **rank** to limit density of labels or improve
the text hierarchy.




