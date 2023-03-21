import "dart:async";

import "package:flutter/widgets.dart";
import "package:http/http.dart" as http;
import "package:mapplet/src/common/extensions.dart";
import "package:mapplet/src/database/depot_database.dart";
import "package:mapplet/src/database/models/tile_model.dart";
import "package:mapplet/src/depot/depot_config.dart";
import "package:queue/queue.dart";
import "package:quiver/iterables.dart";

class FetchProgress {
  FetchProgress({
    required this.progress,
    required this.sizeByte,
  });
  final int sizeByte;
  final double progress;
}

class TileFetchReport {
  TileFetchReport({required this.sizeByte});

  final int sizeByte;
}

class FetchOperation {
  FetchOperation({
    required DepotDatabase db,
    required this.regionId,
    required this.urls,
    required this.config,
  }) : _db = db;
  final DepotDatabase _db;

  final DepotConfiguration config;
  final String regionId;
  http.Client client = http.Client();
  final Iterable<String> urls;
  Queue? _workersQueue;
  bool _fetching = false;
  StreamController? _operationGate;

  // ignore: close_sinks
  final StreamController _abortStreamController = StreamController.broadcast();
  // ignore: close_sinks
  final StreamController<Future<void>> _commitStreamController = StreamController.broadcast();

  Stream<void> get onAbort => _abortStreamController.stream;
  Stream<void> get onCommit => _commitStreamController.stream;

  Future<void> _fetcher({
    required Iterable<String> urls,
    required StreamController gate,
    required StreamController<TileFetchReport> fetchReport,
    double maxHeapSizeMib = 8,
  }) async {
    var fetched = List<TileModel>.empty(growable: true);
    var storedTiles = await _db.getTilesByUrl(urls);
    int retry = 0;
    int size = 0;
    for (int i = 0; i < storedTiles.length; i++) {
      var url = urls.elementAt(i);
      TileModel? res = storedTiles.elementAt(i);
      while (res == null && retry < config.fetchTileAttempts) {
        try {
          final http.Response response = await client.get(Uri.parse(url)).timeout(config.fetchTileTimeout);
          res = TileModel.factory(url, response.bodyBytes);
        } catch (error) {
          if (error is TimeoutException) {
            debugPrint("tile fetch timeout");
          } else {
            debugPrint("error on fetcher: $error");
          }
          res = null;
        }
        if (gate.isClosed) return;
        retry++;
      }
      if (res == null) {
        return Future.error("failed to fetch tile, $retry attempts");
      }
      //logDebug("tile fetched, ${retry} tries");
      fetched.add(res);
      fetchReport.sink.add(TileFetchReport(sizeByte: res.bytes.length));
      size += res.bytes.length;
      retry = 0;
      if (size.byteToMib() >= maxHeapSizeMib) {
        _db.batchWriteTx(fetched.toList());

        fetched.clear();
        size = 0;
      }
    }
    _db.batchWriteTx(fetched.toList());
  }

  int _computeThreadCount(int tiles) => min([(tiles ~/ 64) + 1, config.fetchMaxWorkers])!;

  int _computeBatchSize(int tiles) => max([4, tiles ~/ _computeThreadCount(tiles)])!;

  Future<void> abort() async {
    _operationGate?.close();
    try {
      _workersQueue?.cancel();
    } catch (_) {}
    await _db.cleanTx();
    debugPrint("fetch operation aborted");
    _abortStreamController.sink.add(null);
  }

  Stream<FetchProgress> fetch() async* {
    if (_fetching) return;
    await _db.cleanTx();

    var batchSize = _computeBatchSize(urls.length);
    var threadCount = _computeThreadCount(urls.length);
    var threadMaxHeapSizeMib = config.fetchMaxHeapSizeMib / threadCount;
    debugPrint(
      "${urls.length} tiles, $threadCount threads with batches of $batchSize, max heap size ${config.fetchMaxHeapSizeMib} MiB, $threadMaxHeapSizeMib MiB per thread",
    );

    _fetching = true;
    _operationGate = StreamController.broadcast();
    _workersQueue = Queue(parallel: threadCount);

    var completed = 0;
    var cumulativeSizeByte = 0;

    client = http.Client();
    bool aborted = false;
    StreamController<TileFetchReport> tileFetchController = StreamController.broadcast();

    for (final partition in partition(urls, batchSize)) {
      _workersQueue!
          .add(
        () => _fetcher(urls: partition, gate: _operationGate!, fetchReport: tileFetchController, maxHeapSizeMib: threadMaxHeapSizeMib),
      )
          .onError((error, stackTrace) {
        if (error is! QueueCancelledException) {
          debugPrint("fetcher error $error, aborting operation");
          aborted = true;
          abort();
        }
      });
    }
    await for (final tileReport in tileFetchController.stream) {
      completed++;
      cumulativeSizeByte += tileReport.sizeByte;
      var progress = FetchProgress(progress: completed / urls.length, sizeByte: cumulativeSizeByte);
      yield progress;
      if (completed >= urls.length) break;
    }

    if (!aborted) {
      var commit = _db.commitRegionTx(regionId);
      _commitStreamController.sink.add(commit);
      await commit;
    }
    tileFetchController.close();
    _fetching = false;
  }
}