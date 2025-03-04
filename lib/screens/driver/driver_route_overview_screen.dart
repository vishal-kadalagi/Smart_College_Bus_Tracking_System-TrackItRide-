import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../shared/theme.dart'; // Custom AppTheme colors

class DriverRouteOverviewScreen extends StatefulWidget {
  final String driverEmail;
  final String busNumber;
  final String routeName;
  final String busId;
  final String routeId;

  const DriverRouteOverviewScreen({
    required this.driverEmail,
    required this.busNumber,
    required this.routeName,
    required this.busId,
    required this.routeId,
    super.key,
  });

  @override
  _DriverRouteOverviewScreenState createState() =>
      _DriverRouteOverviewScreenState();
}

class _DriverRouteOverviewScreenState
    extends State<DriverRouteOverviewScreen> {
  late Future<Map<String, dynamic>> routeTrips;

  // Fetch route trips details based on routeName
  Future<Map<String, dynamic>> fetchRouteTrips() async {
    try {
      // Query the 'assignments' collection for the routeName
      final snapshot = await FirebaseFirestore.instance
          .collection('assignments')
          .where('routeName', isEqualTo: widget.routeName)
          .get();

      print("Query executed: ${snapshot.docs.length} documents found.");

      if (snapshot.docs.isNotEmpty) {
        // Fetch trips from the first document in the result
        final data = snapshot.docs.first.data();
        final trips = data['trips'] ?? [];
        print("Trips data: $trips"); // Debugging print statement
        return {'trips': trips};
      } else {
        print("No trips found for the given routeName.");
        return {'trips': []}; // Return empty if no trips are found
      }
    } catch (e) {
      print("Error fetching route trips: $e");
      return {'trips': []};
    }
  }

  @override
  void initState() {
    super.initState();
    routeTrips = fetchRouteTrips();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: routeTrips,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        if (snapshot.hasError) {
          return Scaffold(body: Center(child: Text('Error: ${snapshot.error}')));
        }

        final data = snapshot.data ?? {};

        // Separate trips into Trip 1 and Trip 2
        final trip1 = data['trips']
            ?.where((trip) => trip['tripType'] == 'Trip 1')
            .toList() ?? [];
        final trip2 = data['trips']
            ?.where((trip) => trip['tripType'] == 'Trip 2')
            .toList() ?? [];

        return Scaffold(
          appBar: AppBar(
            title: const Text("Route Overview"),
            backgroundColor: AppTheme.primaryColor,
          ),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Route Details",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                Text("Bus Number: ${widget.busNumber}"),
                const SizedBox(height: 10),
                Text("Route Name: ${widget.routeName}"),
                const SizedBox(height: 20),
                const Text(
                  "Stop and Timings",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                Expanded(
                  child: Row(
                    children: [
                      // Trip 1 - Left side
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Trip 1",
                              style: TextStyle(
                                  fontSize: 22, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 10),
                            Expanded(
                              child: ListView.builder(
                                itemCount: trip1.length,
                                itemBuilder: (context, index) {
                                  final trip = trip1[index];
                                  return Container(
                                    padding: const EdgeInsets.all(12.0),
                                    margin: const EdgeInsets.only(bottom: 10),
                                    decoration: BoxDecoration(
                                      color: Colors.blue.shade50,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                          color: Colors.blue.shade200, width: 1.5),
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Stop: ${trip['stop']}',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          'Timing: ${trip['timing']}',
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.grey.shade700,
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 20),
                      // Trip 2 - Right side
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Trip 2",
                              style: TextStyle(
                                  fontSize: 22, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 10),
                            Expanded(
                              child: ListView.builder(
                                itemCount: trip2.length,
                                itemBuilder: (context, index) {
                                  final trip = trip2[index];
                                  return Container(
                                    padding: const EdgeInsets.all(12.0),
                                    margin: const EdgeInsets.only(bottom: 10),
                                    decoration: BoxDecoration(
                                      color: Colors.green.shade50,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                          color: Colors.green.shade200, width: 1.5),
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Stop: ${trip['stop']}',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          'Timing: ${trip['timing']}',
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.grey.shade700,
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Center(
                  child: ElevatedButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Route Started!')),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                      padding:
                          const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                    ),
                    child: const Text(
                      'Start Route',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
