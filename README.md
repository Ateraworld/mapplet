# The easiest way to store flutter maps for offline usage

🧪 Although mantained and currently being worked on, the package is very young and under development

## Features

**Mapplet** has been designed with simplicity in mind.
The code has been provided with the strict necessary to allow developers to store maps for offline usage using the packet [flutter_map](https://pub.dev/packages/flutter_map).

The **Mapplet** framework is very easy:

* The fetch from the web operation is executed in parallel on multiple workers
* Writes operation on the database are batched to increase performance
* The fetch operation is structured in a _transaction-like_ operation allowing easy `commits` and `aborts`
* Uses an internal _temp_database_ to prevent corrupted data to be commited into the database

## Getting started

### Initialize the packet

The packet is initialized by calling a single function and passing the configuration of each single depot

```dart
await Mapplet.initiate([
        DepotConfiguration(
            id: String,
            minZoom: double,
            maxZoom: double,
            urlTemplate: String
        ),
        ...
    ]);
```

Each configuration specified here will result in a single `Depot` being created under the hood.

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

## Additional information

There are some useful methods in the `extensions` module of **Mapplet**. They are automatically imported with the root import.

Extensions subjects:

* `LatLngBounds`
* `int`
* `LatLng`
* `List<LatLng>`
