# The easiest way to store flutter maps for offline usage

🧪 Although mantained and currently being worked on, the package is very young and under development

## Features

**Mapplet** has been designed with simplicity in mind.
The code has been provided with the strict necessary to allow developers to store maps for offline usage using the packet [flutter_map](https://pub.dev/packages/flutter_map).

Also, it includes a useful layer for **flutter_map** that allows to easily display the user's current location automatically.

### Definitions

**`Region`**
> A region is an area identified by its `LatLngBounds`

**`Depot`**
> Identifies a storage that can contain an arbitrary number of **Regions**. Tiles inside a depot are dynamically shared among regions in order to prevent redownload and save space. Any number of depots can be created during the setup

### Main features

* Store and delete regions by `id`: each `Depot` can contain many regions
* Save space: **Mapplet** detects already stored tiles shared among regions inside each `Depot` and prevent redownload automatically
* Parallel fetch: region tiles are fetched with multiple workers and written in batches on the internal database. This allows for _transaction-like_ operations with clean `abort` and `commit`.
* Extremely fast learning curve: **Mapplet** exposes only the strictly necessary to the developer. With a single point of configuration, integrating the package in projects is very easy.
* A simple and ready to use layer for **flutter_map** that allows to easily display the user's current location automatically.

## Getting started

### Initialize the packet

The packet is initialized by calling a single function and passing the configuration of each single depot. In order to make the package very simple and functional, the `DepotConfiguration` is the single element used for configuring the behaviour of each `Depot` in **Mapplet**.

```dart
await Mapplet.initiate([
        DepotConfiguration(
            id: String,
            minZoom: double,
            maxZoom: double,
            directory: String,
            urlTemplate: String
        ),
        ...
    ]);
```

Each configuration specified here will result in a single `Depot` being created under the hood.

❗Version **^1.1.0**

* `DepotConfiguration` requires the directory field. It is recommended to use the package [path_provider](https://pub.dev/packages/path_provider) to request a directory location that adapts to different platforms using `getApplicationDocumentsDirectory()`.

## Usage

### Store a region

To store a region, firstly create the `LatLngBounds` that describes the region to be stored. **Mapplet** exposes some useful methods to handle regions:

```dart
var center = LatLng(46, 12);
// Create a [LatLngBounds] specifying its center and the distance in kilometers from center.
// The result is a square region with half side equal to the specified distance
var bounds = LatLngBoundsExtensions.fromDelta(center, 10);
```

Then retrieve the instance of the `Depot` and run the fetch operation

```dart
var depot = await Mapplet.depot("my_depot");

var depositOp = await depot.depositRegion("region_id", bounds);
// Listen for abort events
depositOp.onAbort.listen((_) async {
    // Do something O.o
});
// Listen for commit event called when the region is commited to the database
depositOp.onCommit.listen((commitFuture) async {
    // Do something
});
// Start the fetching operation
var stream = depositOp.fetch();
// Wait for progress reports
await for (final progress in stream) {
    // Handle progress
    // Or, whenever you want, abort the operation
    await depositOp.abort();
}
```

### Delete a region

Yes, simple as this.

```dart
var depot = await Mapplet.depot("my_depot");
await depot.dropRegion("region_id");
```

### Use the `TileProvider`

Again, two lines of code.
**Mapplet** has a single tile providers associated with each `Depot`.

* Tries to get the tiles from the storage
* Otherwise, fetches it from the web
* Automatically updates stored tiles based on the evict period defined in the `DepotConfiguration`

```dart
var depot = await Mapplet.depot("my_depot");
var tileProvider = depot.getTileProvider();
```

## Additional information

There are some useful methods in the `extensions` module of **Mapplet**. They are automatically imported with the root import.

Extensions subjects:

* `LatLngBounds`
* `int`
* `LatLng`
* `List<LatLng>`

## Current location layer

**Mapplet** includes also a useful layer to automatically display the user's current location in the map.

To access it, simply add the `LocationWatcherLayer` to **flutter_map**:

```dart
LocationWatcherLayer(
    positionStream: _positionStream.stream,
    style: LocationWatcherLayerStyle(
        showAccuracyCircle: false,
        directionRadius: 64,
        directionAngle: 80,
        showDirection: widget.showDirectionSector,
        markerSize: const Size.square(20),
        directionColor: Colors.red,
        locationMarker: DecoratedBox(
        decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
        ),
        child: Padding(
            padding: const EdgeInsets.all(2),
            child: DecoratedBox(
            decoration: BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
            ),
            ),
        ),
        ),
    ),
)
```
