import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../widgets/sidebar.dart';
import 'request_seed.screen.dart';
import 'request_details.screen.dart';
import '../config.dart';

class RequestScreen extends StatefulWidget {
  @override
  _RequestScreenState createState() => _RequestScreenState();
}

class _RequestScreenState extends State<RequestScreen> {
  List<Map<String, dynamic>> requests = [];
  bool _isSidebarOpen = false;
  String? _userId;

  @override
  void initState() {
    super.initState();
    _loadUserId();
  }

  Future<void> _loadUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _userId = prefs.getString('userId');
    if (_userId != null) {
      await _fetchRequests();
    } else {
      print("Error: User ID not found in SharedPreferences.");
    }
  }

  Future<void> _fetchRequests() async {
    try {
      final response = await http.get(
        Uri.parse('${Config.apiUrl}/api/seed-requests?userId=$_userId'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> responseData = jsonDecode(response.body);
        setState(() {
          requests = responseData.map((request) {
            return {
              'id': request['_id'],
              'name': request['seedType'],
              'status': _capitalize(request['status']),
              'description': request['description'],
              'createdAt': request['createdAt'],
              'imagePath': request['imagePath'],
            };
          }).toList();
        });
        print("Seed requests loaded: $requests");
      } else {
        print("Failed to load seed requests. Status code: ${response.statusCode}");
      }
    } catch (error) {
      print("Error fetching seed requests: $error");
    }
  }

  String _capitalize(String? text) {
    if (text == null || text.isEmpty) return '';
    return text[0].toUpperCase() + text.substring(1);
  }

  void _toggleSidebar() {
    setState(() {
      _isSidebarOpen = !_isSidebarOpen;
    });
  }

  void _requestNewSeed() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => NewSeedRequestScreen(),
      ),
    ).then((_) => _fetchRequests());
  }

  void _viewRequestDetails(Map<String, dynamic> request) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RequestDetailsScreen(request: request),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Scaffold(
              appBar: AppBar(
                title: Text(
                  'Seed Requests',
                  style: TextStyle(color: Colors.white),
                ),
                leading: IconButton(
                  icon: Icon(Icons.menu, color: Colors.white),
                  onPressed: _toggleSidebar,
                ),
                backgroundColor: Colors.green.shade700,
                elevation: 0,
              ),
              body: Container(
                color: Colors.green.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Pending Seed Requests',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.green.shade800,
                        ),
                      ),
                      SizedBox(height: 16),
                      Expanded(
                        child: requests.isEmpty
                            ? Center(
                                child: Text(
                                  "No pending requests found.",
                                  style: TextStyle(
                                    color: Colors.grey.shade600,
                                    fontSize: 16,
                                  ),
                                ),
                              )
                            : ListView.builder(
                                itemCount: requests.length,
                                itemBuilder: (context, index) {
                                  final request = requests[index];
                                  return Card(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    margin: EdgeInsets.symmetric(vertical: 8.0),
                                    child: InkWell(
                                      onTap: () => _viewRequestDetails(request),
                                      child: ListTile(
                                        contentPadding: EdgeInsets.all(16.0),
                                        title: Text(
                                          request['name'] ?? 'Unknown Seed',
                                          style: TextStyle(
                                            fontWeight: FontWeight.w600,
                                            color: Colors.green.shade900,
                                          ),
                                        ),
                                        subtitle: Text(
                                          'Status: ${request['status']}',
                                          style: TextStyle(
                                            color: request['status'].toLowerCase() == 'pending'
                                                ? Colors.orange.shade700
                                                : Colors.green.shade600,
                                          ),
                                        ),
                                        trailing: Icon(
                                          request['status'].toLowerCase() == 'pending'
                                              ? Icons.pending
                                              : Icons.check_circle,
                                          color: request['status'].toLowerCase() == 'pending'
                                              ? Colors.orange.shade700
                                              : Colors.green.shade600,
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                      ),
                      SizedBox(height: 20),
                      Center(
                        child: ElevatedButton.icon(
                          onPressed: _requestNewSeed,
                          icon: Icon(Icons.add),
                          label: Text(
                            'Request New Seed',
                            style: TextStyle(color: Colors.white),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green.shade700,
                            padding: EdgeInsets.symmetric(vertical: 14.0, horizontal: 24.0),
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
