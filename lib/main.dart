import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import './locations.dart' as locations;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MyAppState(),
      child: MaterialApp(
        title: 'Flutter 3.x & Google Map Debugger App',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepOrange),
        ),
        home: const MyHomePage(),
      ),
    );
  }
}

class MyAppState extends ChangeNotifier {}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    var colorScheme = Theme.of(context).colorScheme;

    Widget page;
    switch (selectedIndex) {
      case 0:
        page = const SampleMapPage();
        break;
      case 1:
        page = const MapBugPage();
        break;
      default:
        throw UnimplementedError('no widget for $selectedIndex');
    }

    // The container for the current page, with its background color
    // and subtle switching animation.
    var mainArea = ColoredBox(
      color: colorScheme.surfaceVariant,
      child: AnimatedSwitcher(
        duration: Duration(milliseconds: 200),
        child: page,
      ),
    );

    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth < 450) {
            // Use a more mobile-friendly layout with BottomNavigationBar
            // on narrow screens.
            return Column(
              children: [
                Expanded(child: mainArea),
                SafeArea(
                  child: BottomNavigationBar(
                    items: const [
                      BottomNavigationBarItem(
                        icon: Icon(Icons.map),
                        label: 'Google Map',
                      ),
                      BottomNavigationBarItem(
                        icon: Icon(Icons.bug_report),
                        label: 'Map Bug',
                      ),
                    ],
                    currentIndex: selectedIndex,
                    onTap: (value) {
                      setState(() {
                        selectedIndex = value;
                      });
                    },
                  ),
                )
              ],
            );
          } else {
            return Row(
              children: [
                SafeArea(
                  child: NavigationRail(
                    extended: constraints.maxWidth >= 600,
                    destinations: const [
                      NavigationRailDestination(
                        icon: Icon(Icons.map),
                        label: Text('Google Map'),
                      ),
                      NavigationRailDestination(
                        icon: Icon(Icons.bug_report),
                        label: Text('Map Bug'),
                      ),
                    ],
                    selectedIndex: selectedIndex,
                    onDestinationSelected: (value) {
                      setState(() {
                        selectedIndex = value;
                      });
                    },
                  ),
                ),
                Expanded(child: mainArea),
              ],
            );
          }
        },
      ),
    );
  }
}

class SampleMapPage extends StatefulWidget {
  const SampleMapPage({Key? key}) : super(key: key);

  @override
  State<SampleMapPage> createState() => _SampleMapPageState();
}

class _SampleMapPageState extends State<SampleMapPage> {
  final Map<String, Marker> _markers = {};

  Future<void> _onMapCreated(GoogleMapController controller) async {
    final googleOffices = await locations.getGoogleOffices();
    setState(() {
      _markers.clear();
      for (final office in googleOffices.offices) {
        final marker = Marker(
          markerId: MarkerId(office.name),
          position: LatLng(office.lat, office.lng),
          infoWindow: InfoWindow(
            title: office.name,
            snippet: office.address,
          ),
        );
        _markers[office.name] = marker;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.green[700],
      ),
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Google Office Locations'),
          elevation: 2,
        ),
        body: GoogleMap(
          onMapCreated: _onMapCreated,
          initialCameraPosition: const CameraPosition(
            target: LatLng(0, 0),
            zoom: 2,
          ),
          markers: _markers.values.toSet(),
        ),
      ),
    );
  }
}

class MapBugPage extends StatelessWidget {
  const MapBugPage({super.key});

  final marker = const Marker(
    markerId: MarkerId("Gopuff HQ"),
    position: LatLng(39.96111303475691, -75.14318105207377),
    infoWindow: InfoWindow(
      title: "Gopuff HQ",
      snippet: "537 N 3rd St, Philadelphia PA, 19123",
    ),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Flutter Map Crash Issue')
          // https://github.com/flutter/flutter/issues/105965
          ),
      body: Center(
        child: ElevatedButton(
          child: const Text('Show map'),
          onPressed: () => Navigator.of(context, rootNavigator: true).push(
            MaterialPageRoute(
              builder: (ctx) => Scaffold(
                appBar: AppBar(
                  actions: [
                    IconButton(
                      onPressed: Navigator.of(ctx, rootNavigator: true).pop,
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
                body: GoogleMap(
                  initialCameraPosition: const CameraPosition(
                    target: LatLng(39.96111303475691, -75.14318105207377),
                    zoom: 18,
                  ),
                  markers: {marker},
                  compassEnabled: false,
                  myLocationButtonEnabled: false,
                  myLocationEnabled: false,
                  scrollGesturesEnabled: true,
                  zoomGesturesEnabled: true,
                  rotateGesturesEnabled: false,
                  zoomControlsEnabled: false,
                  mapToolbarEnabled: false,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
