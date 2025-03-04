import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class StudentSearchScreen extends StatefulWidget {
  const StudentSearchScreen({super.key});

  @override
  _StudentSearchScreenState createState() => _StudentSearchScreenState();
}

class _StudentSearchScreenState extends State<StudentSearchScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String query = "";
  List<Map<String, dynamic>> routes = [];
  List<bool> _expanded = []; // List to track expansion states

  @override
  void initState() {
    super.initState();
    fetchRoutes();
  }

  // Fetching all routes from Firestore
  Future<void> fetchRoutes() async {
    try {
      QuerySnapshot routeSnapshot = await _firestore.collection('routes').get();
      setState(() {
        routes = routeSnapshot.docs.map((doc) {
          final data = doc.data() as Map<String, dynamic>;
          return {
            'id': doc.id,
            'route': data['route'] ?? 'Unnamed Route',
            'trips': {
              'trip1': data['trips']?['trip1'] ?? [],
              'trip2': data['trips']?['trip2'] ?? [],
            },
          };
        }).toList();

        // Sort routes by route name
        routes.sort((a, b) => a['route'].compareTo(b['route']));

        // Initialize expanded states based on number of routes
        _expanded = List<bool>.filled(routes.length, false);
      });
    } catch (e) {
      debugPrint("Error fetching routes: $e");
      setState(() {
        routes = [];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredRoutes = routes.where((route) {
      return route["route"].toLowerCase().contains(query.toLowerCase()) ||
          (route["trips"]['trip1'] as List).any((stop) =>
              (stop["stop"] ?? '').toLowerCase().contains(query.toLowerCase())) ||
          (route["trips"]['trip2'] as List).any((stop) =>
              (stop["stop"] ?? '').toLowerCase().contains(query.toLowerCase()));
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Search Bus Routes"),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: const InputDecoration(
                hintText: "Search for a route or stop...",
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() {
                  query = value;
                });
              },
            ),
          ),
          Expanded(
            child: filteredRoutes.isEmpty
                ? const Center(child: Text("No routes found"))
                : ListView.builder(
                    itemCount: filteredRoutes.length,
                    itemBuilder: (context, routeIndex) {
                      final route = filteredRoutes[routeIndex];
                      return Card(
                        margin: const EdgeInsets.all(10),
                        child: ExpansionTile(
                          initiallyExpanded: _expanded[routeIndex],
                          onExpansionChanged: (bool expanded) {
                            setState(() {
                              _expanded[routeIndex] = expanded;
                            });
                          },
                          title: Text(
                            route["route"],
                            style: TextStyle(
                              fontSize: 18.0,
                              fontWeight: FontWeight.bold,
                              color: query.isNotEmpty &&
                                      route["route"]
                                          .toLowerCase()
                                          .contains(query.toLowerCase())
                                  ? Colors.red
                                  : Colors.black,
                            ),
                          ),
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Trip 1',
                                      style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold)),
                                  const SizedBox(height: 8),
                                  for (var stop in route['trips']['trip1'])
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Text(
                                            stop['stop'] ?? 'Unknown Stop',
                                            style: TextStyle(
                                              color: query.isNotEmpty &&
                                                      (stop['stop'] ?? '')
                                                          .toLowerCase()
                                                          .contains(query
                                                              .toLowerCase())
                                                  ? Colors.red
                                                  : Colors.black,
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                          child: Text(
                                            stop['timing'] ?? 'N/A',
                                          ),
                                        ),
                                      ],
                                    ),
                                  const SizedBox(height: 16),
                                  const Text('Trip 2',
                                      style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold)),
                                  const SizedBox(height: 8),
                                  for (var stop in route['trips']['trip2'])
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Text(
                                            stop['stop'] ?? 'Unknown Stop',
                                            style: TextStyle(
                                              color: query.isNotEmpty &&
                                                      (stop['stop'] ?? '')
                                                          .toLowerCase()
                                                          .contains(query
                                                              .toLowerCase())
                                                  ? Colors.red
                                                  : Colors.black,
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                          child: Text(
                                            stop['timing'] ?? 'N/A',
                                          ),
                                        ),
                                      ],
                                    ),
                                ],
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
    );
  }
}
