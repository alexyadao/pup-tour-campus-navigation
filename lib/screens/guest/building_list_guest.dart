import 'package:flutter/material.dart';
import 'package:puptourapp/routes/app_routes.dart';
import 'package:puptourapp/screens/guest/navigation_drawer_guest.dart'; // Drawer
import 'package:puptourapp/widgets/app_header.dart'; // Header
import 'package:puptourapp/widgets/app_footer.dart'; // Footer
import 'package:puptourapp/widgets/customer_service.dart'; // Movable button

class GuestBuildingListScreen extends StatefulWidget {
  const GuestBuildingListScreen({super.key});

  static const String routeName = '/buildings';

  @override
  State<GuestBuildingListScreen> createState() => _GuestBuildingListScreenState();
}

class _GuestBuildingListScreenState extends State<GuestBuildingListScreen> {
  static const Color pupRedDark = Color(0xFF850909);
  static const Color whiteText = Colors.white;
  static const Color greyText = Colors.grey;
  static const double horizontalPadding = 20.0;

  // 🔑 Since this is a Guest screen, we can hardcode this or fetch the actual status
  final bool _isLoggedIn = false;

  // 🔑 Helper function to show the login required modal
  void _showLoginRequiredModal(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Access Restricted'),
          content: const Text("Log in first before viewing the map."),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                // 1. Close the dialog
                Navigator.of(context).pop();
                // 2. Redirect to the Login Page
                // Assuming AppRoutes.login is defined
                Navigator.pushNamed(context, AppRoutes.login);
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

  Widget _buildBuildingCard({
    required String imagePath,
    required String title,
    required String subtitle,
    required String location,
    required String openHours,
    required List<String> tags,
  }) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 25),
      decoration: BoxDecoration(
        color: whiteText,
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
            child: Image.asset(
              imagePath,
              height: 250,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(subtitle, style: TextStyle(color: greyText, fontSize: 14)),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8.0,
                  children: tags
                      .map((tag) => Chip(
                    label: Text(tag, style: const TextStyle(fontSize: 12)),
                    backgroundColor: pupRedDark.withOpacity(0.1),
                    labelStyle: const TextStyle(
                        color: pupRedDark, fontWeight: FontWeight.bold),
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
                  ))
                      .toList(),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    const Icon(Icons.location_on, color: pupRedDark, size: 16),
                    const SizedBox(width: 5),
                    Text(location, style: const TextStyle(color: Colors.black, fontSize: 14)),
                  ],
                ),
                const SizedBox(height: 5),
                Row(
                  children: [
                    const Icon(Icons.access_time, color: pupRedDark, size: 16),
                    const SizedBox(width: 5),
                    Text(openHours, style: const TextStyle(color: Colors.black, fontSize: 14)),
                  ],
                ),
                const SizedBox(height: 15),
                SizedBox(
                  width: double.infinity,
                  height: 35,
                  child: ElevatedButton(
                    onPressed: () {
                      // 🔑 KEY CHANGE: Conditional logic for map viewing
                      if (_isLoggedIn) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Viewing $title on map!')),
                        );
                        // Example navigation for a logged-in user:
                        // Navigator.pushNamed(context, AppRoutes.interactiveMap);
                      } else {
                        // Show the login required modal for guests
                        _showLoginRequiredModal(context);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: pupRedDark,
                      foregroundColor: whiteText,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      "View on Map",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
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
          // --- Main Content ---
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.zero,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: horizontalPadding),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 20),
                            const Text(
                              "Building Information",
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "Detailed information about campus buildings",
                              style: TextStyle(color: greyText, fontSize: 15),
                            ),
                            const SizedBox(height: 25),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: horizontalPadding),
                        child: Column(
                          children: [
                            _buildBuildingCard(
                              imagePath: "assets/images/main_building.png",
                              title: "Main Building",
                              subtitle: "Administrative and academic offices",
                              location: "Sta. Mesa, Manila",
                              openHours: "Open 7:00 AM - 9:00 PM",
                              tags: const ["Academic", "Main Campus"],
                            ),
                            _buildBuildingCard(
                              imagePath: "assets/images/charlie.png",
                              title: "Charlie Del Rosario Building",
                              subtitle: "Hosting offices like the Student Services",
                              location: "Sta. Mesa, Manila",
                              openHours: "Open 7:00 AM - 9:00 PM",
                              tags: const ["Academic", "Main Campus"],
                            ),
                            _buildBuildingCard(
                              imagePath: "assets/images/library.png",
                              title: "Library",
                              subtitle: "Academic resources and study areas",
                              location: "Sta. Mesa, Manila",
                              openHours: "Open 7:00 AM - 9:00 PM",
                              tags: const ["Academic", "Main Campus"],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 80),
                      const AppFooter(),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // --- Movable Customer Service Button ---
          const DraggableCustomerServiceButton(iconSize: 50),
        ],
      ),
    );
  }
}