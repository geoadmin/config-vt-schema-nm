#
# First section - common variable initialization
#

# Ensure that errors don't hide inside pipes
SHELL         = /bin/bash
.SHELLFLAGS   = -o pipefail -c

# Make all .env variables available for make targets
include .env

# Layers definition and meta data
TILESET_FILE ?= ch.swisstopo.leichte-basiskarte.vt.yaml

# Options to run with docker and docker-compose - ensure the container is destroyed on exit
# Containers run as the current user rather than root (so that created files are not root-owned)
DC_OPTS ?= --rm -u $(shell id -u):$(shell id -g)

# Local port to use with postserve
PPORT ?= $(POSTSERVE_PORT)
export PPORT
# Local port to use with tileserver
TPORT ?= 8080
export TPORT

# number of jobs to use for pg_restore/pg_dump
NPROC ?= $(shell nproc)
JOBS ?= $$(( $(NPROC) + 1 ))

# Allow a custom docker-compose project name
ifeq ($(strip $(DC_PROJECT)),)
  DC_PROJECT := $(notdir $(shell pwd))
  DOCKER_COMPOSE := docker-compose
else
  DOCKER_COMPOSE := docker-compose --project-name $(DC_PROJECT)
endif

# Make some operations quieter (e.g. inside the test script)
ifeq ($(strip $(QUIET)),)
  QUIET_FLAG :=
else
  QUIET_FLAG := --quiet
endif

# Use `xargs --no-run-if-empty` flag, if supported
XARGS := xargs $(shell xargs --no-run-if-empty </dev/null 2>/dev/null && echo --no-run-if-empty)

# If running in the test mode, compare files rather than copy them
TEST_MODE?=no
ifeq ($(TEST_MODE),yes)
  # create images in ./build/devdoc and compare them to ./layers
  GRAPH_PARAMS=./build/devdoc ./layers
else
  # update graphs in the ./layers dir
  GRAPH_PARAMS=./layers
endif

# Set VT Pipeline host
VT_PIPELINE_HOST := $(EC2_HOST)

# This defines an easy $(newline) value to act as a "\n". Make sure to keep exactly two empty lines after newline.
define newline


endef


#
# Determine area to work on
# If $(area) parameter is not set and data/*.osm.pbf finds only one file, use it as $(area).
# Otherwise all make targets requiring area param will show an error.
# Note: If there are no data files, and user calls  make download area=... once,
#       they will not need to use area= parameter after that because there will be just a single file.
#
# historically we have been using $(area) rather than $(AREA), so make both work
area ?= switzerland

# The file is placed into the $EXPORT_DIR=/export (mapped to ./data)
export MBTILES_FILE ?= $(area).mbtiles
MBTILES_LOCAL_FILE = data/$(MBTILES_FILE)

#
#  TARGETS
#

.PHONY: help
help:
	@echo "=============================================================================="
	@echo " SwissTopo VT Pipeline "
	@echo "  make 		             		# help about available commands"
	@echo "  make build              		# build source code"
	@echo "  make start-db           		# start PostgreSQL, creating it if it doesn't exist"
	@echo "  make stop-db            		# stop PostgreSQL database without destroying the data"
	@echo "  make destroy-db         		# remove docker containers and PostgreSQL data volume"
	@echo "  make copy-test-db       		# create copy of ltvt database"
	@echo "  make remove-test-db     		# remove copy of ltvt database"
	@echo "  make psql               		# start PostgreSQL console"
	@echo "  make get-dumps          		# get dumps of databases (see .env file)"
	@echo "  make import-ltvt        		# restore dump of ltvt database"
	@echo "  make transform-geometry 		# transform geometry from LV95 to web Mercator"
	@echo "  make import-sql         		# import sql from build/sql folder"
	@echo "  make generate-metadata    		# create metadata table in METADATA_LOCAL_FILE"
	@echo "  make generate-tiles-pg   		# generate tiles"
	@echo "  make generate-devdoc    		# generate devdoc including graphs for all layers [./layers/...]"
	@echo "  make bash               		# start openmaptiles-tools /bin/bash terminal"
	@echo "  make start-postserve    		# start dynamic tile server                   [ see $(VT_PIPELINE_HOST):$(PPORT)} ]"
	@echo "  make start-tileserver   		# start maptiler/tileserver-gl                [ see $(VT_PIPELINE_HOST):$(TPORT) ]"
	@echo "  make start-maptiler-server 	# start MapTiler server
	@echo "  make stop-maptiler-server  	# stop MapTiler server
	@echo "  make clean-unnecessary-docker	# clean unnecessary docker image(s) and container(s)"
	@echo "  make remove-docker-images		# remove openmaptiles docker images"
	@echo "  make help               		# help about available commands"
	@echo "=============================================================================="
	@echo "  number of cores:        		$(NPROC)"
	@echo "  number of jobs:         		$(JOBS)"

.PHONY: all
all: init-dirs build/openmaptiles.tm2source/data.yml build/mapping.yaml build-sql

.PHONY: build
build: all


.PHONY: init-dirs
init-dirs:
	@mkdir -p build/sql/parallel
	@mkdir -p build/openmaptiles.tm2source
	@mkdir -p data/borders
	@mkdir -p cache

build/openmaptiles.tm2source/data.yml: init-dirs
ifeq (,$(wildcard build/openmaptiles.tm2source/data.yml))
	$(DOCKER_COMPOSE) run $(DC_OPTS) openmaptiles-tools generate-tm2source $(TILESET_FILE) --host="postgres" --port=5432 --database=$(LTVT_DB) --user=$(PGUSER) > $@
endif


build/mapping.yaml: init-dirs
ifeq (,$(wildcard build/mapping.yaml))
	$(DOCKER_COMPOSE) run $(DC_OPTS) openmaptiles-tools generate-imposm3 $(TILESET_FILE) > $@
endif

.PHONY: build-sql
build-sql: init-dirs
ifeq (,$(wildcard build/sql/run_last.sql))
	@mkdir -p build/sql/parallel
	$(DOCKER_COMPOSE) run $(DC_OPTS) openmaptiles-tools bash -c \
		'generate-sql $(TILESET_FILE) --dir ./build/sql \
		&& generate-sqltomvt $(TILESET_FILE) \
							 --key --gzip --postgis-ver 3.0.1 \
							 --function --fname=getmvt >> ./build/sql/run_last.sql'
endif

.PHONY: clean
clean:
	rm -rf build

.PHONY: start-db-nowait
start-db-nowait: init-dirs
	@echo "Starting postgres docker compose target using $${POSTGIS_IMAGE:-default} image (no recreate if exists)" && \
	$(DOCKER_COMPOSE) up --no-recreate -d postgres

.PHONY: start-db
start-db: start-db-nowait
	@echo "Wait for PostgreSQL to start..."
	$(DOCKER_COMPOSE) run $(DC_OPTS) openmaptiles-tools pgwait

.PHONY: stop-db
stop-db:
	@echo "Stopping PostgreSQL..."
	$(DOCKER_COMPOSE) stop postgres

.PHONY: destroy-db
# TODO:  Use https://stackoverflow.com/a/27852388/177275
destroy-db: DC_PROJECT := $(shell echo $(DC_PROJECT) | tr A-Z a-z)
destroy-db:
	$(DOCKER_COMPOSE) down -v --remove-orphans
	$(DOCKER_COMPOSE) rm -fv
	docker volume ls -q -f "name=^$(DC_PROJECT)_" | $(XARGS) docker volume rm
	rm -rf cache

.PHONY: psql
psql: start-db-nowait
	$(DOCKER_COMPOSE) run $(DC_OPTS) openmaptiles-tools sh -c 'pgwait && psql.sh'

.PHONY: get-dumps
get-dumps: start-db-nowait
		$(DOCKER_COMPOSE) run $(DC_OPTS) openmaptiles-tools sh -c 'pg_dump $(LTVT_DBCONN) -v -Fc $(LTVT_TABLES) > $(LTVT_DUMP_FILE)'
		$(DOCKER_COMPOSE) run $(DC_OPTS) openmaptiles-tools sh -c 'pg_dumpall -d $(LTVT_DBCONN) -g > $(GLOBALS_DUMP_FILE)'

.PHONY: import-globals
import-globals: start-db-nowait
		$(DOCKER_COMPOSE) run $(DC_OPTS) openmaptiles-tools psql.sh -U $(PGUSER) -d template1 -P pager=off -f $(GLOBALS_DUMP_FILE) 1>/dev/null

.PHONY: import-ltvt
import-ltvt: start-db-nowait import-globals
		$(DOCKER_COMPOSE) run $(DC_OPTS) openmaptiles-tools psql.sh -U $(PGUSER) -d template1 -c "SELECT pg_terminate_backend(pg_stat_activity.pid) FROM pg_stat_activity WHERE pg_stat_activity.datname = '$(LTVT_DB)'"
		$(DOCKER_COMPOSE) run $(DC_OPTS) openmaptiles-tools sh -c 'dropdb --if-exists $(LTVT_DB) -U $(PGUSER)'
		$(DOCKER_COMPOSE) run $(DC_OPTS) openmaptiles-tools sh -c 'createdb $(LTVT_DB) --owner=$(PGUSER) -U $(PGUSER)'
		$(DOCKER_COMPOSE) run $(DC_OPTS) openmaptiles-tools psql.sh -U $(PGUSER) -d $(LTVT_DB) -P pager=off -f ./prepare_import/prepare_ltvt.sql
		$(DOCKER_COMPOSE) run $(DC_OPTS) openmaptiles-tools psql.sh -U $(PGUSER) -d $(LTVT_DB) -P pager=off -f ./prepare_import/setze_lastupdate_firstdate.sql
		$(DOCKER_COMPOSE) run $(DC_OPTS) openmaptiles-tools psql.sh -U $(PGUSER) -d $(LTVT_DB) -P pager=off -f ./prepare_import/setze_quadindex.sql
		$(DOCKER_COMPOSE) run $(DC_OPTS) openmaptiles-tools sh -c 'pg_restore -j $(JOBS) -v -U $(PGUSER) -d $(LTVT_DB) $(LTVT_DUMP_FILE)'

.PHONY: grant-vt_reader
grant-vt_reader: start-db-nowait
		$(DOCKER_COMPOSE) run $(DC_OPTS) openmaptiles-tools psql.sh -U $(PGUSER) -d template1 -c "SELECT pg_terminate_backend(pg_stat_activity.pid) FROM pg_stat_activity WHERE pg_stat_activity.datname = '$(LTVT_DB)'"
        $(DOCKER_COMPOSE) run $(DC_OPTS) openmaptiles-tools psql.sh -U $(PGUSER) -d $(LTVT_DB) -P pager=off -f ./prepare_import/vt_reader.sql

.PHONY: transform-geometry
transform-geometry: start-db-nowait
	$(DOCKER_COMPOSE) run $(DC_OPTS) openmaptiles-tools psql.sh -v ON_ERROR_STOP=1 -d $(LTVT_DB) -P pager=off -f ./prepare_import/create_index_ltvt.sql
	$(DOCKER_COMPOSE) run $(DC_OPTS) openmaptiles-tools psql.sh -v ON_ERROR_STOP=1 -v schema="lbm" -d $(LTVT_DB) -P pager=off -f ./prepare_import/trans-epsg2056-3857.sql

.PHONY: import-sql
import-sql: all start-db-nowait
	$(DOCKER_COMPOSE) run $(DC_OPTS) openmaptiles-tools sh -c 'pgwait && import-sql' | \
	  awk -v s=": WARNING:" '$$0~s{print; print "\n*** WARNING detected, aborting"; exit(1)} 1'

.PHONY: generate-metadata
generate-metadata: start-db-nowait
	# Create mbtiles for newly generated metadata
	$(DOCKER_COMPOSE) $(DC_CONFIG_TILES) run $(DC_OPTS) openmaptiles-tools \
			mbtiles-tools meta-generate $(METADATA_LOCAL_FILE) $(TILESET_FILE)

.PHONY: create-contents
create-contents: start-db-nowait
	$(DOCKER_COMPOSE) run $(DC_OPTS) openmaptiles-tools psql.sh -U $(PGUSER) -d $(LTVT_DB) -f ./prepare_import/create_contents.sql \
	-v name="$(MD_NAME)" -v get_tile="$(MD_GETTILE)" -v extent="$(MD_EXTENT)" -v view_center="$(MD_CENTER)" -v view_zoom="$(MD_ZOOM)" \
	-v minzoom="$(MD_MIN_ZOOM)" -v maxzoom="$(MD_MAX_ZOOM)" -v attribution="$(MD_ATTRIBUTION)" -v description="$(MD_DESCRIPTION)" \
	-v vector_layers="$(MD_LAYERS)" -v properties="NULL"

.PHONY: copy-test-db
copy-test-db: start-db-nowait
	$(DOCKER_COMPOSE) run $(DC_OPTS) openmaptiles-tools psql.sh -U $(PGUSER) -d template1 -c "REVOKE CONNECT ON DATABASE $(LTVT_DB) FROM public"
	$(DOCKER_COMPOSE) run $(DC_OPTS) openmaptiles-tools psql.sh -U $(PGUSER) -d template1 -c "SELECT pg_terminate_backend(pg_stat_activity.pid) FROM pg_stat_activity WHERE pg_stat_activity.datname = '$(LTVT_DB)'"
	$(DOCKER_COMPOSE) run $(DC_OPTS) openmaptiles-tools sh -c "createdb --owner=$(PGUSER) -T $(LTVT_DB) $(TEST_PR_DB)"
	$(DOCKER_COMPOSE) run $(DC_OPTS) openmaptiles-tools psql.sh -U $(PGUSER) -d template1 -c "GRANT CONNECT ON DATABASE $(LTVT_DB) TO public"

.PHONY: remove-test-db
remove-test-db: start-db-nowait
	$(DOCKER_COMPOSE) run $(DC_OPTS) openmaptiles-tools psql.sh -U $(PGUSER) -d template1 -c "SELECT pg_terminate_backend(pg_stat_activity.pid) FROM pg_stat_activity WHERE pg_stat_activity.datname = '$(TEST_PR_DB)'"
	$(DOCKER_COMPOSE) run $(DC_OPTS) openmaptiles-tools sh -c "dropdb --if-exists $(TEST_PR_DB)"

.PHONY: import-sql-test
import-sql-test: start-db-nowait
	$(DOCKER_COMPOSE) run $(DC_OPTS) openmaptiles-tools sh -c 'export POSTGRES_DB=$(TEST_PR_DB) && pgwait && import-sql' | \
	  awk -v s=": WARNING:" '$$0~s{print; print "\n*** WARNING detected, aborting"; exit(1)} 1'

.PHONY: generate-tiles
generate-tiles: all start-db
	@$(assert_area_is_given)
	@echo "Generating tiles into $(MBTILES_LOCAL_FILE) (will delete if already exists)..."
	@rm -rf "$(MBTILES_LOCAL_FILE)"
	$(DOCKER_COMPOSE) $(DC_CONFIG_TILES) run $(DC_OPTS) generate-vectortiles
	@echo "Updating generated tile metadata ..."
	$(DOCKER_COMPOSE) $(DC_CONFIG_TILES) run $(DC_OPTS) openmaptiles-tools \
			mbtiles-tools meta-generate "$(MBTILES_LOCAL_FILE)" $(TILESET_FILE) --auto-minmax --show-ranges

ifneq ($(wildcard $(AREA_DC_CONFIG_FILE)),)
  DC_CONFIG_TILES := -f docker-compose.yml -f $(AREA_DC_CONFIG_FILE)
endif
.PHONY: generate-tiles-pg
generate-tiles-pg: all start-db
	@$(assert_area_is_given)
	@echo "Generating tiles into $(MBTILES_LOCAL_FILE) (will delete if already exists)..."
	@rm -rf "$(MBTILES_LOCAL_FILE)"
	$(DOCKER_COMPOSE) $(DC_CONFIG_TILES) run $(DC_OPTS) generate-vectortiles-pg generate-tiles
	@echo "Updating generated tile metadata ..."
	$(DOCKER_COMPOSE) $(DC_CONFIG_TILES) run $(DC_OPTS) openmaptiles-tools \
			mbtiles-tools meta-generate "$(MBTILES_LOCAL_FILE)" $(TILESET_FILE) --auto-minmax --show-ranges

.PHONY: start-maptiler-server
start-maptiler-server: start-db-nowait
	@echo "Starting MapTiler Server container (no recreate if exists)" && \
	$(DOCKER_COMPOSE) up --no-recreate -d maptiler-server

.PHONY: stop-maptiler-server
stop-maptiler-server:
	@echo "Stopping MapTiler Server container" && \
	$(DOCKER_COMPOSE) stop maptiler-server

.PHONY: start-tileserver
start-tileserver: init-dirs
	@echo " "
	@echo "***********************************************************"
	@echo "* "
	@echo "* Download/refresh maptiler/tileserver-gl docker image"
	@echo "* see documentation: https://github.com/maptiler/tileserver-gl"
	@echo "* "
	@echo "***********************************************************"
	@echo " "
	docker pull maptiler/tileserver-gl
	@echo " "
	@echo "***********************************************************"
	@echo "* "
	@echo "* Start maptiler/tileserver-gl "
	@echo "*       ----------------------------> check $(VT_PIPELINE_HOST):$(TPORT) "
	@echo "* "
	@echo "***********************************************************"
	@echo " "
	docker run $(DC_OPTS) -it --name tileserver-gl -v $$(pwd)/data:/data -p $(TPORT):$(TPORT) maptiler/tileserver-gl --port $(TPORT)

.PHONY: start-postserve
start-postserve: start-db
	@echo " "
	@echo "***********************************************************"
	@echo "* "
	@echo "* Bring up postserve at $(VT_PIPELINE_HOST):$(PPORT)"
	@echo "* "
	@echo "*  set data source / TileJSON URL to $(VT_PIPELINE_HOST):$(PPORT)"
	@echo "* "
	@echo "***********************************************************"
	@echo " "
	$(DOCKER_COMPOSE) up -d postserve

.PHONY: stop-postserve
stop-postserve:
	$(DOCKER_COMPOSE) stop postserve

# generate all etl and mapping graphs
.PHONY: generate-devdoc
generate-devdoc: init-dirs
	mkdir -p ./build/devdoc && \
	$(DOCKER_COMPOSE) run $(DC_OPTS) openmaptiles-tools sh -c \
			'generate-etlgraph $(TILESET_FILE) $(GRAPH_PARAMS) && \
			 generate-mapping-graph $(TILESET_FILE) $(GRAPH_PARAMS)'

.PHONY: bash
bash: init-dirs
	$(DOCKER_COMPOSE) run $(DC_OPTS) openmaptiles-tools bash

.PHONY: remove-docker-images
remove-docker-images:
	@echo "Deleting all openmaptiles related docker image(s)..."
	@$(DOCKER_COMPOSE) down
	@docker images "openmaptiles/*" -q                | $(XARGS) docker rmi -f
	@docker images "maputnik/editor" -q               | $(XARGS) docker rmi -f
	@docker images "maptiler/tileserver-gl" -q        | $(XARGS) docker rmi -f

.PHONY: clean-unnecessary-docker
clean-unnecessary-docker:
	@echo "Deleting unnecessary container(s)..."
	@docker ps -a -q --filter "status=exited" | $(XARGS) docker rm
	@echo "Deleting unnecessary image(s)..."
	@docker images | grep \<none\> | awk -F" " '{print $$3}' | $(XARGS) docker rmi
