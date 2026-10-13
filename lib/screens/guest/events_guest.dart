import 'package:flutter/material.dart';
import 'package:puptourapp/routes/app_routes.dart';
import 'package:puptourapp/screens/guest/navigation_drawer_guest.dart'; // Drawer
import 'package:puptourapp/widgets/app_header.dart';
import 'package:puptourapp/widgets/app_footer.dart';
import 'package:puptourapp/widgets/customer_service.dart'; // Movable button

class GuestEventsScreen extends StatefulWidget {
  const GuestEventsScreen({super.key});

  @override
  State<GuestEventsScreen> createState() => _GuestEventsScreenState();
}

class _GuestEventsScreenState extends State<GuestEventsScreen> {
  static const Color pupRedDark = Color(0xFF850909);
  static const Color whiteText = Colors.white;
  static const Color greyText = Colors.grey;
  static const Color cardBackgroundColor = Colors.white;

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      margin: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: TextField(
        decoration: InputDecoration(
          hintText: "Search Events...",
          contentPadding: const EdgeInsets.symmetric(vertical: 14.0, horizontal: 8.0),
          border: InputBorder.none,
          prefixIcon: Padding(
            padding: const EdgeInsets.only(left: 10, right: 8),
            child: Icon(Icons.search, color: pupRedDark, size: 28),
          ),
        ),
      ),
    );
  }

  Widget _buildEventCard({
    required String imagePath,
    required String title,
    required String description,
    required String dateTime,
  }) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 30),
      decoration: BoxDecoration(
        color: cardBackgroundColor,
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
              height: 180,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        color: Colors.black,
                        fontSize: 20,
                        fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text(description,
                    style: TextStyle(color: greyText, fontSize: 14, height: 1.4)),
                const SizedBox(height: 10),
                Row(
                  children: [
                    const Icon(Icons.access_time, color: pupRedDark, size: 18),
                    const SizedBox(width: 9),
                    Expanded(
                      child: Text(
                        dateTime,
                        style: const TextStyle(
                            color: pupRedDark,
                            fontSize: 14,
                            fontWeight: FontWeight.w500),
                        overflow: TextOverflow.ellipsis, // Prevent overflow
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 45,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pushNamed(AppRoutes.login);
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
                      "Log in to View Details",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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
          // --- Main Content ---
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSearchBar(),
                      const Text(
                        "Upcoming Campus Events",
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 15),
                      _buildEventCard(
                        imagePath: 'assets/images/pup.png',
                        title: "PUP Tour 2025",
                        description:
                        "An engaging campus event showcasing PUP student organizations, food stalls, merchandise booths, and interactive activities. Students can explore clubs, try affordable meals, and participate in games, raffles, and performances.",
                        dateTime: "December 12, 2025 | 8:00 AM – 5:00 PM",
                      ),
                      _buildEventCard(
                        imagePath: 'assets/images/cea.png',
                        title: "Engineering Week: Innovate 2026",
                        description:
                        "A week-long series of workshops, seminars, and hackathons dedicated to civil, electrical, and computer engineering. Includes a project showcase by graduating students.",
                        dateTime: "January 20, 2026 | 8:00 AM – 5:00 PM",
                      ),
                      const SizedBox(height: 30),
                    ],
                  ),
                ),
                const AppFooter(),
              ],
            ),
          ),

          // --- Movable Customer Service Button ---
          const DraggableCustomerServiceButton(iconSize: 50),
        ],
      ),
    );
  }
}