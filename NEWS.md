# ytdata (development version)

* `yt_arcgis_fetch()` sends `bbox` values in full. `paste()` wrote a round value of 1e5 or more, or a small one such as 1e-5, in scientific notation (`1e+05`), so a projected bounding box could reach the service as `1e+05,1e+06,...` (0.0.0.9003).
* New `yt_layer_url()` builds the GeoYukon `MapServer` layer URL for a service and layer id (vectorised), so other code need not copy the GeoYukon base URL; `yt_arcgis_fetch()` now uses it.
* Declares `Depends: R (>= 4.1.0)`, since the code uses the native pipe.
* Initial version.
* `yt_arcgis_fetch()` fetches a GeoYukon ArcGIS REST layer as an `sf` object, with server-side attribute and bounding-box filtering and transparent paging.
* `yt_get()` fetches a layer registered in the ytdata layer registry, and `yt_layers()` lists the registry.
* `yt_get_caribou_herds()` fetches the GeoYukon caribou herd ranges, optionally filtered to named herds.
