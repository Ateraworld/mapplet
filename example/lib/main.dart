import "package:flutter/material.dart";
import "package:latlong2/latlong.dart";
import "package:mapplet/mapplet.dart";

Future<void> main() async {
  await Mapplet.initialize([
    DepotConfiguration(
      id: "default_depot",
      urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
      minZoom: 10,
      maxZoom: 16,
    ),
  ]);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Mapplet",
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: "Mapplet"),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final Depot _depot = Mapplet.depot("default_depot");
  DepotStats? _stats;
  FetchOperation? _fetchOp;
  FetchProgress? _progressFirst;
  FetchProgress? _progressSecond;
  bool _committingFirst = false;
  bool _committingSecond = false;

  Widget _buildStats() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 8,
              children: [
                const Icon(Icons.storage_rounded),
                Text(
                  _stats != null ? "${_stats!.byteSize.byteToMib().toStringAsFixed(1)} MiB" : "...",
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              "occupied",
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 8,
              children: [
                const Icon(Icons.landscape_rounded),
                Text(
                  _stats != null ? _stats!.regionCount.toString() : "...",
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              "regions",
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 8,
              children: [
                const Icon(Icons.square_rounded),
                Text(
                  _stats != null ? _stats!.tilesCount.toString() : "...",
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              "tiles",
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ],
    );
  }

  Iterable<Widget> _buildFirstRegion() sync* {
    yield const Text(
      "First region",
      style: TextStyle(fontSize: 20),
    );
    yield Padding(
      padding: const EdgeInsets.all(8),
      child: LinearProgressIndicator(
        value: _progressFirst?.progress ?? 0,
      ),
    );

    yield Padding(
      padding: const EdgeInsets.all(16),
      child: SizedBox(
        height: 16,
        width: 16,
        child: _committingFirst ? const CircularProgressIndicator() : null,
      ),
    );
    yield Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: ElevatedButton.icon(
              onPressed: _committingSecond || _committingFirst
                  ? null
                  : () async {
                      _fetchOp = _depot.depositRegion("region", LatLngBoundsExtensions.fromDelta(LatLng(46, 12), 2.5));
                      _fetchOp!.onAbort.listen((_) {
                        debugPrint("operation aborted");
                        setState(() => _committingFirst = false);
                      });
                      _fetchOp!.onCommit.listen((commitFuture) async {
                        setState(() => _committingFirst = true);
                        await commitFuture;
                        debugPrint("operation committed");
                        var stats = await _depot.getStats();
                        setState(() {
                          _committingFirst = false;
                          _stats = stats;
                        });
                      });
                      await for (final progress in _fetchOp!.fetch()) {
                        setState(() => _progressFirst = progress);
                      }
                    },
              icon: const Icon(Icons.download_rounded),
              label: const Text("Download region"),
            ),
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: ElevatedButton.icon(
              onPressed: _committingSecond || _committingFirst
                  ? null
                  : () async {
                      await _depot.dropRegion("region");
                      var stats = await _depot.getStats();
                      setState(() => _stats = stats);
                    },
              icon: const Icon(Icons.delete_rounded),
              label: const Text("Delete region"),
            ),
          ),
        ),
      ],
    );
  }

  Iterable<Widget> _buildSecondRegion() sync* {
    yield const Text(
      "Second region",
      style: TextStyle(fontSize: 20),
    );
    yield Padding(
      padding: const EdgeInsets.all(8),
      child: LinearProgressIndicator(
        value: _progressSecond?.progress ?? 0,
      ),
    );
    yield Padding(
      padding: const EdgeInsets.all(16),
      child: SizedBox(
        height: 16,
        width: 16,
        child: _committingSecond ? const CircularProgressIndicator() : null,
      ),
    );
    yield Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: ElevatedButton.icon(
              onPressed: _committingSecond || _committingFirst
                  ? null
                  : () async {
                      _fetchOp = _depot.depositRegion("region_1", LatLngBoundsExtensions.fromDelta(LatLng(46, 12), 5));
                      _fetchOp!.onAbort.listen((_) {
                        debugPrint("operation aborted");
                        setState(() => _committingSecond = false);
                      });
                      _fetchOp!.onCommit.listen((commitFuture) async {
                        setState(() => _committingSecond = true);
                        await commitFuture;
                        debugPrint("operation committed");
                        var stats = await _depot.getStats();
                        setState(() {
                          _committingSecond = false;
                          _stats = stats;
                        });
                      });
                      await for (final progress in _fetchOp!.fetch()) {
                        setState(() => _progressSecond = progress);
                      }
                    },
              icon: const Icon(Icons.download_rounded),
              label: const Text("Download region"),
            ),
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: ElevatedButton.icon(
              onPressed: _committingSecond || _committingFirst
                  ? null
                  : () async {
                      await _depot.dropRegion("region_1");
                      var stats = await _depot.getStats();
                      setState(() => _stats = stats);
                    },
              icon: const Icon(Icons.delete_rounded),
              label: const Text("Delete region"),
            ),
          ),
        ),
      ],
    );
    yield const Text(
      "The second region is centered at the same spot of the first region but expands for double the area.\nMapplet detects the overlap and skips the fetch procedure on common tiles",
      textAlign: TextAlign.center,
      style: TextStyle(fontSize: 18),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(widget.title),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              _buildStats(),
              const Divider(height: 32),
              ..._buildFirstRegion(),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 32),
                child: Container(height: 8, color: Colors.grey),
              ),
              ..._buildSecondRegion(),
              const Divider(),
            ],
          ),
        ),
      ),
    );
  }
}
