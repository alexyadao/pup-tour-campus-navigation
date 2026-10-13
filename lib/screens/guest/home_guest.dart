import 'package:flutter/material.dart';
import 'package:puptourapp/routes/app_routes.dart';
import 'package:puptourapp/screens/guest/navigation_drawer_guest.dart';
import 'package:puptourapp/widgets/app_header.dart';
import 'package:puptourapp/widgets/app_footer.dart';
import 'package:puptourapp/widgets/customer_service.dart'; // Movable button

class GuestHomeScreen extends StatefulWidget {
  const GuestHomeScreen({super.key});

  @override
  State<GuestHomeScreen> createState() => _GuestHomeScreenState();
}

class _GuestHomeScreenState extends State<GuestHomeScreen> {
  static const Color pupRedDark = Color(0xFF850909);
  static const Color orangeButton = Color(0xFFFFA500);
  static const Color whiteText = Colors.white;
  static const Color greyText = Colors.grey;

  static const RadialGradient pupRedRadialGradient = RadialGradient(
    colors: [pupRedDark, pupRedDark],
    stops: [0.0, 1.0],
    center: Alignment.center,
    radius: 0.8,
  );

  // --- Info Card Widget ---
  Widget _buildInfoCard({
    required Widget iconWidget,
    required String title,
    required String value,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        color: whiteText,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: greyText.withOpacity(0.7),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          SizedBox(width: 60, height: 60, child: iconWidget),
          const SizedBox(width: 20),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: pupRedDark,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  color: pupRedDark,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // --- Featured Building Card ---
  Widget _buildBuildingCard({
    required String imagePath,
    required String title,
    required String subtitle,
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
              topLeft: Radius.circular(50),
              topRight: Radius.circular(50),
            ),
            child: Image.asset(
              imagePath,
              height: 380,
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
                Text(
                  subtitle,
                  style: TextStyle(color: greyText, fontSize: 14),
                ),
                const SizedBox(height: 15),
                SizedBox(
                  width: double.infinity,
                  height: 40,
                  child: OutlinedButton(
                    onPressed: () {},
                    style: OutlinedButton.styleFrom(
                      foregroundColor: pupRedDark,
                      side: const BorderSide(color: pupRedDark, width: 1.5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: const Text(
                      "View Details",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                )
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
          // Base Layer: Scrolling Content
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // --- Welcome Section ---
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    padding: const EdgeInsets.only(top: 30, left: 20, right: 20, bottom: 50),
                    decoration: BoxDecoration(
                      gradient: pupRedRadialGradient,
                      borderRadius: BorderRadius.circular(40),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Welcome back, Juan!",
                          style: TextStyle(
                            color: whiteText,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          "Explore the Polytechnic University of the \nPhilippines campus with interactive \nmaps and virtual tours.",
                          style: TextStyle(
                            color: whiteText,
                            fontSize: 15,
                          ),
                        ),
                        const SizedBox(height: 40),
                        SizedBox(
                          height: 38,
                          child: ElevatedButton(
                            onPressed: () {},
                            style: ElevatedButton.styleFrom(
                              backgroundColor: orangeButton,
                              foregroundColor: pupRedDark,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                              elevation: 0,
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.auto_awesome),
                                const SizedBox(width: 2),
                                const Text(
                                  "Ask AI Guide",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        SizedBox(
                          height: 38,
                          child: OutlinedButton(
                            onPressed: () => Navigator.pushNamed(context, AppRoutes.interactiveMap),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: whiteText,
                              side: const BorderSide(color: whiteText, width: 2),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Image.asset(
                                  'assets/icons/mapicon_white.png',
                                  width: 40,
                                  height: 40,
                                ),
                                const SizedBox(width: 2),
                                const Text(
                                  "View Campus Map",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 30),

                // --- Info Cards ---
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Column(
                    children: [
                      _buildInfoCard(
                        iconWidget: Image.asset('assets/icons/building_icon.png', width: 40, height: 40),
                        title: "View Campus Map",
                        value: "15+",
                      ),
                      _buildInfoCard(
                        iconWidget: Image.asset('assets/icons/location_1.png', width: 40, height: 40),
                        title: "Saved Location",
                        value: "8",
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 30),

                // --- Featured Buildings ---
                Padding(
                  padding: const EdgeInsets.only(left: 20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Featured Buildings",
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Explore notable locations on campus",
                        style: TextStyle(color: greyText, fontSize: 16),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Column(
                    children: [
                      _buildBuildingCard(
                        imagePath: "assets/images/main_building.png",
                        title: "Main Building",
                        subtitle: "Administrative and academic offices",
                      ),
                      _buildBuildingCard(
                        imagePath: "assets/images/charlie.png",
                        title: "Charlie Del Rosario Building",
                        subtitle: "Hosting offices like the Student Services",
                      ),
                      _buildBuildingCard(
                        imagePath: "assets/images/library.png",
                        title: "Library",
                        subtitle: "Academic resources and study areas",
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 150),

                // --- Footer ---
                const AppFooter(),
              ],
            ),
          ),

          // --- Movable Customer Service Button ---
          DraggableCustomerServiceButton(iconSize: 50),
        ],
      ),
    );
  }
}