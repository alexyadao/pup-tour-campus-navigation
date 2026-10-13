import 'package:flutter/material.dart';
import '../../../widgets/main_layout.dart'; // Ensure correct path

class UserManualScreen extends StatefulWidget {
  const UserManualScreen({super.key});

  @override
  State<UserManualScreen> createState() => _UserManualScreenState();
}

class _UserManualScreenState extends State<UserManualScreen> {
  // --- Style Constants ---
  static const Color neonYellow = Color(0xFFFFEA00);
  static const Color whiteText = Colors.white;
  static const Color whiteText70 = Colors.white70;

  // --- Background ---
  Widget _buildBackground() {
    return Container(
      color: const Color(0xFF1A0505),
      child: Stack(
        children: [
          Positioned(
            top: -50,
            right: -50,
            child: Container(
              width: 300, height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: neonYellow.withOpacity(0.1),
                boxShadow: [BoxShadow(color: neonYellow.withOpacity(0.15), blurRadius: 100, spreadRadius: 20)],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- Helper: Expansion Tile (The FAQ Item) ---
  Widget _buildManualTile(String title, IconData icon, List<Widget> children) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          collapsedIconColor: neonYellow,
          iconColor: neonYellow,
          leading: Icon(icon, color: whiteText),
          title: Text(title, style: const TextStyle(color: whiteText, fontWeight: FontWeight.bold, fontSize: 16)),
          childrenPadding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          children: children,
        ),
      ),
    );
  }

  // --- Helper: Bullet Point ---
  Widget _buildStep(String text, {IconData? icon}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon ?? Icons.circle, size: 14, color: whiteText70),
          const SizedBox(width: 10),
          Expanded(child: Text(text, style: const TextStyle(color: whiteText70, fontSize: 14, height: 1.5))),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      enableScroll: false,
      useStandardBackground: false,
      extendBodyBehindAppBar: true,
      showHeader: false, // Custom back button
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Stack(
          children: [
            _buildBackground(),
            
            // Content
            SafeArea(
              child: Column(
                children: [
                  // Header
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                    child: Row(
                      children: [
                        // Back Button
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(Icons.arrow_back_ios_new, color: whiteText, size: 20),
                          ),
                        ),
                        const SizedBox(width: 20),
                        const Text("User Manual", style: TextStyle(color: whiteText, fontSize: 24, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),

                  // Manual List
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      children: [
                        const Text("How to navigate the campus", style: TextStyle(color: neonYellow, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
                        const SizedBox(height: 15),

                        // 1. INTERACTIVE MAP GUIDES
                        _buildManualTile("Using the Map", Icons.map_outlined, [
                          _buildStep("Pinch to zoom in/out and drag to move around the campus."),
                          _buildStep("Tap the 'Recenter Button' (Red Icon) to instantly jump back to your current location.", icon: Icons.my_location),
                          _buildStep("The 'GPS Button' (Grey) allows the app to access your precise coordinates via Geoapify services."),
                          _buildStep("The blue dot represents YOU on the map."),
                        ]),

                        _buildManualTile("Finding Buildings", Icons.search, [
                          _buildStep("Use the search bar at the top to type a building name (e.g., 'Library', 'Gym')."),
                          _buildStep("Select a result from the list to fly the camera to that location."),
                          _buildStep("A 'Landmark Card' will slide up from the bottom, showing the building's history and photo."),
                        ]),

                        _buildManualTile("Navigation & Directions", Icons.directions_walk, [
                          _buildStep("Tap 'Navigate to this Building' on the Landmark Card."),
                          _buildStep("A Blue Navigation Line will appear, drawing the walking path from your location to the destination."),
                          _buildStep("Follow the blue line to reach your destination."),
                        ]),

                        const SizedBox(height: 20),
                        const Text("Events & Profile", style: TextStyle(color: neonYellow, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
                        const SizedBox(height: 15),

                        // 2. OTHER GUIDES
                        _buildManualTile("Joining Events", Icons.event, [
                          _buildStep("Go to the 'Events' tab to see upcoming activities."),
                          _buildStep("Tap 'View Details' to read about the event."),
                          _buildStep("Click 'Register Now' and fill out the form to secure your slot."),
                          _buildStep("Tap the Bell icon to set a reminder 2 days before the event."),
                        ]),

                        _buildManualTile("Account Verification", Icons.verified_user, [
                          _buildStep("Go to 'Profile' > 'Verify Account'."),
                          _buildStep("Upload your Student ID or COR."),
                          _buildStep("Wait for admin approval. Once verified, you will see a green badge on your profile."),
                        ]),
                        
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}