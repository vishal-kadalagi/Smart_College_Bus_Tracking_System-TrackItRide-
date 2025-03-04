import 'package:flutter/material.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  // Method to handle logout
  void _logout(BuildContext context) {
    // Logic for logging out, e.g., clearing tokens or user data
    Navigator.pushReplacementNamed(context, '/admin_login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _logout(context),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            // Card 1: Admin Manage Buses
            Card(
              margin: const EdgeInsets.symmetric(vertical: 8),
              child: ListTile(
                title: const Text('Manage Buses'),
                leading: const Icon(Icons.directions_bus),
                onTap: () {
                  Navigator.pushNamed(context, '/admin_manage_buses');
                },
              ),
            ),
            
            // Card 2: Admin Manage Drivers
            Card(
              margin: const EdgeInsets.symmetric(vertical: 8),
              child: ListTile(
                title: const Text('Manage Drivers'),
                leading: const Icon(Icons.person),
                onTap: () {
                  Navigator.pushNamed(context, '/admin_manage_drivers');
                },
              ),
            ),

            // Card 3: Admin Route Management
            Card(
              margin: const EdgeInsets.symmetric(vertical: 8),
              child: ListTile(
                title: const Text('Route Management'),
                leading: const Icon(Icons.route),
                onTap: () {
                  Navigator.pushNamed(context, '/admin_route_management');
                },
              ),
            ),
            
            // Card 4: Admin Analytics
            Card(
              margin: const EdgeInsets.symmetric(vertical: 8),
              child: ListTile(
                title: const Text('Analytics'),
                leading: const Icon(Icons.analytics),
                onTap: () {
                  Navigator.pushNamed(context, '/admin_analytics');
                },
              ),
            ),
            
            // Card 5: Bus & Route Assignment
            Card(
              margin: const EdgeInsets.symmetric(vertical: 8),
              child: ListTile(
                title: const Text('Bus & Route Assignment'),
                subtitle: const Text('Assign buses and routes to drivers'),
                leading: const Icon(Icons.assignment),
                onTap: () {
                  Navigator.pushNamed(context, '/assign_bus_route');
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
