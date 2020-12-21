-- Create missing index
CREATE INDEX IF NOT EXISTS lbm_housenumber_the_geom ON lbm.housenumber USING gist(the_geom);