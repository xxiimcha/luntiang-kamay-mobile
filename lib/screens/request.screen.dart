import 'package:flutter/material.dart';
import '../widgets/sidebar.dart'; // Make sure this import points to your Sidebar widget file
import 'request_seed.screen.dart';

class RequestScreen extends StatefulWidget {
  @override
  _RequestScreenState createState() => _RequestScreenState();
}

class _RequestScreenState extends State<RequestScreen> {
  // Sample data for pending requests
  final List<Map<String, String>> requests = [
    {'id': '1', 'name': 'Tomato Seeds', 'status': 'Pending'},
    {'id': '2', 'name': 'Lettuce Seeds', 'status': 'Pending'},
    {'id': '3', 'name': 'Carrot Seeds', 'status': 'Pending'},
  ];

  bool _isSidebarOpen = false;

  void _toggleSidebar() {
    setState(() {
      _isSidebarOpen = !_isSidebarOpen;
    });
  }

 void _requestNewSeed() {
  // Navigate to the NewSeedRequestScreen
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => NewSeedRequestScreen(),
    ),
  );
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
                title: Text('Request Seeds'),
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
                      'Pending Seed Requests',
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 20),
                    Expanded(
                      child: ListView.builder(
                        itemCount: requests.length,
                        itemBuilder: (context, index) {
                          final request = requests[index];
                          return Card(
                            margin: EdgeInsets.symmetric(vertical: 8.0),
                            child: ListTile(
                              title: Text(request['name']!),
                              subtitle: Text('Status: ${request['status']}'),
                              trailing: Icon(Icons.pending, color: Colors.orange),
                            ),
                          );
                        },
                      ),
                    ),
                    SizedBox(height: 20),
                    ElevatedButton.icon(
                      onPressed: _requestNewSeed,
                      icon: Icon(Icons.add),
                      label: Text('Request New Seed'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green.shade700,
                        padding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 20.0),
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
