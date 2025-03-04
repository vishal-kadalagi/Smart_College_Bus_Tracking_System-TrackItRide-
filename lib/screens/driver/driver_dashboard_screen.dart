import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../shared/theme.dart'; // Import custom AppTheme colors
import 'driver_profile_screen.dart'; // Profile screen
import 'driver_view_feedback_screen.dart'; // Feedback screen
import 'driver_route_overview_screen.dart'; // Route overview screen

class DriverDashboardScreen extends StatefulWidget {
  const DriverDashboardScreen({super.key});

  @override
  State<DriverDashboardScreen> createState() => _DriverDashboardScreenState();
}

class _DriverDashboardScreenState extends State<DriverDashboardScreen> {
  int _selectedIndex = 0;
  late Future<Map<String, dynamic>> driverAssignment;
  String? driverEmail = FirebaseAuth.instance.currentUser?.email;

  Future<Map<String, dynamic>> fetchDriverAssignment(String email) async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('assignments')
          .where('driverEmail', isEqualTo: email)
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        return snapshot.docs.first.data();
      }
      return {};
    } catch (e) {
      print("Error: $e");
      return {};
    }
  }

  @override
  void initState() {
    super.initState();
    if (driverEmail != null) {
      driverAssignment = fetchDriverAssignment(driverEmail!);
    }
  }

  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);
  }

  Future<void> _logout() async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushNamedAndRemoveUntil(context, '/driver_login', (_) => false);
  }

  @override
  Widget build(BuildContext context) {
    if (driverEmail == null) {
      return const Center(child: Text("Error: Driver email not found"));
    }

    return FutureBuilder<Map<String, dynamic>>(
      future: driverAssignment,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        if (snapshot.hasError) {
          return Scaffold(body: Center(child: Text('Error: ${snapshot.error}')));
        }
        final data = snapshot.data ?? {};

        final List<Widget> widgetOptions = [
          DriverHomePageContent(
            key: const PageStorageKey('DriverHomePageContent'),
            busNumber: data['busNumber'] ?? '',
            routeName: data['routeName'] ?? '',
          ),
          DriverRouteOverviewScreen(
            driverEmail: driverEmail!,
            busNumber: data['busNumber'] ?? '',
            routeName: data['routeName'] ?? '',
            busId: data['busId'] ?? '',
            routeId: data['routeId'] ?? '',
          ),
          const DriverProfileScreen(),
          const DriverViewFeedbackScreen(),
        ];

        return Scaffold(
          appBar: AppBar(
            title: const Text("Driver Dashboard"),
            backgroundColor: AppTheme.primaryColor,
            actions: [
              IconButton(
                icon: const Icon(Icons.logout),
                onPressed: _logout,
              ),
            ],
          ),
          body: IndexedStack(
            index: _selectedIndex,
            children: widgetOptions,
          ),
          bottomNavigationBar: BottomNavigationBar(
            items: const [
              BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
              BottomNavigationBarItem(icon: Icon(Icons.directions_bus), label: 'Route'),
              BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
              BottomNavigationBarItem(icon: Icon(Icons.feedback), label: 'Feedback'),
            ],
            currentIndex: _selectedIndex,
            selectedItemColor: Colors.white,
            unselectedItemColor: Colors.white70,
            backgroundColor: AppTheme.primaryColor,
            onTap: _onItemTapped,
            type: BottomNavigationBarType.fixed,
          ),
        );
      },
    );
  }
}

class DriverHomePageContent extends StatefulWidget {
  final String busNumber;
  final String routeName;

  const DriverHomePageContent({required this.busNumber, required this.routeName, super.key});

  @override
  _DriverHomePageContentState createState() => _DriverHomePageContentState();
}

class _DriverHomePageContentState extends State<DriverHomePageContent> {
  bool _isTracking = false;
  Position? _currentLocation;
  GoogleMapController? _mapController;
  Timer? _locationUpdateTimer;
  final Set<Polyline> _polylines = {};
  final Set<Marker> _markers = {};
  List<LatLng> routeCoordinates = [];
  List<LatLng> traveledCoordinates = [];

  Future<void> _getRoutePolyline() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('routes')
          .where('route', isEqualTo: widget.routeName)
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        final routeData = snapshot.docs.first.data();
        List<LatLng> coordinates = [];
        routeData['trips'].forEach((trip, stops) {
          stops.forEach((stop) {
            final coords = stop['coordinates'].split(', ');
            coordinates.add(LatLng(double.parse(coords[0]), double.parse(coords[1])));

            // Add stop markers
            _markers.add(Marker(
              markerId: MarkerId(stop['stop'] ?? 'Unknown Stop'),
              position: LatLng(double.parse(coords[0]), double.parse(coords[1])),
              icon: BitmapDescriptor.defaultMarker, // Default marker for stops
              infoWindow: InfoWindow(
                title: stop['stop'],
                snippet: "Stop Location",
              ),
            ));
          });
        });

        setState(() {
          routeCoordinates = coordinates;
          _polylines.add(Polyline(
            polylineId: const PolylineId('remainingPolyline'),
            points: routeCoordinates,
            color: Colors.blue,
            width: 5,
          ));
        });
      }
    } catch (e) {
      print("Error fetching route polyline: $e");
    }
  }

  Future<void> _startTracking() async {
    var permissionStatus = await Permission.location.request();
    if (!permissionStatus.isGranted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Location permission denied!')));
      return;
    }

    setState(() {
      _isTracking = true;
    });

    _locationUpdateTimer = Timer.periodic(const Duration(seconds: 2), (_) async {
      Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      final LatLng currentLatLng = LatLng(position.latitude, position.longitude);

      traveledCoordinates.add(currentLatLng);

      List<LatLng> remainingCoordinates = routeCoordinates.where((point) {
        return !traveledCoordinates.contains(point);
      }).toList();

      await FirebaseFirestore.instance.collection('driver_locations').add({
        'driverEmail': FirebaseAuth.instance.currentUser?.email,
        'latitude': position.latitude,
        'longitude': position.longitude,
        'timestamp': FieldValue.serverTimestamp(),
      });

      setState(() {
        _currentLocation = position;

        _markers.removeWhere((marker) => marker.markerId.value == 'driverLocation');
        _markers.add(
          Marker(
            markerId: const MarkerId('driverLocation'),
            position: currentLatLng,
            icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue), // Blue marker for driver
            infoWindow: InfoWindow(
              title: "Driver's Location",
              snippet: "Lat: ${currentLatLng.latitude}, Lng: ${currentLatLng.longitude}",
            ),
          ),
        );

        _polylines.clear();
        _polylines.add(Polyline(
          polylineId: const PolylineId('traveledPolyline'),
          points: traveledCoordinates,
          color: Colors.green,
          width: 5,
        ));
        _polylines.add(Polyline(
          polylineId: const PolylineId('remainingPolyline'),
          points: remainingCoordinates,
          color: Colors.blue,
          width: 5,
        ));
      });

      if (_mapController != null) {
        _mapController!.animateCamera(
          CameraUpdate.newLatLng(currentLatLng),
        );
      }
    });
  }

  Future<void> _stopTracking() async {
    _locationUpdateTimer?.cancel();
    setState(() {
      _isTracking = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Trip stopped.')));
  }

  @override
  void dispose() {
    _locationUpdateTimer?.cancel();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _getRoutePolyline();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Welcome!", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              Text("Bus Number: ${widget.busNumber}"),
              const SizedBox(height: 10),
              Text("Route Name: ${widget.routeName}"),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: _isTracking ? null : _startTracking,
                    style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryColor),
                    child: const Text('Start Trip'),
                  ),
                  ElevatedButton(
                    onPressed: _isTracking ? _stopTracking : null,
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                    child: const Text('Stop Trip'),
                  ),
                ],
              ),
            ],
          ),
        ),
        Expanded(
          child: GoogleMap(
            initialCameraPosition: CameraPosition(
              target: _currentLocation != null
                  ? LatLng(_currentLocation!.latitude, _currentLocation!.longitude)
                  : const LatLng(0, 0),
              zoom: 14,
            ),
            onMapCreated: (controller) => _mapController = controller,
            polylines: _polylines,
            markers: _markers,
          ),
        ),
      ],
    );
  }
}
