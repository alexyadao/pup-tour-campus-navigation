import 'package:flutter/material.dart';
import 'package:puptourapp/routes/app_routes.dart';
import 'package:puptourapp/screens/guest/navigation_drawer_guest.dart';
import 'package:puptourapp/widgets/app_header.dart';
import 'package:puptourapp/widgets/app_footer.dart';
import 'package:puptourapp/widgets/customer_service.dart';
import 'dart:ui'; // For BackdropFilter

class CampusMapGuestScreen extends StatefulWidget {
  const CampusMapGuestScreen({super.key});

  static const String routeName = '/campus_map_guest';

  @override
  State<CampusMapGuestScreen> createState() => _CampusMapGuestScreenState();
}

class _CampusMapGuestScreenState extends State<CampusMapGuestScreen> {
  // --- Style Constants ---
  static const Color pupRedDark = Color(0xFF850909);
  static const Color whiteText = Colors.white;
  static const Color greyText = Colors.grey;

  static const double horizontalPadding = 40.0;

  // 🔑 KEY CHANGE: State to manage the user's login status
  bool _isLoggedIn = false; // Set to false initially to show the lock/blur

  // --- Helper Widget: Small Building Card (UNCHANGED) ---
  Widget _buildSmallBuildingCard({
    required String imagePath,
    required String title,
    required String subtitle,
    VoidCallback? onTap,
  }) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        color: whiteText,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.7),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(15),
          onTap: onTap ?? () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Tapped on $title!')),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(15),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.asset(
                    imagePath,
                    width: 80,
                    height: 80,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: TextStyle(color: greyText, fontSize: 13),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // --- Helper Widget: The Locked Map Card ---
  Widget _buildLockedMapCard(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 40),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFe6dada),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 6,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      // 🔑 The Stack enables layering the map content, the blur, and the button
      child: Stack(
        alignment: Alignment.center,
        children: [
          // --- Base Layer: Original Map Card Content ---
          Column(
            children: [
              Image.asset(
                'assets/icons/mapicon.png',
                width: 200,
                height: 200,
                color: pupRedDark,
              ),
              const Text(
                "Interactive Campus Map",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                "Navigate through PUP campus with our interactive map feature",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: greyText,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: 200,
                height: 30,
                child: ElevatedButton(
                  // Button is only active if logged in
                  onPressed: _isLoggedIn
                      ? () {
                    Navigator.pushNamed(context, AppRoutes.interactiveMap);
                  }
                      : null, // Disabled when logged out
                  style: ElevatedButton.styleFrom(
                    backgroundColor: pupRedDark,
                    foregroundColor: whiteText,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    "Load Map",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),

          // --- Overlay Layer: Blur and Login Button ---
          if (!_isLoggedIn)
            Positioned.fill(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: BackdropFilter(
                  // Apply the blur
                  filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
                  child: Container(
                    // Semi-transparent overlay
                    color: Colors.black.withOpacity(0.3),
                    alignment: Alignment.center,
                    child: SizedBox(
                      width: 220, // Slightly wider button
                      height: 50,
                      child: ElevatedButton(
                        onPressed: () {
                          // TODO: Navigate to the login screen
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Redirecting to Login Screen...')),
                          );
                          // Example: Navigator.pushNamed(context, AppRoutes.login);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: pupRedDark,
                          foregroundColor: whiteText,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          elevation: 5,
                        ),
                        child: const Text(
                          "Log-in to View Map",
                          textAlign: TextAlign.center,
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
            ),
        ],
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
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.zero,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // --- Page Title ---
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: horizontalPadding),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 20.0),
                            const Text(
                              "Campus Map",
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "Interactive map of PUP Manila Campus",
                              style: TextStyle(
                                color: greyText,
                                fontSize: 15,
                              ),
                            ),
                            const SizedBox(height: 20),
                          ],
                        ),
                      ),

                      // --- Interactive Campus Map Card (Now uses the helper function) ---
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: horizontalPadding),
                        child: _buildLockedMapCard(context),
                      ),

                      // --- Small Building Cards ---
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: horizontalPadding),
                        child: Column(
                          children: [
                            _buildSmallBuildingCard(
                              imagePath: "assets/images/main_building.png",
                              title: "Main Building",
                              subtitle: "Administrative and academic offices",
                            ),
                            _buildSmallBuildingCard(
                              imagePath: "assets/images/charlie.png",
                              title: "Charlie Del Rosario Building",
                              subtitle: "Hosting offices like the Student Services",
                            ),
                            _buildSmallBuildingCard(
                              imagePath: "assets/images/library.png",
                              title: "Library",
                              subtitle: "Academic resources and study areas",
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 100),

                      // --- Footer ---
                      const AppFooter(),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // -------------------- MOVABLE CUSTOMER SERVICE BUTTON --------------------
          // The DraggableCustomerServiceButton needs to be Positioned inside the Stack
          // if it wasn't already configured that way in its own widget.
          // Assuming it's configured for floating behavior.
          const DraggableCustomerServiceButton(iconSize: 50),
        ],
      ),
    );
  }
}