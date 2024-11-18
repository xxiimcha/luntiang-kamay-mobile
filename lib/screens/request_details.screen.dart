import 'package:flutter/material.dart';
import '../config.dart';

class RequestDetailsScreen extends StatelessWidget {
  final Map<String, dynamic> request;

  RequestDetailsScreen({required this.request});

  String formatDate(String? dateStr) {
    if (dateStr == null) return 'Unknown';
    try {
      final DateTime date = DateTime.parse(dateStr);
      return '${date.day}-${date.month}-${date.year}';
    } catch (e) {
      return 'Unknown';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Request Details',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.green.shade700,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              request['name'] ?? 'Unknown Seed',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.green.shade900,
              ),
            ),
            SizedBox(height: 16),
            Text(
              'Status: ${request['status']}',
              style: TextStyle(
                fontSize: 18,
                color: request['status'].toLowerCase() == 'pending'
                    ? Colors.orange.shade700
                    : Colors.green.shade600,
              ),
            ),
            SizedBox(height: 16),
            Text(
              'Description:',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.green.shade800,
              ),
            ),
            Text(
              request['description'] ?? 'No description provided.',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 16),
            Text(
              'Created At: ${formatDate(request['createdAt'])}',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade700,
              ),
            ),
            SizedBox(height: 20),
            Center(
              child: request['imagePath'] != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(12.0),
                      child: Image.network(
                        '${Config.apiUrl}/${request['imagePath']}',
                        height: 200,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Center(
                            child: Text(
                              'Failed to load image.',
                              style: TextStyle(color: Colors.grey.shade600),
                            ),
                          );
                        },
                      ),
                    )
                  : Container(
                      height: 200,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey),
                      ),
                      child: Center(
                        child: Text(
                          'No image available.',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
