import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AssignBusRouteScreen extends StatefulWidget {
  const AssignBusRouteScreen({super.key});

  @override
  _AssignBusRouteScreenState createState() => _AssignBusRouteScreenState();
}

class _AssignBusRouteScreenState extends State<AssignBusRouteScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String? selectedBusId;
  String? selectedBusNumber;
  String? selectedNumberPlate;

  String? selectedDriverId;
  String? selectedDriverName;
  String? selectedDriverEmail;

  String? selectedRouteId;
  String? selectedRouteName;

  // List to store trips related to the selected route
  List<Map<String, dynamic>> routeTrips = [];

  bool showDriverAndRouteSelection = false; // Define this variable

  // Store assigned details to be used for filtering
  List<Map<String, dynamic>> assignedDetails = [];

  // Future to load assigned details
  late Future<List<Map<String, dynamic>>> assignedDetailsFuture;

  @override
  void initState() {
    super.initState();
    assignedDetailsFuture = fetchAssignedDetails(); // Initialize the future
  }

  // Fetch assigned details
  Future<List<Map<String, dynamic>>> fetchAssignedDetails() async {
    try {
      final snapshot = await _firestore
          .collection('assignments')
          .orderBy('createdAt', descending: false)
          .get();

      assignedDetails = snapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'id': doc.id,
          'busNumber': data['busNumber'] as String?,
          'numberPlate': data['numberPlate'] as String?,
          'driverName': data['driverName'] as String?,
          'driverEmail': data['driverEmail'] as String?,
          'routeName': data['routeName'] as String?,
        };
      }).toList();

      return assignedDetails;
    } catch (e) {
      print('Error fetching assigned details: $e');
      return [];
    }
  }

  // Fetch buses (not assigned)
  Future<List<Map<String, dynamic>>> fetchBuses() async {
    QuerySnapshot busSnapshot = await _firestore.collection('buses').get();
    List<Map<String, dynamic>> buses = busSnapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      return {
        'id': doc.id,
        'busNumber': data['busNumber'],
        'numberPlate': data['numberPlate'],
      };
    }).toList();

    // Filter out already assigned buses
    buses.removeWhere((bus) => assignedDetails.any((detail) => detail['busNumber'] == bus['busNumber']));

    buses.sort((a, b) => (a['busNumber'] as String).compareTo(b['busNumber'])); // Sort buses by bus number
    return buses;
  }

  // Fetch drivers
  Future<List<Map<String, dynamic>>> fetchDrivers() async {
    QuerySnapshot driverSnapshot = await _firestore.collection('drivers').get();
    List<Map<String, dynamic>> drivers = driverSnapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      return {
        'id': doc.id,
        'name': data['name'],
        'email': data['email'],
      };
    }).toList();

    // Filter out already assigned drivers
    drivers.removeWhere((driver) => assignedDetails.any((detail) => detail['driverEmail'] == driver['email']));

    drivers.sort((a, b) => (a['name'] as String).compareTo(b['name'])); // Sort drivers by name
    return drivers;
  }

  // Fetch routes
  Future<List<Map<String, dynamic>>> fetchRoutes() async {
    QuerySnapshot routeSnapshot = await _firestore.collection('routes').get();
    List<Map<String, dynamic>> routes = routeSnapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      return {
        'id': doc.id,
        'route': data['route'],
        'trips': data['trips'], // Store trips structure directly
      };
    }).toList();

    // Filter out already assigned routes
    routes.removeWhere((route) => assignedDetails.any((detail) => detail['routeName'] == route['route']));

    routes.sort((a, b) => (a['route'] as String).compareTo(b['route'])); // Sort routes alphabetically
    return routes;
  }

   // Fetch trips for a given route name and update UI
   Future<List<Map<String, dynamic>>> fetchRouteTrips(String routeName) async {
     try {
       final snapshot = await _firestore.collection('routes')
           .where('route', isEqualTo: routeName)
           .get();

       if (snapshot.docs.isNotEmpty) {
         final data = snapshot.docs.first.data();
         return [
           ...data['trips']['trip1'].map((stop) => {'stop': stop['stop'], 'timing': stop['timing'], 'tripType': 'Trip 1'}),
           ...data['trips']['trip2'].map((stop) => {'stop': stop['stop'], 'timing': stop['timing'], 'tripType': 'Trip 2'}),
         ];
       } else {
         return [];
       }
     } catch (e) {
       print('Error fetching route trips: $e');
       return [];
     }
   }

   // Add a new assignment
   Future<void> addAssignment() async {
     if (selectedBusId != null &&
         selectedDriverId != null &&
         selectedRouteId != null) {
       try {
         await _firestore.collection('assignments').add({
           'busNumber': selectedBusNumber,
           'numberPlate': selectedNumberPlate,
           'driverName': selectedDriverName,
           'driverEmail': selectedDriverEmail,
           'routeName': selectedRouteName,
           'trips': await fetchRouteTrips(selectedRouteName!), // Fetch trips here
           'createdAt': FieldValue.serverTimestamp(),
         });

         setState(() {
           assignedDetailsFuture = fetchAssignedDetails(); // Refresh the list
           selectedBusId = null;
           selectedDriverId = null;
           selectedRouteId = null;
           routeTrips.clear(); // Clear trips after assignment
         });

         ScaffoldMessenger.of(context).showSnackBar(
           const SnackBar(content: Text('Assignment added successfully')),
         );
       } catch (e) {
         print('Error adding assignment: $e');
         ScaffoldMessenger.of(context).showSnackBar(
           const SnackBar(content: Text('Error adding assignment')),
         );
       }
     } else {
       ScaffoldMessenger.of(context).showSnackBar(
         const SnackBar(content: Text('Please select all fields')),
       );
     }
   }

   // Delete an assignment from Firestore
   Future<void> deleteAssignment(String assignmentId) async {
     try {
       await _firestore.collection('assignments').doc(assignmentId).delete();
       setState(() {
         assignedDetailsFuture = fetchAssignedDetails(); // Refresh the list after deletion
       });
       ScaffoldMessenger.of(context).showSnackBar(
         const SnackBar(content: Text('Assignment deleted successfully')),
       );
     } catch (e) {
       print('Error deleting assignment: $e');
       ScaffoldMessenger.of(context).showSnackBar(
         const SnackBar(content: Text('Error deleting assignment')),
       );
     }
   }

   @override
   Widget build(BuildContext context) {
     final screenWidth = MediaQuery.of(context).size.width; 
     return Scaffold(
       appBar: AppBar(
         title: const Text('Assign Bus, Driver & Route'),
       ),
       body: Center(
         child: SingleChildScrollView(
           padding: const EdgeInsets.all(16.0),
           child: Column(
             crossAxisAlignment: CrossAxisAlignment.center,
             children: <Widget>[
               const Text(
                 'Assigned Details',
                 style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
               ),
               const SizedBox(height: 16),
               FutureBuilder<List<Map<String, dynamic>>>(  
                 future: assignedDetailsFuture,
                 builder: (context, snapshot) {
                   if (snapshot.connectionState == ConnectionState.waiting) {
                     return const CircularProgressIndicator();
                   }
                   if (snapshot.hasError) {
                     return Text('Error: ${snapshot.error}');
                   }

                   final assignedDetails = snapshot.data!;
                   if (assignedDetails.isEmpty) {
                     return const Text('No assignments yet.');
                   }

                   return Card(
                     elevation: 3,
                     child: Container(
                       width: screenWidth * 0.9,
                       padding: const EdgeInsets.all(8.0),
                       child: ListView(
                         shrinkWrap: true,
                         children: assignedDetails.map((detail) {
                           return Column(
                             crossAxisAlignment: CrossAxisAlignment.start,
                             children: [
                               ListTile(
                                 title: RichText(
                                   text: TextSpan(
                                     text: 'Bus: ${detail['busNumber']} (${detail['numberPlate']})',
                                     style: const TextStyle(fontSize: 16),
                                   ),
                                 ),
                                 subtitle: RichText(
                                   text: TextSpan(
                                     text: 'Driver: ${detail['driverName']} - Route: ${detail['routeName']}',
                                     style: const TextStyle(fontSize: 14),
                                   ),
                                 ),
                                 trailing:
                                   IconButton(
                                     icon:
                                       const Icon(Icons.delete),
                                     onPressed:
                                       () => deleteAssignment(detail['id']),
                                   ),
                               ),
                               const Divider(),
                               const Text('Trip Details:', style: TextStyle(fontWeight: FontWeight.bold)),
                               FutureBuilder<List<Map<String, dynamic>>>(
                                 future:
                                   fetchRouteTrips(detail['routeName']),
                                 builder:(context, tripSnapshot){
                                   if(tripSnapshot.connectionState == ConnectionState.waiting){
                                     return const CircularProgressIndicator();
                                   }
                                   if(tripSnapshot.hasError){
                                     return Text('Error fetching trips');
                                   }

                                   final trips =
                                       tripSnapshot.data ?? [];
                                   if(trips.isEmpty){
                                     return const Text('No trips scheduled for this route.');
                                   }

                                   List<Map<String, dynamic>> trip1Stops =
                                       trips.where((trip) => trip.containsKey('tripType') && trip['tripType'] == 'Trip 1').toList();
                                   List<Map<String, dynamic>> trip2Stops =
                                       trips.where((trip) => trip.containsKey('tripType') && trip['tripType'] == 'Trip 2').toList();

                                   return Row(
                                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                     children:[
                                       Expanded(child:
                                         Column(
                                           crossAxisAlignment:
                                               CrossAxisAlignment.start,
                                           children:[
                                             const Text("Trip 1", style:
                                               TextStyle(fontWeight:
                                               FontWeight.bold)),
                                             DataTable(columns:[
                                               DataColumn(label :const Text('Stop')),
                                               DataColumn(label :const Text('Timing')),
                                             ],
                                             rows:[
                                               for(var trip in trip1Stops)
                                                 DataRow(cells:[
                                                   DataCell(Text(trip['stop'])),
                                                   DataCell(Text(trip['timing'])),
                                                 ]),
                                             ],
                                             )
                                           ],
                                         ),
                                       ),
                                       Expanded(child:
                                         Column(
                                           crossAxisAlignment:
                                               CrossAxisAlignment.start,
                                           children:[
                                             const Text("Trip 2", style:
                                               TextStyle(fontWeight:
                                               FontWeight.bold)),
                                             DataTable(columns:[
                                               DataColumn(label :const Text('Stop')),
                                               DataColumn(label :const Text('Timing')),
                                             ],
                                             rows:[
                                               for(var trip in trip2Stops)
                                                 DataRow(cells:[
                                                   DataCell(Text(trip['stop'])),
                                                   DataCell(Text(trip['timing'])),
                                                 ]),
                                             ],
                                             )
                                           ],
                                         ),
                                       ),
                                     ],
                                   );
                                 },
                               ),
                             ],
                           );
                         }).toList(),
                       ),
                     ),
                   );
                 },
               ),
               const SizedBox(height: 32),
               const Text(
                 'Step 1: Select Bus',
                 style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
               ),
               FutureBuilder<List<Map<String, dynamic>>>(  
                 future:
                   fetchBuses(),
                 builder:(context,busSnapshot){
                   if(busSnapshot.connectionState == ConnectionState.waiting){
                     return const CircularProgressIndicator();
                   }
                   if(busSnapshot.hasError){
                     return Text('Error:${busSnapshot.error}');
                   }
                   final buses= busSnapshot.data ?? [];
                   return DropdownButtonFormField<String>(
                     decoration :const InputDecoration(
                       labelText:'Select Bus',
                       border :OutlineInputBorder(),
                     ),
                     value :selectedBusId,
                     onChanged :(newValue){
                       setState((){ 
                         selectedBusId=newValue; 
                         selectedBusNumber=buses.firstWhere((bus)=>bus ['id']==newValue)['busNumber'];
                         selectedNumberPlate=buses.firstWhere((bus)=>bus ['id']==newValue)['numberPlate'];
                         showDriverAndRouteSelection=true;  
                       });
                     },
                     items:buses.map((bus){
                       return DropdownMenuItem<String>(
                         value :bus ['id'], 
                         child :Text('${bus ['busNumber']} (${bus ['numberPlate']})'),
                       );
                     }).toList(),
                   );
                 },
               ),

              if(showDriverAndRouteSelection)...[
                const SizedBox(height :16), 
                const Text( 
                  'Step2 : Select Driver', 
                  style :TextStyle(fontSize :16,fontWeight :FontWeight.bold), 
                ), 
                FutureBuilder<List<Map<String,dynamic>>>(  
                  future :fetchDrivers(), 
                  builder:(context ,driverSnapshot){ 
                    if(driverSnapshot.connectionState == ConnectionState.waiting){ 
                      return const CircularProgressIndicator(); 
                    } 
                    if(driverSnapshot.hasError){ 
                      return Text ('Error:${driverSnapshot.error}'); 
                    } 
                    final drivers= driverSnapshot.data ?? []; 
                    return DropdownButtonFormField <String>(
                      decoration :const InputDecoration( 
                        labelText :'Select Driver', 
                        border :OutlineInputBorder(), 
                      ), 
                      value:selectedDriverId , 
                      onChanged:(newValue){ 
                        setState((){ 
                          selectedDriverId=newValue; 
                          selectedDriverName=drivers.firstWhere((driver)=>driver ['id']==newValue)['name']; 
                          selectedDriverEmail=drivers.firstWhere((driver)=>driver ['id']==newValue)['email']; 
                        }); 
                      }, 
                      items :drivers.map((driver){ 
                        return DropdownMenuItem <String>(
                          value :driver ['id'], 
                          child :Text(driver ['name']), 
                        ); 
                      }).toList(), 
                    ); 
                  }, 
                ), 

                const SizedBox(height :16), 

                const Text( 
                  'Step3 : Select Route', 
                  style :TextStyle(fontSize :16,fontWeight :FontWeight.bold), 
                ), 

                FutureBuilder<List<Map <String,dynamic>>>(  
                  future :fetchRoutes(),  
                  builder:(context ,routeSnapshot){  
                    if(routeSnapshot.connectionState == ConnectionState.waiting){  
                      return const CircularProgressIndicator();  
                    }  
                    if(routeSnapshot.hasError){  
                      return Text ('Error:${routeSnapshot.error}');  
                    }  
                    final routes= routeSnapshot.data ?? [];  
                    return DropdownButtonFormField <String>(  
                      decoration :const InputDecoration(  
                        labelText :'Select Route',  
                        border :OutlineInputBorder(),  
                      ),  
                      value:selectedRouteId ,  
                      onChanged:(newValue){  
                        setState((){   
                          selectedRouteId=newValue;   
                          selectedRouteName=routes.firstWhere((route)=>route ['id']==newValue)['route'];   
                        });   
                        fetchRouteTrips(selectedRouteName!);   
                      },   
                      items :routes.map((route){   
                        return DropdownMenuItem <String>(   
                          value :route ['id'],   
                          child :Text(route ['route']),   
                        );   
                      }).toList(),   
                    );   
                  },   
                ),   

                ElevatedButton(    
                  onPressed :addAssignment ,    
                  child :const Text ('Assign Bus , Driver , and Route'),    
                ),    
              ],    
            ],    
          ),    
        ),    
      ),    
     );    
   }    

}