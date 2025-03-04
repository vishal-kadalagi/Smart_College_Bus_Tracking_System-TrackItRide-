import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

class StudentLocationScreen extends StatefulWidget {
  const StudentLocationScreen({super.key});

  @override
  _StudentLocationScreenState createState() => _StudentLocationScreenState();
}

class _StudentLocationScreenState extends State<StudentLocationScreen> {
  late Future<List<Map<String, dynamic>>> assignedBuses;
  GoogleMapController? _mapController;
  final Set<Polyline> _polylines = {};
  final Set<Marker> _markers = {};
  final Location _location = Location();
  StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>? _driverLocationSubscription;
  StreamSubscription<LocationData>? _userLocationSubscription;
  LatLng? _currentDriverLocation;
  LatLng? _currentUserLocation;

  @override
  void initState() {
    super.initState();
    assignedBuses = fetchAssignedBuses();
    _requestLocationPermission();
    _startUserLocationTracking();
  }

  @override
  void dispose() {
    _driverLocationSubscription?.cancel();
    _userLocationSubscription?.cancel();
    super.dispose();
  }

  /// Request location permissions from the user
  Future<void> _requestLocationPermission() async {
    PermissionStatus permissionStatus = await _location.hasPermission();
    if (permissionStatus == PermissionStatus.denied) {
      permissionStatus = await _location.requestPermission();
      if (permissionStatus != PermissionStatus.granted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Location permission is required.')),
        );
        return;
      }
    }

    final isServiceEnabled = await _location.serviceEnabled();
    if (!isServiceEnabled) {
      final serviceEnabled = await _location.requestService();
      if (!serviceEnabled) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Location services must be enabled.')),
        );
        return;
      }
    }
  }

  /// Start tracking the user's live location
  void _startUserLocationTracking() {
    _userLocationSubscription = _location.onLocationChanged.listen((locationData) {
      if (locationData.latitude != null && locationData.longitude != null) {
        final userPosition = LatLng(locationData.latitude!, locationData.longitude!);

        setState(() {
          _currentUserLocation = userPosition;

          // Remove the previous marker and add a new marker for the user's location
          _markers.removeWhere((marker) => marker.markerId.value == 'userLocation');
          _markers.add(
            Marker(
              markerId: const MarkerId('userLocation'),
              position: userPosition,
              icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
              infoWindow: const InfoWindow(title: 'Driver Live Location'),
            ),
          );
        });

        // Move the map camera to focus on the user's location
        _mapController?.animateCamera(CameraUpdate.newLatLng(userPosition));
      }
    });
  }

  Future<List<Map<String, dynamic>>> fetchAssignedBuses() async {
    try {
      final snapshot = await FirebaseFirestore.instance.collection('assignments').get();
      if (snapshot.docs.isNotEmpty) {
        List<Map<String, dynamic>> busList = [];
        for (var doc in snapshot.docs) {
          final data = doc.data();
          final busNumber = data['busNumber'] ?? 'Unknown Bus';
          final routeName = data['routeName'] ?? 'Unknown Route';
          final driverEmail = data['driverEmail'] ?? 'Unknown Email';

          final routeSnapshot = await FirebaseFirestore.instance
              .collection('routes')
              .where('route', isEqualTo: routeName)
              .get();

          if (routeSnapshot.docs.isNotEmpty) {
            final routeData = routeSnapshot.docs.first.data();
            final trips = routeData['trips'] ?? {};

            busList.add({
              'busNumber': busNumber,
              'routeName': routeName,
              'driverEmail': driverEmail,
              'trips': trips,
            });
          }
        }
        return busList;
      }
      return [];
    } catch (e) {
      print("Error fetching assignments: $e");
      return [];
    }
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
  }

  /// Start tracking the live location of a driver from the Firestore database
  void _startDriverLocationTracking(String driverEmail) {
    // Cancel any existing location subscription
    _driverLocationSubscription?.cancel();

    // Clear old markers and polylines before adding new ones
    setState(() {
      _polylines.clear();
      _markers.removeWhere((marker) => marker.markerId.value == 'driverLocation');
      _currentDriverLocation = null;
    });

    // Listen to the driver's live location updates
    _driverLocationSubscription = FirebaseFirestore.instance
        .collection('driver_locations')
        .doc(driverEmail)
        .snapshots()
        .listen((snapshot) {
      if (snapshot.exists) {
        final data = snapshot.data();
        if (data != null) {
          final lat = data['latitude'] ?? 0.0;
          final lng = data['longitude'] ?? 0.0;

          final driverPosition = LatLng(lat, lng);

          setState(() {
            _currentDriverLocation = driverPosition;

            // Remove the previous marker and add a new marker for the driver
            _markers.add(
              Marker(
                markerId: const MarkerId('driverLocation'),
                position: driverPosition,
                icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
                infoWindow: const InfoWindow(title: 'Driver Location'),
              ),
            );
          });

          // Move the map camera to focus on the driver's location
          _mapController?.animateCamera(CameraUpdate.newLatLng(driverPosition));
        }
      }
    });
  }

  void _fetchRouteDetails(String routeName) async {
    // Clear old markers and polylines before fetching new route details
    setState(() {
      _polylines.clear();
      _markers.removeWhere((marker) => marker.markerId.value != 'userLocation' && marker.markerId.value != 'driverLocation');
    });

    final routeSnapshot = await FirebaseFirestore.instance
        .collection('routes')
        .where('route', isEqualTo: routeName)
        .get();

    if (routeSnapshot.docs.isNotEmpty) {
      final routeData = routeSnapshot.docs.first.data();
      final trips = routeData['trips'] ?? {};
      List<LatLng> polylinePoints = [];

      trips.forEach((_, stops) {
        if (stops is List<dynamic>) {
          for (var stop in stops) {
            if (stop is Map<String, dynamic>) {
              final coordinates = stop['coordinates'] ?? '';
              final splitCoordinates = coordinates.split(',');
              if (splitCoordinates.length == 2) {
                final lat = double.tryParse(splitCoordinates[0].trim()) ?? 0.0;
                final lng = double.tryParse(splitCoordinates[1].trim()) ?? 0.0;
                polylinePoints.add(LatLng(lat, lng));

                _markers.add(
                  Marker(
                    markerId: MarkerId(stop['stop'] ?? 'Unknown Stop'),
                    position: LatLng(lat, lng),
                    infoWindow: InfoWindow(
                      title: stop['stop'] ?? 'Unknown Stop',
                      snippet: 'Time: ${stop['timing'] ?? 'Unknown Time'}',
                    ),
                  ),
                );
              }
            }
          }
        }
      });

      setState(() {
        _polylines.add(Polyline(
          polylineId: PolylineId(routeName),
          points: polylinePoints,
          color: Colors.blue,
          width: 4,
        ));
      });

      if (polylinePoints.isNotEmpty) {
        _mapController?.animateCamera(CameraUpdate.newLatLngBounds(
          LatLngBounds(
            southwest: polylinePoints.reduce((a, b) => LatLng(
              a.latitude < b.latitude ? a.latitude : b.latitude,
              a.longitude < b.longitude ? a.longitude : b.longitude,
            )),
            northeast: polylinePoints.reduce((a, b) => LatLng(
              a.latitude > b.latitude ? a.latitude : b.latitude,
              a.longitude > b.longitude ? a.longitude : b.longitude,
            )),
          ),
          50,
        ));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: assignedBuses,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        if (snapshot.hasError) {
          return Scaffold(body: Center(child: Text('Error: ${snapshot.error}')));
        }

        final buses = snapshot.data ?? [];
        if (buses.isEmpty) {
          return Scaffold(
            appBar: AppBar(
              title: const Text("Bus Assignments"),
              backgroundColor: Colors.blue,
            ),
            body: const Center(child: Text("No assigned buses available")),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text("Buses Live Location"),
            backgroundColor: Colors.blue,
          ),
          body: Column(
            children: [
              Expanded(
                flex: 2,
                child: ListView.builder(
                  itemCount: buses.length,
                  itemBuilder: (context, index) {
                    final bus = buses[index];

                    return Card(
                      margin: const EdgeInsets.all(8.0),
                      child: ListTile(
                        title: Text('Bus Number: ${bus['busNumber']}'),
                        subtitle: Text('Route: ${bus['routeName']}'),
                        trailing: ElevatedButton(
                          onPressed: () {
                            _startDriverLocationTracking(bus['driverEmail']);
                            _fetchRouteDetails(bus['routeName']);
                          },
                          child: const Text("Live Location"),
                        ),
                      ),
                    );
                  },
                ),
              ),
              Expanded(
                flex: 3,
                child: GoogleMap(
                  onMapCreated: _onMapCreated,
                  initialCameraPosition: const CameraPosition(
                    target: LatLng(0.0, 0.0),
                    zoom: 5,
                  ),
                  markers: _markers,
                  polylines: _polylines,
                  myLocationEnabled: true,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
