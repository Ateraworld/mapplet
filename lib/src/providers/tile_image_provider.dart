import "dart:async";
import "dart:io";
import "dart:ui";

import "package:flutter/foundation.dart";
import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:flutter_map/flutter_map.dart";
import "package:mapplet/src/common/logger.dart";
import "package:mapplet/src/database/models/tile_model.dart";
import "package:mapplet/src/depot/depot.dart";
import "package:mapplet/src/providers/map_tile_provider.dart";
import "package:meta/meta.dart";

/// The tile image provider of **Mapplet**
///
/// Tries to load the tile from the local [Depot], if not present, fetches it from the web
@internal
class MappletTileImageProvider extends ImageProvider<MappletTileImageProvider> {
  MappletTileImageProvider({
    required this.depot,
    required this.options,
    required this.coords,
  }) : tileProvider = depot.getTileProvider();
  final Depot depot;
  final HttpClient client = HttpClient();
  final TileLayer options;
  final TileCoordinates coords;
  final MappletTileProvider tileProvider;

  @override
  ImageStreamCompleter loadImage(
    MappletTileImageProvider key,
    ImageDecoderCallback decode,
  ) {
    // ignore: close_sinks
    final StreamController<ImageChunkEvent> chunkEvents = StreamController<ImageChunkEvent>();
    var codec = _loadCodec(key: key, decode: decode, chunkEvents: chunkEvents);
    var stream = MultiFrameImageStreamCompleter(
      codec: codec,
      chunkEvents: chunkEvents.stream,
      scale: 1,
      debugLabel: coords.toString(),
      informationCollector: () => <DiagnosticsNode>[
        DiagnosticsProperty<TileCoordinates>("Coordinates", coords),
      ],
    );
    return stream;
  }

  Future<Codec> _loadCodec({
    required MappletTileImageProvider key,
    required ImageDecoderCallback decode,
    required StreamController<ImageChunkEvent> chunkEvents,
  }) async {
    Uint8List? bytes;
    final tileUrl = tileProvider.getTileUrl(coords, options);
    Codec codec;
    TileModel? tile;
    try {
      tile = await depot.getTile(tileUrl);
      var evictPeriod = depot.config.tilesStoreEvictPeriod ?? const Duration(days: 7);
      var shouldUpdate = tile != null && (DateTime.now().toUtc().millisecondsSinceEpoch - tile.timestamp >= evictPeriod.inMilliseconds);
      if (tile == null || shouldUpdate) {
        // if (res != null) {
        //   log("url ${res.url}, ts ${res.timestamp}, ts diff ${DateTime.now().toUtc().millisecondsSinceEpoch - res.timestamp}, evict ms ${evictPeriod.inMilliseconds}");
        // }
        final HttpClientResponse response;
        final request = await client.getUrl(Uri.parse(tileUrl));
        tileProvider.headers.forEach(
          (k, v) => request.headers.add(k, v, preserveHeaderCase: true),
        );
        response = await request.close();
        // Read the bytes from the HTTP request response
        bytes = await consolidateHttpClientResponseBytes(
          response,
          onBytesReceived: (int cumulative, int? total) {
            chunkEvents.add(
              ImageChunkEvent(
                cumulativeBytesLoaded: cumulative,
                expectedTotalBytes: total,
              ),
            );
          },
        );
        if (shouldUpdate) {
          depot.db.writeSingleTile(TileModel.factory(tileUrl, bytes)).then((value) => log("evicted"));
        }
        codec = await decode(await ImmutableBuffer.fromUint8List(bytes));
      } else {
        codec = await decode(await ImmutableBuffer.fromUint8List(Uint8List.fromList(tile.bytes)));
      }
    } catch (err) {
      log(err.toString());
      if (tile != null) {
        codec = await decode(await ImmutableBuffer.fromUint8List(Uint8List.fromList(tile.bytes)));
      } else {
        // Empty error image
        codec = await decode(
          await ImmutableBuffer.fromUint8List(Uint8List.fromList([])),
        );
      }
    } finally {
      scheduleMicrotask(() => PaintingBinding.instance.imageCache.evict(key));
      chunkEvents.close();
    }
    return codec;
  }

  @override
  Future<MappletTileImageProvider> obtainKey(
    ImageConfiguration configuration,
  ) =>
      Future.value(this);
}
