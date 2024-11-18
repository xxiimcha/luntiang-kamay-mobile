import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../screens/home.screen.dart';
import '../screens/request.screen.dart';
import '../screens/profile.screen.dart';
import '../screens/login.screen.dart'; // Import the login screen

class Sidebar extends StatelessWidget {
  final bool isOpen;
  final Function toggleSidebar;

  const Sidebar({Key? key, required this.isOpen, required this.toggleSidebar})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 250,
      color: Colors.green.shade800,
      child: Column(
        children: [
          // Toggle Button and Header
          Container(
            color: Colors.green.shade900,
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    SizedBox(width: 10),
                    Text(
                      'Luntiang Kamay',
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    ),
                  ],
                ),
                IconButton(
                  icon: Icon(Icons.menu, color: Colors.white),
                  onPressed: () => toggleSidebar(),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              children: [
                _buildSidebarItem(
                  icon: Icons.nature,
                  label: 'Plant Progress',
                  context: context,
                ),
                _buildSidebarItem(
                  icon: Icons.request_page,
                  label: 'Request',
                  context: context,
                ),
                _buildSidebarItem(
                  icon: Icons.person,
                  label: 'Profile',
                  context: context,
                ),
                _buildSidebarItem(
                  icon: Icons.logout,
                  label: 'Logout',
                  context: context,
                ),
              ],
            ),
          ),
          // Sidebar Footer with Profile
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundImage: NetworkImage(
                      'https://via.placeholder.com/150'), // Placeholder image
                  radius: 20,
                ),
                SizedBox(width: 10),
                Text(
                  'Paul',
                  style: TextStyle(color: Colors.white),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebarItem({
    required IconData icon,
    required String label,
    required BuildContext context,
  }) {
    return Container(
      child: ListTile(
        leading: Icon(icon, color: Colors.white),
        title: Text(
          label,
          style: TextStyle(color: Colors.white),
        ),
        onTap: () {
          if (label == 'Plant Progress') {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => HomeScreen()),
            );
          } else if (label == 'Request') {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => RequestScreen()),
            );
          } else if (label == 'Profile') {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ProfileScreen()),
            );
          } else if (label == 'Logout') {
            _showLogoutDialog(context);
          }
        },
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Logout'),
          content: Text('Are you sure you want to logout?'),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
            ),
            TextButton(
              child: Text('Logout'),
              onPressed: () async {
                Navigator.of(context).pop(); // Close the dialog
                await _logout(context); // Call logout function
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _logout(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear(); // Clear all saved data in SharedPreferences
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => LoginScreen()),
      (Route<dynamic> route) => false,
    ); // Navigate to login screen and clear all previous routes
  }
}
