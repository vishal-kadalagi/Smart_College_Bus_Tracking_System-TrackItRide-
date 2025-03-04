import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class StudentRoutesScreen extends StatefulWidget {
  const StudentRoutesScreen({super.key});

  @override
  _StudentRoutesScreenState createState() => _StudentRoutesScreenState();
}

class _StudentRoutesScreenState extends State<StudentRoutesScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late Future<List<Map<String, dynamic>>> routes;

  @override
  void initState() {
    super.initState();
    routes = fetchRoutes();
  }

  Future<List<Map<String, dynamic>>> fetchRoutes() async {
    QuerySnapshot routeSnapshot = await _firestore.collection('routes').get();

    List<Map<String, dynamic>> fetchedRoutes = routeSnapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      return {
        'id': doc.id,
        'route': data['route'] ?? 'Unnamed Route',
        'trips': data['trips'] ?? {},
      };
    }).toList();

    fetchedRoutes.sort((a, b) => a['route'].compareTo(b['route']));
    return fetchedRoutes;
  }

  // Function to parse coordinates from a comma-separated string into LatLng
  List<LatLng> parseCoordinates(String coordinates) {
    List<String> coords = coordinates.split(',').map((e) => e.trim()).toList();
    return coords.length >= 2
        ? [LatLng(double.parse(coords[0]), double.parse(coords[1]))]
        : [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Student Routes'),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: routes,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No routes available.'));
          }

          var fetchedRoutes = snapshot.data!;

          return ListView.builder(
            itemCount: fetchedRoutes.length,
            itemBuilder: (context, index) {
              final route = fetchedRoutes[index];
              List<LatLng> polylineCoordinates = [];

              // Parse coordinates for all trips
              route['trips'].forEach((tripKey, tripData) {
                for (var stop in tripData) {
                  // Parse the coordinates string for each stop
                  var coords = stop['coordinates'];
                  polylineCoordinates.addAll(parseCoordinates(coords));
                }
              });

              return Card(
                margin: const EdgeInsets.all(10),
                child: ExpansionTile(
                  title: Text(route['route'], style: const TextStyle(fontSize: 18)),
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Trip 1', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                for (var stop in route['trips']['trip1'] ?? [])
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(child: Text(stop['stop'], style: const TextStyle(fontSize: 14))),
                                      Expanded(child: Text(stop['timing'], style: const TextStyle(fontSize: 14))),
                                    ],
                                  ),
                              ],
                            ),
                          ),
                          const VerticalDivider(width: 20),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Trip 2', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                for (var stop in route['trips']['trip2'] ?? [])
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(child: Text(stop['stop'], style: const TextStyle(fontSize: 14))),
                                      Expanded(child: Text(stop['timing'], style: const TextStyle(fontSize: 14))),
                                    ],
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 300,
                      child: GoogleMap(
                        initialCameraPosition: CameraPosition(
                          target: polylineCoordinates.isNotEmpty
                              ? polylineCoordinates.first
                              : const LatLng(0, 0),
                          zoom: 12,
                        ),
                        polylines: {
                          if (polylineCoordinates.isNotEmpty)
                            Polyline(
                              polylineId: PolylineId(route['id']),
                              points: polylineCoordinates,
                              color: Colors.blue,
                              width: 4,
                            ),
                        },
                        markers: Set<Marker>.from(
                          polylineCoordinates.map((latLng) => Marker(
                            markerId: MarkerId(latLng.toString()),
                            position: latLng,
                          )),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
