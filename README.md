# Swisstopo base map

## Terms of use
The description below are intended for swisstopo development-team to produce VTs. If you wish to download mbtiles (see releases), please check the TermsOfUse-OGD-swisstopo file.

## Infrastructure Overview and Links
The first image shows the setup of the Virtual EC2 machine, including the connections between postgres databases and 
APACHE server, with links to relevant pieces below.

![VT Pipeline AWS](https://user-images.githubusercontent.com/19833762/94259506-d8da8700-ff2e-11ea-9b09-145409b304ec.png)

This image provides an overview of the technical infrastructure composing the Vector Tiles pipeline, including the 
connections between existing BGDI databases, the virtual machine setup, the GitHub repository, local machines, 
and MapTiler Cloud.

![VT Pipeline Overview](https://user-images.githubusercontent.com/19833762/94141897-bcc2e100-fe6d-11ea-9c47-53f255b68b79.png)

## DEV schema docs
- https://geoadmin.github.io/config-vt-schema-sbm/



## Overview of cartographer process
1. Make any change into *.sql or *.yaml file to modify data visualization, generalization or any other change. 
You can modify it either locally in your cloned repository or do it directly in the GitHub editor on the web.

2. Promote your changes as a pull request to the master branch. It triggers *SwissTopo CI generate reports* workflow.
A new branch is created for your pull request and statistics about tile size and tile speed generation are created and
 added to your pull request as a comment. It takes about half an hour. (Purple arrows in the schema.)

3. Inspect the statistic and see how your modifications have affected the tiles. After that you can either:
Do another modification and commit it into the pull request. The statistics will be re-recreated.
Merge your pull request into master branch. It takes about half an hour. It triggers *SwissTopo CI - import sql* workflow.
 (Orange arrow in the schema). 

4. Check the live-preview of master branch at: https://swisstopo.maptiler.ch/tileset/dev

5. Create a release of tiles on GitHub webpage. (Green arrows in schema.) Generated tiles will be uploaded as release 
artefacts and also uploaded to SwissTopo account at MapTiler cloud.

updating etl documentation for gh-pages controlled by https://github.com/geoadmin/config-vt-schema-sbm/blob/ghpages/generate-jekyll-layer-docs.sh

## Overview of PROD tiles creation process
1. (optional) Make sure your data in the PROD database are up to date. Run Import data workflow from GitHub and choose the 
PROD branch. Or run re-import of data locally as described in *Manual steps for Database Preparation* section of 
Installation protocol. Re-import of data takes about two hours.

2. Merge master branch into PROD branch. It triggers SwissTopo CI - import sql workflow. Or you can run import of sql 
locally as described in *Work on Layers/Import of sql* section of Installation protocol.

3. Create a new release over the PROD branch. It triggers *SwissTopo CI - generate mbtiles* workflow. Or you can generate 
tiles locally as described in *Generate Vector Tiles* section of Installation protocol.

4. If you have used GitHub Action, MBTiles will be uploaded to MapTiler Cloud and to the release at GitHub. 

5. (optional) If you want to upload the mbtiles to S3 bucket you have to do it manually as described in *CloudPush* and 
*AWS CLI* sections of Installation protocol.

## config-vt-gl-styles

Styles for Vector Tiles Products

The styles, including fonts and sprites, can be edited directly within MapTiler Cloud. The GL styles may then be exported by cartography team for KOGIS team release - while storing all the required files for deployment in GitHub.

1. To export the style from MapTiler Cloud, navigate the Maps menu, select the map, and select "Export Style" from the Drop-Down menu at the bottom-right of the Map Preview.

2. sprites: open style.json and open the link given under "sprite:" (e.g. https://api.maptiler.com/maps/5c14e290-720c-4465-b559-698fa2bcc11c/sprite) and append ".png", "@2x.png", ".json", "@2x.json"

3. To upload the style & sprite to GitHub,navigate to https://github.com/geoadmin/config-vt-gl-styles/tree/master/sbm, and select "Upload files" under the "Add File" drop-down OR create local repository and push to github.

