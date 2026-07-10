# ytdata

<!-- badges: start -->
[![R-CMD-check](https://github.com/FOR-CAST/ytdata/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/FOR-CAST/ytdata/actions/workflows/R-CMD-check.yaml)
<!-- badges: end -->

Lightweight R helpers to fetch Government of Yukon open geospatial data from the
[GeoYukon](https://mapservices.gov.yk.ca/arcgis/rest/services/GeoYukon) ArcGIS REST services as `sf`
objects. There is no `bcdata`-style package for Yukon, so `ytdata` wraps the GeoYukon ArcGIS REST
`query` endpoints and keeps a small registry of commonly used layers.

## Installation

``` r
# install.packages("pak")
pak::pak("FOR-CAST/ytdata")
```

## Usage

``` r
library(ytdata)

yt_layers()                     # registered layers
herds <- yt_get_caribou_herds() # all Yukon caribou herd ranges
yt_get("caribou_herd_ranges")   # fetch by registry key
```

Fetched layers are returned in EPSG:4326; reproject with `sf::st_transform()` as needed.
