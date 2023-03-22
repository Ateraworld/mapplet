# Changelog

## 1.0.2

* Initial version

## 1.0.3

* Parallelism improvements: number of workers now dynamically depends on the number of tiles to fetch
* Improved the speed of the fetch operation with Dart `Isolates`
* Introduced the _evict period_ for stored tiles, indicating how often they should be updated

## 1.0.4

* Added the configuration parameter for the number of `parallelBatchWriters` during a fetch operation
* Added the _example_ folder

## 1.0.5

* Added the abort reason to the abort stream
