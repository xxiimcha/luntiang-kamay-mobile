import 'package:flutter/material.dart';
import '../widgets/sidebar.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isSidebarOpen = false;

  // Sample data for plants and their progress levels
  final List<Map<String, dynamic>> plants = [
    {'name': 'Tomato Plant', 'progress': 0.7},
    {'name': 'Basil Plant', 'progress': 0.4},
    {'name': 'Lettuce Plant', 'progress': 0.9},
    {'name': 'Carrot Plant', 'progress': 0.6},
  ];

  void _toggleSidebar() {
    setState(() {
      _isSidebarOpen = !_isSidebarOpen;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Main Content with App Bar
          Positioned.fill(
            child: Scaffold(
              appBar: AppBar(
                title: Text('Dashboard'),
                leading: IconButton(
                  icon: Icon(Icons.menu),
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
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 20),
                    Expanded(
                      child: ListView.builder(
                        itemCount: plants.length,
                        itemBuilder: (context, index) {
                          final plant = plants[index];
                          return Card(
                            margin: EdgeInsets.symmetric(vertical: 8.0),
                            child: ListTile(
                              title: Text(plant['name']),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(height: 8),
                                  LinearProgressIndicator(
                                    value: plant['progress'],
                                    backgroundColor: Colors.green.shade200,
                                    color: Colors.green.shade700,
                                  ),
                                  SizedBox(height: 8),
                                  Text('${(plant['progress'] * 100).toStringAsFixed(0)}% Progress'),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Sidebar Overlay
          AnimatedPositioned(
            duration: Duration(milliseconds: 300),
            left: _isSidebarOpen ? 0 : -250, // Slide in/out based on sidebar state
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
