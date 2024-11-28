import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../InvestorPages/InvestorProfile/TermsScreen.dart';
import '../../main.dart';
import '../FarmerHome/farmerHome.dart';
import '../FarmerHome/projects_list.dart';
import 'CustomerServiceScreen.dart';
import 'FAQscreen.dart';
import 'InfoScreen.dart';

class Farmerprofile extends StatefulWidget {
  const Farmerprofile({super.key});

  @override
  _FarmerprofileState createState() => _FarmerprofileState();
}

class _FarmerprofileState extends State<Farmerprofile> {
  int _selectedTabIndex = 0; // Default tab is "حسابي"
  String userName = ''; // To store the user's name

  @override
  void initState() {
    super.initState();
    _fetchUserName(); // Fetch user's name when the page loads
  }

  // Function to fetch user's name from Firestore
  Future<void> _fetchUserName() async {
    try {
      final userId = FirebaseAuth.instance.currentUser!.uid;
      final userDoc = await FirebaseFirestore.instance.collection('users').doc(userId).get();
      setState(() {
        userName = userDoc['name'] ?? 'اسم المستخدم'; // Default if name is not found
      });
    } catch (e) {
      print('Failed to fetch user name: $e');
    }
  }

  // Function to delete user account and related data
  Future<void> _deleteUserAccount() async {
    try {
      final userId = FirebaseAuth.instance.currentUser!.uid;

      // Delete user document
      await FirebaseFirestore.instance.collection('users').doc(userId).delete();

      // Delete investments related to the user
      final investments = await FirebaseFirestore.instance.collection('investments').where('userId', isEqualTo: userId).get();
      for (var doc in investments.docs) {
        await doc.reference.delete();
      }

      // Delete investment opportunities related to the user
      final investmentOpportunities = await FirebaseFirestore.instance.collection('investmentOpportunities').where('userId', isEqualTo: userId).get();
      for (var doc in investmentOpportunities.docs) {
        await doc.reference.delete();
      }

      // Delete the user from Firebase Auth
      await FirebaseAuth.instance.currentUser!.delete();

      // Redirect to start page or login page
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => StartPage()),
            (route) => false,
      );
    } catch (e) {
      print('Error deleting account: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('فشل في حذف الحساب، حاول مرة أخرى')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAF9),
      body: Stack(
        children: [
          _buildAppBar(), // Profile page header with user info
          Padding(
            padding: const EdgeInsets.only(top: 250, left: 20, right: 20),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  _buildProfileSettings(), // Profile settings options
                  const SizedBox(height: 20),
                  _buildLogoutButton(), // Logout button
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomNavigationBar(), // Bottom navigation bar
    );
  }

  // App bar with profile icon and user name
  Widget _buildAppBar() {
    return ClipRRect(
      borderRadius: const BorderRadius.only(
        bottomLeft: Radius.circular(20),
        bottomRight: Radius.circular(20),
      ),
      child: Container(
        height: 320,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF345E50), Color(0xFF49785E), Color(0xFFA8B475)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Stack(
          children: [
            Align(
              alignment: Alignment.center,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.white,
                    child: Icon(
                      Icons.person,
                      size: 70,
                      color: Color(0xFF345E50),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    userName, // Display fetched user name here
                    style: const TextStyle(
                      fontSize: 24,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Markazi Text',
                    ),
                  ),
                  const SizedBox(height: 4),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // List of profile settings items
  Widget _buildProfileSettings() {
    return Container(
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(40),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            spreadRadius: 5,
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          buildSettingsItem(
            context,
            "تغيير اللغة",
            Icons.language,
                () => _showLanguageChangeDialog(context),
          ),
          buildSettingsItem(
            context,
            "تواصل معنا",
            Icons.contact_support,
                () =>
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const CustomerServiceScreen()),
                ),
          ),
          buildSettingsItem(
            context,
            "الأسئلة الشائعة",
            Icons.security,
                () =>
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const FAQscreen()),
                ),
          ),
          buildSettingsItem(
            context,
            "الشروط والأحكام",
            Icons.rule,
                () =>
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const TermsScreen()),
                ),
          ),
          buildSettingsItem(
            context,
            "عن إمداد",
            Icons.info,
                () =>
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const InfoScreen()),
                ),
          ),
          buildSettingsItem(
            context,
            "حذف الحساب",
            Icons.delete,
                () => _showDeleteAccountConfirmationDialog(context),
          ),
        ],
      ),
    );
  }

  // Single setting item with icon, title, and onTap action
  Widget buildSettingsItem(BuildContext context, String title, IconData icon,
      VoidCallback onTap) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(vertical: 5.0),
      leading: Icon(icon, color: const Color(0xFF4B7960)),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          color: Color(0xFF4B7960),
          fontFamily: 'Markazi Text',
        ),
      ),
      trailing: const Icon(Icons.arrow_forward_ios, color: Color(0xFF4B7960)),
      onTap: onTap,
    );
  }

  // Logout button with gradient background
  Widget _buildLogoutButton() {
    return Container(
      width: 150,
      height: 40,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF4B7960),
            Color(0xFF728F66),
            Color(0xFFA2AA6D),
          ],
        ),
        borderRadius: BorderRadius.circular(50),
      ),
      child: ElevatedButton(
        onPressed: () => _showLogoutConfirmationDialog(context),
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 1),
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(50),
          ),
        ),
        child: const Text(
          "تسجيل الخروج",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontFamily: 'Markazi Text',
          ),
        ),
      ),
    );
  }

  // Bottom navigation bar
  BottomNavigationBar _buildBottomNavigationBar() {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      backgroundColor: Colors.white,
      selectedItemColor: Colors.green.shade800,
      unselectedItemColor: Colors.grey,
      showSelectedLabels: true,
      showUnselectedLabels: true,
      currentIndex: _selectedTabIndex,
      onTap: (index) {
        setState(() {
          _selectedTabIndex = index;
        });

        // Navigate to different screens based on selected index
        if (index == 0) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const Farmerprofile()),
                (route) => false,
          );
        } else if (index == 1) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const ProjectList()),
                (route) => false,
          );
        } else if (index == 2) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const FarmerHomePage()),
                (route) => false,
          );
        }
      },
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: 'حسابي',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.nature),
          label: 'مشاريعي الزراعية',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'الرئيسية',
        ),
      ],
    );
  }

  // Language change dialog
  void _showLanguageChangeDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "تغيير اللغة",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF4B7960),
                  ),
                ),
                const Divider(),
                ListTile(
                  title: const Text("العربية", style: TextStyle(fontSize: 18)),
                  onTap: () {
                    Navigator.of(context).pop();
                  },
                ),
                const Divider(),
                ListTile(
                  title: const Text("English", style: TextStyle(fontSize: 18)),
                  onTap: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Logout confirmation dialog
  void _showLogoutConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "هل أنت متأكد من تسجيل الخروج؟",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF4B7960),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildConfirmationButton(context, "الرجوع"),
                    _buildConfirmationButton(
                        context, "تسجيل الخروج", isLogout: true),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Delete account confirmation dialog
  void _showDeleteAccountConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "هل أنت متأكد من حذف الحساب؟",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF4B7960),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildConfirmationButton(context, "الرجوع"),
                    _buildConfirmationButton(
                        context, "حذف الحساب", isDeleteAccount: true),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Helper method to build confirmation buttons for dialogs
  Widget _buildConfirmationButton(BuildContext context, String text,
      {bool isLogout = false, bool isDeleteAccount = false}) {
    return Container(
      width: 120, // Set a fixed width for the button
      height: 40, // Set a fixed height for the button
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF4B7960),
            Color(0xFF728F66),
            Color(0xFFA2AA6D),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: TextButton(
        onPressed: () {
          Navigator.of(context).pop(); // Close the dialog
          if (isDeleteAccount) {
            _deleteUserAccount(); // Call the delete account method
          } else if (isLogout) {
            // Handle logout logic if necessary
          }
        },
        style: TextButton.styleFrom(
          padding: EdgeInsets.zero, // Remove padding to respect fixed height
        ),
        child: Text(
          text,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14, // Adjust font size as needed
          ),
        ),
      ),
    );
  }
}