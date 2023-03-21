import "dart:async";
import "dart:io";
import "dart:ui";

import "package:flutter/foundation.dart";
import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:flutter_map/flutter_map.dart";
import "package:mapplet/src/depot/depot.dart";
import "package:mapplet/src/providers/map_tile_provider.dart";

class MappletTileImageProvider extends ImageProvider<MappletTileImageProvider> {
  MappletTileImageProvider({
    required this.depot,
    required this.options,
    required this.coords,
  }) : tileProvider = depot.getTileProvider();
  final Depot depot;
  final HttpClient client = HttpClient();
  final TileLayer options;
  final Coords<num> coords;
  final MappletTileProvider tileProvider;
  ImmutableBuffer? _errorImageBuffer;

  @override
  ImageStreamCompleter loadBuffer(MappletTileImageProvider key, DecoderBufferCallback decode) {
    // ignore: close_sinks
    final StreamController<ImageChunkEvent> chunkEvents = StreamController<ImageChunkEvent>();
    var codec = _loadCodec(key: key, decode: decode, chunkEvents: chunkEvents);
    var stream = MultiFrameImageStreamCompleter(
      codec: codec,
      chunkEvents: chunkEvents.stream,
      scale: 1,
      debugLabel: coords.toString(),
      informationCollector: () => <DiagnosticsNode>[
        DiagnosticsProperty<Coords>("Coordinates", coords),
      ],
    );
    return stream;
  }

  Future<Codec> _loadCodec({
    required MappletTileImageProvider key,
    required DecoderBufferCallback decode,
    required StreamController<ImageChunkEvent> chunkEvents,
  }) async {
    Uint8List? bytes;
    final networkUrl = tileProvider.getTileUrl(coords, options);
    Codec codec;
    //* Try get bytes from Isar, if not present, retrieve them from the network
    // !
    try {
      var res = await depot.getTile(networkUrl);
      if (res == null) {
        final HttpClientResponse response;

        final request = await client.getUrl(Uri.parse(networkUrl));
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
        codec = await decode(await ImmutableBuffer.fromUint8List(bytes), allowUpscaling: false);
      } else {
        codec = await decode(await ImmutableBuffer.fromUint8List(Uint8List.fromList(res.bytes)), allowUpscaling: false);
      }
    } catch (err) {
      debugPrint(err.toString());
      _errorImageBuffer ??= await ImmutableBuffer.fromUint8List((await rootBundle.load("assets/images/surface.png")).buffer.asUint8List());
      codec = await decode(_errorImageBuffer!, allowUpscaling: false);
    } finally {
      scheduleMicrotask(() => PaintingBinding.instance.imageCache.evict(key));
      chunkEvents.close();
    }
    return codec;
  }

  @override
  Future<MappletTileImageProvider> obtainKey(ImageConfiguration configuration) => Future.value(this);
}
