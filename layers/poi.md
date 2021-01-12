---
category: layer
title: poi
etl_graph: media/etl_poi.png
mapping_graph: media/mapping_poi.png
sql_query: SELECT the_geom, class, subclass, name, "name:de", "name:fr", "name:it", "name:rm", "name:latin", direction FROM lbm.layer_poi(ST_SetSRID('BOX3D(-20037508.34 -20037508.34, 20037508.34 20037508.34)'::box3d, 3857 ), 14)
---
LBM POIs

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

More general classes of POIs. If there is no more general `class` for the `subclass`
this field will contain the same value as `subclass`.

Possible values:

- `aerialway`
- `allotments`
- `attraction`
- `boundary_stone`
- `building`
- `bus`
- `campsite`
- `castle`
- `cave`
- `cemetery`
- `college`
- `dam`
- `ferry_terminal`
- `fuel`
- `funicular`
- `golf`
- `hospital`
- `lock`
- `lodging`
- `military`
- `monument`
- `motorway`
- `park`
- `pitch`
- `place_of_worship`
- `power`
- `prison`
- `railway`
- `ruins`
- `school`
- `sports_centre`
- `spring`
- `stadium`
- `stone`
- `storage_tank`
- `survey_point`
- `swimming_pool`
- `tower`
- `wastewater_plant`
- `waterfall`
- `weir`
- `zoo`


### subclass

More refined description.

Possible values:

- `allotments`
- `alpine_hut`
- `attraction`
- `boundary_stone`
- `building`
- `bus_stop`
- `camp_site`
- `caravan_site`
- `castle`
- `cave`
- `cemetery`
- `christian`
- `church_tower`
- `college`
- `communications_tower`
- `dam`
- `entry_exit`
- `exit`
- `fairground`
- `ferry_terminal`
- `fuel`
- `funicular_stop`
- `golf_course`
- `horse_racing`
- `hospital`
- `incineration_plant`
- `junction`
- `lock`
- `military`
- `monument`
- `observation`
- `park`
- `power_plant`
- `prison`
- `ruins`
- `school`
- `sports_centre`
- `spring`
- `stadium`
- `station`
- `stone`
- `survey_point`
- `swimming_pool`
- `telescope`
- `tower`
- `tram_stop`
- `university`
- `viewpoint`
- `wastewater_plant`
- `waterfall`
- `water_tank`
- `weir`
- `wilderness_hut`
- `wind_turbine`
- `zoo`


### direction

can be used to orientate direction for waterfalls




