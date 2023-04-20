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

## 1.0.6

* Added the `dispose` function to the **Mapplet** main class

## 1.1.0

* Updated **Isar** to major version _3.1.0_

### ❗Breaking changes

* `DepotConfiguration` now requires a directory in order to adapt to **Isar** _3.1.0_
