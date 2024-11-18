import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../widgets/sidebar.dart';
import 'plant_details.screen.dart';
import '../config.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isSidebarOpen = false;
  String? _userId;

  // List to store plants dynamically added by the user
  final List<Map<String, dynamic>> plants = [];

  // List of plant options for dropdown
  final List<String> plantOptions = ['Sili', 'Talong', 'Okra'];

  @override
  void initState() {
    super.initState();
    _loadUserId().then((_) {
      if (_userId != null) {
        _fetchPlants(); // Fetch plants only if _userId is successfully loaded
      } else {
        print('User ID still null after _loadUserId.');
      }
    });
  }

  // Load the user ID from SharedPreferences
  Future<void> _loadUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _userId = prefs.getString('userId');
    });

    if (_userId == null) {
      print('User ID not found in SharedPreferences.');
    } else {
      print('Loaded userId: $_userId');
    }
  }

  // Fetch existing plants from the database
  Future<void> _fetchPlants() async {
    if (_userId == null) {
      print('User ID not found, cannot fetch plants.');
      return;
    }

    print('Fetching plants for user ID: $_userId');

print('API Endpoint: ${Config.apiUrl}/api/plants/user-plants/$_userId');
    try {
      final response = await http.get(
        Uri.parse('${Config.apiUrl}/api/plants/user-plants/$_userId'), // Pass userId in the URL
        headers: {'Content-Type': 'application/json'},
      );

      print('API Response status: ${response.statusCode}');
      print('API Response body: ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> responseData = jsonDecode(response.body);

        // Parsing the plant data from the response
        setState(() {
          plants.clear();
          plants.addAll(responseData.map((data) => {
                'id': data['_id'], // Use '_id' from MongoDB as the unique ID
                'name': data['plantName'], // Use 'plantName' for display
                'progress': data['progress'], // Use 'progress' for progress tracking
              }));
        });

        print('Plants fetched successfully: $plants');
      } else {
        print("Failed to load plants. Status code: ${response.statusCode}");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load plants. Please try again later.')),
        );
      }
    } catch (error) {
      print("Error fetching plants: $error");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred while fetching plants.')),
      );
    }
  }

  void _toggleSidebar() {
    setState(() {
      _isSidebarOpen = !_isSidebarOpen;
    });
    print('Sidebar toggled: $_isSidebarOpen');
  }

  void _addNewPlant() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        String? selectedPlant;

        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          backgroundColor: Colors.green.shade50,
          title: Text(
            'Add New Plant',
            style: TextStyle(color: Colors.green.shade800, fontWeight: FontWeight.bold),
          ),
          content: DropdownButtonFormField<String>(
            decoration: InputDecoration(
              labelText: 'Select Plant',
              labelStyle: TextStyle(color: Colors.green.shade800),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.green),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.green.shade700),
              ),
            ),
            items: plantOptions.map((String plant) {
              return DropdownMenuItem<String>(
                value: plant,
                child: Text(plant),
              );
            }).toList(),
            onChanged: (value) {
              selectedPlant = value;
              print('Selected plant: $selectedPlant');
            },
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                print('Add plant dialog canceled.');
              },
              child: Text('Cancel', style: TextStyle(color: Colors.white)),
              style: TextButton.styleFrom(
                backgroundColor: Colors.green.shade700,
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                if (selectedPlant != null && _userId != null) {
                  print('Attempting to save plant $selectedPlant for user $_userId');
                  await _savePlantToDatabase(selectedPlant!);
                  Navigator.of(context).pop();
                } else {
                  print('Add plant failed: Plant not selected or user not logged in');
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Please select a plant and ensure you are logged in')),
                  );
                }
              },
              child: Text('Add Plant', style: TextStyle(color: Colors.white)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green.shade700,
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _savePlantToDatabase(String plantName) async {
    print('Saving plant $plantName to database...');
    try {
      final response = await http.post(
        Uri.parse('${Config.apiUrl}/api/plants/add'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'userId': _userId,
          'plantName': plantName,
          'progress': 0.0, // Default progress
        }),
      );

      if (response.statusCode == 201) {
        setState(() {
          plants.add({'name': plantName, 'progress': 0.0});
        });
        print('Plant added successfully to database: $plantName');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Plant added successfully!')),
        );
      } else {
        print('Failed to add plant to database. Status code: ${response.statusCode}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to add plant.')),
        );
      }
    } catch (error) {
      print('Error saving plant to database: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred. Please try again.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Scaffold(
              appBar: AppBar(
                title: Text('Dashboard', style: TextStyle(color: Colors.white)),
                backgroundColor: Colors.green.shade700,
                leading: IconButton(
                  icon: Icon(Icons.menu, color: Colors.white),
                  onPressed: _toggleSidebar,
                ),
              ),
              body: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Plant Progress Dashboard',
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.green.shade800),
                    ),
                    SizedBox(height: 20),
                    Expanded(
                      child: plants.isEmpty
                          ? Center(child: Text("No plants added yet.", style: TextStyle(color: Colors.grey.shade600)))
                          : ListView.builder(
                              itemCount: plants.length,
                              itemBuilder: (context, index) {
                                final plant = plants[index];
                                return GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => PlantDetailsScreen(plant: plant),
                                      ),
                                    );
                                  },
                                  child: Card(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    margin: EdgeInsets.symmetric(vertical: 8.0),
                                    child: ListTile(
                                      title: Text(
                                        plant['name'],
                                        style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green.shade900),
                                      ),
                                      subtitle: Text(
                                        'Progress: ${(plant['progress'] * 100).toStringAsFixed(0)}%',
                                        style: TextStyle(color: Colors.green.shade700),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                    ),
                    SizedBox(height: 16),
                    Center(
                      child: ElevatedButton.icon(
                        onPressed: _addNewPlant,
                        icon: Icon(Icons.add, color: Colors.white),
                        label: Text('Add New Plant', style: TextStyle(color: Colors.white)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green.shade700,
                          padding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 20.0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          AnimatedPositioned(
            duration: Duration(milliseconds: 300),
            left: _isSidebarOpen ? 0 : -250,
            top: 0,
            bottom: 0,
            child: Sidebar(
              isOpen: _isSidebarOpen,
              toggleSidebar: _toggleSidebar,
            ),
          ),
        ],
      ),
    );
  }
}
