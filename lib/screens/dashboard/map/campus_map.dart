import 'package:flutter/material.dart';
import 'package:puptourapp/routes/app_routes.dart';
import 'package:puptourapp/widgets/main_layout.dart'; 

class CampusMapScreen extends StatefulWidget {
  const CampusMapScreen({super.key});

  static const String routeName = '/campus_map';

  @override
  State<CampusMapScreen> createState() => _CampusMapScreenState();
}

class _CampusMapScreenState extends State<CampusMapScreen> {
  // --- Style Constants ---
  static const Color pupRedDark = Color(0xFF850909);
  static const Color orangeAccent = Color(0xFFFFA500); // The Gold/Orange from photo
  static const Color whiteText = Colors.white;
  static const Color greyText = Colors.grey;

  static const double horizontalPadding = 20.0;

  // --- Helper Widget: Premium Glass Building Card ---
  Widget _buildSmallBuildingCard({
    required String imagePath,
    required String title,
    required String subtitle,
    VoidCallback? onTap,
  }) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 15),
      height: 90, // Fixed height for consistency
      decoration: BoxDecoration(
        // 1. THE VISIBLE GLASS GRADIENT (White -> Warm Beige)
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            const Color.fromARGB(93, 255, 255, 255).withValues(alpha: 10.85), // Frosted White
            const Color.fromARGB(25, 232, 220, 202).withValues(alpha: 0.10), // Warm Beige Tint
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        // 2. WHITE BORDER
        border: Border.all(
          color: const Color.fromARGB(34, 255, 255, 255).withValues(alpha: 0.8),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            spreadRadius: 0,
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: onTap,
          child: Stack(
            children: [
              // 3. THE ORANGE INDICATOR (Left Edge)
              Positioned(
                left: 0,
                top: 15,
                bottom: 15,
                child: Container(
                  width: 6, // Thickness of the orange pill
                  decoration: const BoxDecoration(
                    color: orangeAccent,
                    borderRadius: BorderRadius.only(
                      topRight: Radius.circular(10),
                      bottomRight: Radius.circular(10),
                    ),
                  ),
                ),
              ),

              // 4. Content Row
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                child: Row(
                  children: [
                    const SizedBox(width: 5), // Spacing from orange indicator
                    
                    // Image (Styled to match the vibe)
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 5,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(14),
                        child: Image.asset(
                          imagePath,
                          width: 60,
                          height: 60,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    
                    const SizedBox(width: 15),
                    
                    // Text Column
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: const TextStyle(
                              color: Color(0xFF2D2D2D), // Dark Grey/Black
                              fontSize: 16,
                              fontWeight: FontWeight.w800, // Thicker font
                              letterSpacing: -0.5,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            subtitle,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    // 5. Right Arrow (Glassy Look)
                    Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 18,
                      color: Colors.black.withValues(alpha: 0.2), // Subtle arrow
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      child: Padding(
        padding: const EdgeInsets.all(horizontalPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            
            // --- HEADER CARD (Kept from previous step) ---
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(25),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Colors.white, Color(0xFFF0E0D0)],
                ),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.white, width: 3.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Campus Map",
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: Colors.black87),
                      ),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(color: pupRedDark.withValues(alpha: 0.1), shape: BoxShape.circle),
                        child: Icon(Icons.map, color: pupRedDark.withValues(alpha: 0.8)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Divider(color: Colors.black.withValues(alpha: 0.1), thickness: 1),
                  const SizedBox(height: 20),
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Map Type", style: TextStyle(fontSize: 15, color: Colors.black54, fontWeight: FontWeight.w500)),
                      Text("Interactive 2D", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Colors.black)),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // --- Interactive Map Card ---
            Container(
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 30),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color.fromARGB(26, 255, 255, 255),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(color: Colors.black.withValues(alpha: 0.08), spreadRadius: 2, blurRadius: 15, offset: const Offset(0, 5)),
                ],
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(color: pupRedDark.withValues(alpha: 0.05), shape: BoxShape.circle),
                    child: Image.asset('assets/icons/mapicon.png', width: 80, height: 80, color: pupRedDark, errorBuilder: (c,e,s) => const Icon(Icons.map, size: 80, color: pupRedDark)),
                  ),
                  const SizedBox(height: 20),
                  const Text("Explore Campus", textAlign: TextAlign.center, style: TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  const Text("Navigate through the PUP Manila campus with our interactive map.", textAlign: TextAlign.center, style: TextStyle(color: greyText, fontSize: 14, height: 1.4)),
                  const SizedBox(height: 25),
                  SizedBox(
                    width: double.infinity, height: 50,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pushNamed(context, AppRoutes.interactiveMap),
                      style: ElevatedButton.styleFrom(backgroundColor: pupRedDark, foregroundColor: whiteText, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)), elevation: 5),
                      child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.touch_app, size: 20), SizedBox(width: 10), Text("Launch Interactive Map", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold))]),
                    ),
                  ),
                ],
              ),
            ),

            const Text("Quick Locations", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
            const SizedBox(height: 15),

            // --- UPDATED CARDS (Matching the Customer Service Style) ---
            _buildSmallBuildingCard(
              imagePath: "assets/images/main_building.png",
              title: "Main Building",
              subtitle: "Admin & Academic Offices",
              onTap: () => Navigator.pushNamed(context, AppRoutes.mainBuildingDetails),
            ),
            _buildSmallBuildingCard(
              imagePath: "assets/images/charlie.png",
              title: "Charlie Del Rosario",
              subtitle: "Student Services & Orgs",
              onTap: () => Navigator.pushNamed(context, AppRoutes.charlieBuildingDetails),
            ),
            _buildSmallBuildingCard(
              imagePath: "assets/images/library.png",
              title: "Ninoy Aquino Library",
              subtitle: "Resources & Study Areas",
              onTap: () => Navigator.pushNamed(context, AppRoutes.libraryBuildingDetails),
            ),
          ],
        ),
      ),
    );
  }
}