# ytdata 0.0.0.9001

* New `yt_layer_url()` builds the GeoYukon `MapServer` layer URL for a service and layer id (vectorised), so other code need not copy the GeoYukon base URL; `yt_arcgis_fetch()` now uses it.

# ytdata 0.0.0.9000

* Initial version.
* `yt_arcgis_fetch()` fetches a GeoYukon ArcGIS REST layer as an `sf` object, with server-side attribute and bounding-box filtering and transparent paging.
* `yt_get()` fetches a layer registered in the ytdata layer registry, and `yt_layers()` lists the registry.
* `yt_get_caribou_herds()` fetches the GeoYukon caribou herd ranges, optionally filtered to named herds.
