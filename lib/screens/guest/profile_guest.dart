import 'package:flutter/material.dart';
import 'package:puptourapp/routes/app_routes.dart';
import 'package:puptourapp/screens/guest/navigation_drawer_guest.dart'; // Drawer Import
import 'package:puptourapp/widgets/app_header.dart'; // Header Import
import 'package:puptourapp/widgets/app_footer.dart'; // Footer Import
import 'package:puptourapp/widgets/customer_service.dart'; // Movable button
import 'dart:ui'; // Required for ImageFilter.blur

class GuestProfileScreen extends StatefulWidget {
  const GuestProfileScreen({super.key});

  static const String routeName = '/guestProfile';

  @override
  State<GuestProfileScreen> createState() => _GuestProfileScreenState();
}

class _GuestProfileScreenState extends State<GuestProfileScreen> {
  // --- Style Constants ---
  static const Color pupRedDark = Color(0xFF850909);
  static const Color whiteText = Colors.white;
  static const Color greyText = Colors.grey;
  static const Color statLabelText = Color(0xFF9E9E9E);
  static const Color statCardBackground = Color(0xFFF7F7F7);

  static const double horizontalPadding = 20.0;

  // 🔑 Helper function to show the login required modal
  void _showLoginRequiredModal(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Access Restricted'),
          content: const Text("Log in first to have an account."),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                // 1. Close the dialog
                Navigator.of(context).pop();
                // 2. Redirect to the Login Page
                Navigator.of(context).pushReplacementNamed(AppRoutes.login);
              },
              child: Text(
                'Okay',
                style: TextStyle(color: pupRedDark, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );
  }

  // --- Helper Widget: Profile Info Card (UNCHANGED) ---
  Widget _buildProfileInfoCard({
    required String label,
    required String value,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: statLabelText,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            color: Colors.black,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  // --- Helper Widget: Statistic Row Item (UNCHANGED) ---
  Widget _buildStatRowItem({
    required String label,
    required String value,
    Color valueColor = pupRedDark,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: statCardBackground,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: statLabelText,
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: valueColor,
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  // --- Helper Widget: Action Button (UNCHANGED) ---
  Widget _buildActionButton({
    required String text,
    required VoidCallback onPressed,
    Color backgroundColor = pupRedDark,
    Color textColor = whiteText,
    bool isOutline = false,
  }) {
    return Container(
      width: double.infinity,
      height: 45,
      margin: const EdgeInsets.only(bottom: 15),
      child: isOutline
          ? OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: backgroundColor, width: 2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          foregroundColor: backgroundColor,
        ),
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      )
          : ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: textColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          elevation: 0,
        ),
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const AppHeader(),
      drawer: const NavigationDrawerGuest(),

      body: Stack(
        children: [
          // -------------------- MAIN CONTENT --------------------
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Page Title and Subtitle (Kept outside the blur/scroll area for clarity)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.only(
                  top: 30,
                  left: horizontalPadding,
                  right: horizontalPadding,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      "Profile",
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      "Manage your account settings",
                      style: TextStyle(
                        color: greyText,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
              ),

              // 🔑 START BLUR AREA: This Expanded section holds the scrollable content
              Expanded(
                child: Stack(
                  children: [
                    // --- Scrollable Profile Content (Base Layer) ---
                    SingleChildScrollView(
                      padding: EdgeInsets.zero,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Main Profile Card Area
                          Padding(
                            padding: const EdgeInsets.all(horizontalPadding),
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: whiteText,
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.2),
                                    spreadRadius: 3,
                                    blurRadius: 8,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Column(
                                children: [
                                  // User Avatar
                                  Container(
                                    width: 80,
                                    height: 80,
                                    decoration: BoxDecoration(
                                      color: pupRedDark,
                                      borderRadius: BorderRadius.circular(40),
                                    ),
                                    alignment: Alignment.center,
                                    child: const Text(
                                      "JD",
                                      style: TextStyle(
                                        color: whiteText,
                                        fontSize: 32,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  const Text(
                                    "Juan Dela Cruz",
                                    style: TextStyle(
                                      color: pupRedDark,
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    "juan.delacruz@pup.edu.ph",
                                    style: TextStyle(
                                      color: greyText,
                                      fontSize: 14,
                                    ),
                                  ),
                                  const SizedBox(height: 20),

                                  // Student ID & Member Since
                                  Container(
                                    padding: const EdgeInsets.all(10),
                                    margin: const EdgeInsets.only(bottom: 10),
                                    decoration: BoxDecoration(
                                      color: statCardBackground,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: _buildProfileInfoCard(
                                            label: "Student ID",
                                            value: "2024-12345-MN-0",
                                          ),
                                        ),
                                        Expanded(
                                          child: _buildProfileInfoCard(
                                            label: "Member Since",
                                            value: "November 2025",
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  const SizedBox(height: 10),

                                  // Statistics
                                  const Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      "Statistics",
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  _buildStatRowItem(
                                    label: "Tours Completed",
                                    value: "3",
                                  ),
                                  _buildStatRowItem(
                                    label: "Saved Locations",
                                    value: "8",
                                  ),
                                  _buildStatRowItem(
                                    label: "Time Spent Exploring",
                                    value: "2.5 hours",
                                  ),
                                  const SizedBox(height: 20),

                                  // Action Buttons (Placeholder/Disabled)
                                  _buildActionButton(
                                    text: "Reset Password",
                                    onPressed: () => _showLoginRequiredModal(context), // Redirects to modal
                                    isOutline: true,
                                  ),
                                  _buildActionButton(
                                    text: "Settings",
                                    onPressed: () => _showLoginRequiredModal(context), // Redirects to modal
                                    isOutline: true,
                                  ),
                                  _buildActionButton(
                                    text: "Sign Out",
                                    onPressed: () => _showLoginRequiredModal(context), // Redirects to modal
                                  ),
                                ],
                              ),
                            ),
                          ),

                          const SizedBox(height: 100),

                          // Footer
                          const AppFooter(),
                        ],
                      ),
                    ),

                    // 🔑 Overlay Layer: Blur and Center Button
                    Positioned.fill(
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
                        child: Container(
                          color: Colors.black.withOpacity(0.1), // Light transparent cover
                          alignment: Alignment.center,
                          child: SizedBox(
                            width: 220,
                            height: 50,
                            child: ElevatedButton(
                              onPressed: () => _showLoginRequiredModal(context),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: pupRedDark,
                                foregroundColor: whiteText,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                elevation: 5,
                              ),
                              child: const Text(
                                "Log-in to View Profile",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // 🔑 END BLUR AREA
            ],
          ),

          // -------------------- MOVABLE CUSTOMER SERVICE BUTTON --------------------
          const DraggableCustomerServiceButton(iconSize: 50),
        ],
      ),
    );
  }
}