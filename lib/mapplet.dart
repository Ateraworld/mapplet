library mapplet;

import "dart:async";

import "package:mapplet/src/depot/depot.dart";
import "package:mapplet/src/depot/depot_config.dart";

export "package:mapplet/src/common/extensions.dart";

export "package:mapplet/src/database/depot_stats.dart";
export "package:mapplet/src/database/models/region_model.dart";
export "package:mapplet/src/database/models/tile_model.dart";

export "package:mapplet/src/depot/depot.dart";
export "package:mapplet/src/depot/depot_config.dart";
export "package:mapplet/src/depot/fetch_operation.dart" hide TileFetchReport;

export "package:mapplet/src/providers/map_tile_provider.dart";

export "package:mapplet/src/widgets/location_watcher/location_watcher_layer.dart";
export "package:mapplet/src/widgets/location_watcher/payloads.dart";
export "package:mapplet/src/widgets/location_watcher/tweens.dart";

/// Entry point for handling offline maps with **Mapplet**
class Mapplet {
  static final List<Depot> _depots = List.empty(growable: true);

  /// Initiate the **Mapplet** plugin defining all the [DepotConfiguration]
  static Future<void> initialize(Iterable<DepotConfiguration> depots) async {
    _depots.clear();
    var initTasks = List<Future<Depot>>.empty(growable: true);
    for (final config in depots) {
      initTasks.add(Depot.open(config));
    }
    var res = await Future.wait(initTasks);
    _depots.addAll(res);
  }

  static Future<void> dispose({bool deleteFromDisk = false}) async {
    var tasks = List.generate(_depots.length, (index) => _depots.elementAt(index).close(deleteFromDisk: deleteFromDisk));
    await Future.wait(tasks);
  }

  /// Get a [Depot] by id
  static Depot depot(String id) => _depots.firstWhere((element) => element.config.id == id);
}
