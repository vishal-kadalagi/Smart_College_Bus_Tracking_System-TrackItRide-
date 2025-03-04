import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class AdminRouteManagementScreen extends StatefulWidget {
  const AdminRouteManagementScreen({super.key});

  @override
  _AdminRouteManagementScreenState createState() =>
      _AdminRouteManagementScreenState();
}

class _AdminRouteManagementScreenState
    extends State<AdminRouteManagementScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late GoogleMapController _mapController;
  Map<String, Polyline> polylines = {};

  @override
  void initState() {
    super.initState();
    _loadAllPolylines(); // Load polylines for all routes on startup
  }

  // Fetch all routes
  Future<List<Map<String, dynamic>>> fetchRoutes() async {
    QuerySnapshot routeSnapshot = await _firestore.collection('routes').get();
    List<Map<String, dynamic>> routes = routeSnapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      return {
        'id': doc.id,
        'route': data['route'] ?? 'Unnamed Route',
        'trips': data['trips'] ?? {'trip1': [], 'trip2': []},
      };
    }).toList();

    routes.sort((a, b) {
      final nameA = a['route'];
      final nameB = b['route'];
      final numberA = int.tryParse(nameA.replaceAll(RegExp(r'\D'), '')) ?? 0;
      final numberB = int.tryParse(nameB.replaceAll(RegExp(r'\D'), '')) ?? 0;
      return numberA.compareTo(numberB);
    });
    return routes;
  }

  // Load all polylines from Firestore
  Future<void> _loadAllPolylines() async {
    QuerySnapshot routeSnapshot = await _firestore.collection('routes').get();
    for (var doc in routeSnapshot.docs) {
      await updatePolyline(doc.id);
    }
  }

  // Add route to Firestore
  void addRoute(String routeName) async {
    if (routeName.isNotEmpty) {
      await _firestore.collection('routes').add({
        'route': routeName,
        'trips': {
          'trip1': [],
          'trip2': [],
        },
      });
      setState(() {});
    }
  }

  // Edit route name
  Future<void> editRouteName(String routeId, String newRouteName) async {
    if (newRouteName.isNotEmpty) {
      await _firestore.collection('routes').doc(routeId).update({
        'route': newRouteName,
      });
      setState(() {});
    }
  }

  // Add stop to a trip
  void addStopToRoute(
      String routeId, String tripId, String stopName, String timing, String coordinates) async {
    if (stopName.isNotEmpty && timing.isNotEmpty && coordinates.isNotEmpty) {
      try {
        await _firestore.collection('routes').doc(routeId).update({
          'trips.$tripId': FieldValue.arrayUnion([
            {'stop': stopName, 'timing': timing, 'coordinates': coordinates}
          ])
        });
        await updatePolyline(routeId); // Update the polyline
      } catch (e) {
        print('Error adding stop: $e');
      }
      setState(() {});
    }
  }

  // Delete stop
  void deleteStopFromRoute(String routeId, String tripId, Map<String, dynamic> stop) async {
    try {
      await _firestore.collection('routes').doc(routeId).update({
        'trips.$tripId': FieldValue.arrayRemove([stop]),
      });
      await updatePolyline(routeId); // Update the polyline
    } catch (e) {
      print('Error deleting stop: $e');
    }
    setState(() {});
  }

  // Update polyline for a route
  Future<void> updatePolyline(String routeId) async {
    final routeDoc = await _firestore.collection('routes').doc(routeId).get();
    if (routeDoc.exists) {
      final data = routeDoc.data() as Map<String, dynamic>;
      final trips = data['trips'] as Map<String, dynamic>? ?? {};
      List<LatLng> polylinePoints = [];

      for (var trip in trips.values) {
        if (trip is List) {
          for (var stop in trip) {
            final coords = stop['coordinates']?.split(',') ?? [];
            if (coords.length == 2) {
              final lat = double.tryParse(coords[0].trim());
              final lng = double.tryParse(coords[1].trim());
              if (lat != null && lng != null) {
                polylinePoints.add(LatLng(lat, lng));
              }
            }
          }
        }
      }

      if (polylinePoints.isNotEmpty) {
        setState(() {
          polylines[routeId] = Polyline(
            polylineId: PolylineId(routeId),
            points: polylinePoints,
            color: Colors.blue,
            width: 4,
          );
        });
      }
    }
  }

  // Show dialog to add a new route
  Future<void> showAddRouteDialog() async {
    String routeName = '';
    await showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add New Route'),
          content: TextField(
            decoration: const InputDecoration(hintText: 'Route Name'),
            onChanged: (value) => routeName = value,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                if (routeName.isNotEmpty) {
                  addRoute(routeName);
                  Navigator.pop(context);
                }
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  // Show dialog to add a new stop
  Future<void> showAddStopDialog(String routeId, String tripId) async {
    String stopName = '';
    String stopTiming = '';
    String coordinates = '';
    await showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add New Stop'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: const InputDecoration(hintText: 'Stop Name'),
                onChanged: (value) => stopName = value,
              ),
              TextField(
                decoration: const InputDecoration(hintText: 'Timing (e.g., 08:30 AM)'),
                onChanged: (value) => stopTiming = value,
              ),
              TextField(
                decoration: const InputDecoration(
                  hintText: 'Coordinates (e.g., 15.87961854303658, 74.52165434950857)',
                ),
                onChanged: (value) => coordinates = value,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                if (stopName.isNotEmpty && stopTiming.isNotEmpty && coordinates.isNotEmpty) {
                  addStopToRoute(routeId, tripId, stopName, stopTiming, coordinates);
                  Navigator.pop(context);
                }
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Route Management')),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: fetchRoutes(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No routes available.'));
          }

          var routes = snapshot.data!;

          return ListView.builder(
            itemCount: routes.length,
            itemBuilder: (context, index) {
              final route = routes[index];
              final stops = route['trips']?['trip1'] ?? [];

              return Card(
                margin: const EdgeInsets.all(10),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(route['route'], style: const TextStyle(fontSize: 18)),
                        IconButton(
                          onPressed: () =>
                              showAddStopDialog(route['id'], 'trip1'),
                          icon: const Icon(Icons.add),
                        ),
                      ],
                    ),
                    const Divider(),
                    stops.isNotEmpty
                        ? ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: stops.length,
                            itemBuilder: (context, stopIndex) {
                              final stop = stops[stopIndex];
                              return ListTile(
                                title: Text(stop['stop'] ?? 'Unknown Stop'),
                                subtitle: Text(
                                  'Timing: ${stop['timing'] ?? 'Unknown Timing'}\n'
                                  'Coordinates: ${stop['coordinates'] ?? 'Unknown Coordinates'}',
                                ),
                                trailing: IconButton(
                                  icon: const Icon(Icons.delete),
                                  onPressed: () => deleteStopFromRoute(
                                    route['id'],
                                    'trip1',
                                    stop,
                                  ),
                                ),
                              );
                            },
                          )
                        : const Padding(
                            padding: EdgeInsets.all(10),
                            child: Text('No stops added yet.'),
                          ),
                    SizedBox(
                      height: 200,
                      child: GoogleMap(
                        initialCameraPosition: const CameraPosition(
                          target: LatLng(15.87961854303658, 74.52165434950857),
                          zoom: 10,
                        ),
                        onMapCreated: (controller) {
                          _mapController = controller;
                        },
                        polylines: Set<Polyline>.of(
                          polylines.values.where(
                            (polyline) =>
                                polyline.polylineId.value == route['id'],
                          ),
                        ),
                        markers: stops
                            .map((stop) {
                              final coords = stop['coordinates']?.split(',');
                              if (coords?.length == 2) {
                                final lat = double.tryParse(coords![0]);
                                final lng = double.tryParse(coords[1]);
                                if (lat != null && lng != null) {
                                  return Marker(
                                    markerId: MarkerId(stop['stop']),
                                    position: LatLng(lat, lng),
                                  );
                                }
                              }
                              return null;
                            })
                            .whereType<Marker>()
                            .toSet(),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: showAddRouteDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}
