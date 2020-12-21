DROP TABLE IF EXISTS contents;
CREATE TABLE contents (
name text UNIQUE PRIMARY KEY NOT NULL,
get_tile text NOT NULL,
extent box2d NOT NULL,
view_center real ARRAY[2] NOT NULL,
view_zoom integer NOT NULL,
minzoom integer NOT NULL,
maxzoom integer NOT NULL,
attribution text NOT NULL,
description text NOT NULL,
vector_layers json NOT NULL,
properties json
);

INSERT INTO contents (
name,
get_tile,
extent,
view_center,
view_zoom,
minzoom,
maxzoom,
attribution,
description,
vector_layers,
properties)
VALUES (
:name,
:get_tile,
:extent,
:view_center,
:view_zoom,
:minzoom,
:maxzoom,
:attribution,
:description,
:vector_layers,
:properties
);
