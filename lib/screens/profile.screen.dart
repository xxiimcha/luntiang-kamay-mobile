import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../config.dart'; // Import config.dart
import 'package:http/http.dart' as http;
import 'dart:convert';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  String _name = 'Paul';
  String _email = 'paul@example.com';
  String _phone = '123-456-7890';
  XFile? _profileImage;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  Future<void> _loadProfileData() async {
    final prefs = await SharedPreferences.getInstance();

    setState(() {
      _name = prefs.getString('name') ?? _name;
      _email = prefs.getString('email') ?? _email;
      _phone = prefs.getString('phone') ?? _phone;
      final imagePath = prefs.getString('profileImage');
      if (imagePath != null) _profileImage = XFile(imagePath);
    });

    await _fetchUserData();
    _printStoredData(); // Print values to the terminal
  }

  Future<void> _printStoredData() async {
    final prefs = await SharedPreferences.getInstance();
    print('Stored name: ${prefs.getString('name')}');
    print('Stored email: ${prefs.getString('email')}');
    print('Stored phone: ${prefs.getString('phone')}');
    print('Stored profile image path: ${prefs.getString('profileImage')}');
  }

  Future<void> _fetchUserData() async {
    try {
      final response = await http.get(Uri.parse('${Config.apiUrl}/user-profile'));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _name = data['name'] ?? _name;
          _email = data['email'] ?? _email;
          _phone = data['phone'] ?? _phone;
        });
        _saveProfileData();
      } else {
        _showSnackBar("Failed to load user data.");
      }
    } catch (e) {
      print("Error fetching user data: $e");
      _showSnackBar("Error fetching user data. Try again.");
    }
  }

  Future<void> _saveProfileData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('name', _name);
    await prefs.setString('email', _email);
    await prefs.setString('phone', _phone);
    if (_profileImage != null) await prefs.setString('profileImage', _profileImage!.path);
  }

  Future<void> _pickImageFromGallery() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    setState(() => _profileImage = pickedFile);
  }

  Future<void> _takePhoto() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.camera);
    setState(() => _profileImage = pickedFile);
  }

  Future<void> _uploadProfileImage() async {
    if (_profileImage == null) return;

    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('${Config.apiUrl}/upload-profile-image'),
      );
      request.files.add(await http.MultipartFile.fromPath('profileImage', _profileImage!.path));
      final response = await request.send();

      if (response.statusCode == 200) {
        _showSnackBar("Profile image uploaded successfully.");
      } else {
        throw Exception("Failed to upload profile image.");
      }
    } catch (e) {
      print("Error uploading profile image: $e");
      _showSnackBar("Error uploading profile image. Try again.");
    }
  }

  void _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      await _saveProfileData();
      await _uploadProfileImage();

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Profile Updated'),
          content: Text('Your profile information has been updated successfully.'),
          actions: [
            TextButton(onPressed: () => Navigator.of(context).pop(), child: Text('Close')),
          ],
        ),
      );
    }
  }

  void _showImageOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: Icon(Icons.photo_library),
                title: Text('Pick from Gallery'),
                onTap: () {
                  Navigator.of(context).pop();
                  _pickImageFromGallery();
                },
              ),
              ListTile(
                leading: Icon(Icons.camera_alt),
                title: Text('Take a Photo'),
                onTap: () {
                  Navigator.of(context).pop();
                  _takePhoto();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
        backgroundColor: Colors.green.shade700,
        leading: IconButton(icon: Icon(Icons.arrow_back), onPressed: () => Navigator.of(context).pop()),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _buildProfileImage(),
                SizedBox(height: 20),
                _buildTextField('Name', _name, (value) => _name = value ?? '', 'Please enter your name'),
                SizedBox(height: 20),
                _buildTextField('Email', _email, (value) => _email = value ?? '', 'Please enter a valid email address',
                    emailValidation: true),
                SizedBox(height: 20),
                _buildTextField('Phone Number', _phone, (value) => _phone = value ?? '', 'Please enter your phone number'),
                SizedBox(height: 30),
                ElevatedButton(
                  onPressed: _saveProfile,
                  child: Text('Save Profile'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green.shade700,
                    padding: EdgeInsets.symmetric(vertical: 16.0),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    minimumSize: Size(double.infinity, 50),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileImage() {
    return Center(
      child: Stack(
        children: [
          CircleAvatar(
            radius: 60,
            backgroundImage: _profileImage != null
                ? FileImage(File(_profileImage!.path))
                : AssetImage('assets/placeholder.png') as ImageProvider,
            backgroundColor: Colors.grey.shade200,
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: GestureDetector(
              onTap: _showImageOptions,
              child: CircleAvatar(
                radius: 18,
                backgroundColor: Colors.green.shade700,
                child: Icon(Icons.camera_alt, color: Colors.white, size: 18),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(
    String label,
    String initialValue,
    void Function(String?) onSaved,
    String validationMessage, {
    bool emailValidation = false,
  }) {
    return TextFormField(
      initialValue: initialValue,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(),
        filled: true,
        fillColor: Colors.grey.shade100,
      ),
      onSaved: onSaved,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return validationMessage;
        } else if (emailValidation && !RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
          return 'Please enter a valid email address';
        }
        return null;
      },
    );
  }
}
