import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../config.dart';
import 'request.screen.dart'; // Import the RequestScreen

class NewSeedRequestScreen extends StatefulWidget {
  @override
  _NewSeedRequestScreenState createState() => _NewSeedRequestScreenState();
}

class _NewSeedRequestScreenState extends State<NewSeedRequestScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _selectedSeed;
  String _description = '';
  XFile? _image;
  final ImagePicker _picker = ImagePicker();
  final List<String> seeds = ['Sili', 'Talong', 'Okra'];
  String? _userId;
  Map<String, dynamic>? _userData;

  @override
  void initState() {
    super.initState();
    _loadUserId();
  }

  Future<void> _loadUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _userId = prefs.getString('userId');
    print("Loaded User ID from SharedPreferences: $_userId");
    
    if (_userId != null) {
      await _fetchUserData();
    } else {
      print("Error: User ID not found in SharedPreferences.");
      _showErrorDialog("User ID not found. Please log in again.");
    }
  }

  Future<void> _fetchUserData() async {
    try {
      final response = await http.get(
        Uri.parse('${Config.apiUrl}/api/users/$_userId'),
      );

      if (response.statusCode == 200) {
        setState(() {
          _userData = jsonDecode(response.body);
        });
        print("User data loaded: $_userData");
      } else {
        print("Failed to load user data. Status code: ${response.statusCode}");
      }
    } catch (error) {
      print("Error fetching user data: $error");
      _showErrorDialog("An error occurred while fetching user data. Please try again.");
    }
  }

  Future<void> _takePhoto() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.camera);
    setState(() {
      _image = pickedFile;
    });
  }

  Future<void> _uploadPhoto() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    setState(() {
      _image = pickedFile;
    });
  }

  Future<void> _submitRequest() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      if (_userId == null) {
        _showErrorDialog('User ID not found. Please log in again.');
        return;
      }

      try {
        final uri = Uri.parse('${Config.apiUrl}/api/seed-requests');
        final request = http.MultipartRequest('POST', uri);

        request.fields['userId'] = _userId!;
        request.fields['seedType'] = _selectedSeed!;
        request.fields['description'] = _description;

        if (_image != null) {
          request.files.add(
            await http.MultipartFile.fromPath('image', _image!.path),
          );
        }

        final response = await request.send();

        if (response.statusCode == 201) {
          print("Request submitted successfully");
          _showSuccessDialog('Your request for $_selectedSeed has been submitted!');
        } else {
          print("Failed to submit request. Status code: ${response.statusCode}");
          _showErrorDialog('Failed to submit request. Please try again.');
        }
      } catch (error) {
        print("Error submitting request: $error");
        _showErrorDialog('An error occurred. Please try again later.');
      }
    }
  }

  void _showSuccessDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Request Submitted'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close dialog
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => RequestScreen()), // Navigate to RequestScreen
              );
            },
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('New Seed Request'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        backgroundColor: Colors.green.shade700,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Text(
                    'Request a Seed',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.green.shade800,
                    ),
                  ),
                ),
                SizedBox(height: 16),
                Divider(color: Colors.green.shade700, thickness: 1),
                SizedBox(height: 16),
                if (_userData != null)
                  Text(
                    'Hello, ${_userData!['username']}!',
                    style: TextStyle(fontSize: 16, color: Colors.green.shade800),
                  ),
                Text(
                  'Please fill out the form below to request a new seed.',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey.shade700,
                  ),
                ),
                SizedBox(height: 20),

                // Dropdown for Seed Selection
                DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    labelText: 'Select Seed',
                    filled: true,
                    fillColor: Colors.grey.shade100,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  value: _selectedSeed,
                  items: seeds.map((String seed) {
                    return DropdownMenuItem<String>(
                      value: seed,
                      child: Text(seed),
                    );
                  }).toList(),
                  onChanged: (newValue) {
                    setState(() {
                      _selectedSeed = newValue;
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please select a seed type';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 20),

                // Description Input
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Description',
                    filled: true,
                    fillColor: Colors.grey.shade100,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  maxLines: 3,
                  onSaved: (value) {
                    _description = value ?? '';
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a description';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 20),

                // Image Upload/Take Photo Buttons
                Text(
                  'Upload Photo',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.green.shade800,
                  ),
                ),
                SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton.icon(
                      onPressed: _uploadPhoto,
                      icon: Icon(Icons.upload),
                      label: Text('Upload'),
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        backgroundColor: Colors.green.shade700,
                        padding: EdgeInsets.symmetric(vertical: 14.0, horizontal: 16.0),
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: _takePhoto,
                      icon: Icon(Icons.camera_alt),
                      label: Text('Camera'),
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        backgroundColor: Colors.green.shade700,
                        padding: EdgeInsets.symmetric(vertical: 14.0, horizontal: 16.0),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20),

                // Display the selected image
                if (_image != null)
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.green.shade700),
                    ),
                    padding: const EdgeInsets.all(8.0),
                    child: Center(
                      child: Image.file(
                        File(_image!.path),
                        height: 200,
                      ),
                    ),
                  ),
                SizedBox(height: 20),
                Divider(color: Colors.green.shade700, thickness: 1),
                SizedBox(height: 20),

                // Submit Button
                Center(
                  child: ElevatedButton(
                    onPressed: _submitRequest,
                    child: Text('Submit Request'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green.shade700,
                      padding: EdgeInsets.symmetric(vertical: 16.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      minimumSize: Size(double.infinity, 50),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
