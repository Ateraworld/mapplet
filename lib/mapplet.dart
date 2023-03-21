library mapplet;

import "dart:async";

import "package:mapplet/src/depot/depot.dart";
import "package:mapplet/src/depot/depot_config.dart";

export "package:mapplet/src/common/extensions.dart";

export "package:mapplet/src/database/depot_database.dart";
export "package:mapplet/src/database/depot_stats.dart";
export "package:mapplet/src/database/models/region_model.dart";
export "package:mapplet/src/database/models/tile_model.dart";

export "package:mapplet/src/depot/depot.dart";
export "package:mapplet/src/depot/depot_config.dart";
export "package:mapplet/src/depot/fetch_operation.dart";

export "package:mapplet/src/providers/map_tile_provider.dart";

/// Entry point for handling offline maps with OffMap
class Mapplet {
  static final List<Depot> _depots = List.empty(growable: true);

  static Future<void> initiate(Iterable<DepotConfiguration> depots) async {
    _depots.clear();
    var initTasks = List<Future<Depot>>.empty(growable: true);
    for (final config in depots) {
      initTasks.add(Depot.open(config));
    }
    var res = await Future.wait(initTasks);
    _depots.addAll(res);
  }

  static Depot depot(String id) => _depots.firstWhere((element) => element.config.id == id);
}
