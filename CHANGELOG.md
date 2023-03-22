# Changelog

## 1.0.2

* Initial version

## 1.0.3

* Parallelism improvements: number of workers now dynamically depends on the number of tiles to fetch
* Improved the speed of the fetch operation with Dart `Isolates`
* Introduced the _evict period_ for stored tiles, indicating how often they should be updated
