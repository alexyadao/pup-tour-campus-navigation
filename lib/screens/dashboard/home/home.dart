import 'dart:ui'; // Required for Glassmorphism
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:puptourapp/routes/app_routes.dart';
// 1. IMPORT YOUR NEW MAIN LAYOUT
import 'package:puptourapp/widgets/main_layout.dart';
import 'package:puptourapp/screens/dashboard/map/saved_locations_list.dart';
import 'package:puptourapp/screens/ai/ai_guide_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // --- Constants ---
  static const Color pupRedDark = Color(0xFF850909);
  static const Color greyText = Colors.grey;

  // --- Variables ---
  String _guestName = "Guest";
  String _mapViewCount = "0";
  String _eventsJoined = "0"; // Changed from Tours Completed
  String _savedLocations = "0";
  bool _isVerified = false;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  // --- 1. FETCH DATA (Updated for Events) ---
  Future<void> _fetchUserData() async {
    try {
      final supabase = Supabase.instance.client;
      final user = supabase.auth.currentUser;
      final userId = user?.id;

      if (userId != null) {
        // A. Get User Profile & Map Count
        final userData = await supabase
            .from('users')
            .select(
                'first_name, last_name, map_view_count, verification_status')
            .eq('user_id', userId)
            .single();

        // B. Get Events Joined (NEW LOGIC)
        final events = await supabase
            .from('event_participants')
            .count(CountOption.exact) // More efficient than fetching all rows
            .eq('user_id', userId);

        // C. Get Saved Locations
        final saved = await supabase
            .from('saved_locations')
            .count(CountOption.exact)
            .eq('user_id', userId);

        if (mounted) {
          setState(() {
            _guestName = "${userData['first_name']} ${userData['last_name']}";
            _mapViewCount = (userData['map_view_count'] ?? 0).toString();
            _eventsJoined = events.toString(); // Updated variable
            _savedLocations = saved.toString();
            final status = userData['verification_status'] ?? 'Unverified';
            _isVerified = (status == 'Verified');
          });
        }
      }
    } catch (e) {
      debugPrint("Error fetching user data: $e");
    }
  }

  // --- 2. HANDLE MAP CLICK (Increment Logic) ---
  Future<void> _handleMapClick() async {
    // A. Navigate Immediately (For good UX)
    Navigator.pushNamed(context, AppRoutes.interactiveMap);

    // B. Update Database in Background
    try {
      final supabase = Supabase.instance.client;
      final user = supabase.auth.currentUser;
      if (user != null) {
        // Get current count
        final data = await supabase
            .from('users')
            .select('map_view_count')
            .eq('user_id', user.id)
            .single();

        int current = data['map_view_count'] ?? 0;
        int newValue = current + 1;

        // Save new count
        await supabase
            .from('users')
            .update({'map_view_count': newValue}).eq('user_id', user.id);

        // Update UI when they come back
        if (mounted) {
          setState(() {
            _mapViewCount = newValue.toString();
          });
        }
      }
    } catch (e) {
      debugPrint("Error incrementing map view: $e");
    }
  }

  // --- WIDGETS ---
  Widget _buildStatCard({
    required IconData icon,
    required String title,
    required String value,
    required Color iconCircleColor,
    required Color iconColor,
    required VoidCallback? onTap, // If null, arrow is hidden
    List<Color>? gradientColors,
    bool isDarkText = false,
  }) {
    final isGlass = gradientColors == null;
    Widget cardContent = Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        gradient: isGlass
            ? null
            : LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: gradientColors,
              ),
        color: isGlass ? Colors.white.withValues(alpha: 0.6) : null,
        borderRadius: BorderRadius.circular(20),
        border: isGlass
            ? Border.all(color: Colors.white.withValues(alpha: 0.6), width: 1.5)
            : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: iconCircleColor,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: iconCircleColor.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(icon, color: iconColor, size: 28),
              ),
              const SizedBox(width: 15),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: isDarkText ? Colors.black87 : Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    value,
                    style: TextStyle(
                      color: isDarkText
                          ? Colors.black54
                          : Colors.white.withValues(alpha: 0.8),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ],
          ),
          // Only show arrow if onTap is NOT null
          if (onTap != null)
            Icon(Icons.arrow_forward_ios,
                color: isDarkText ? Colors.black54 : Colors.white70, size: 16),
        ],
      ),
    );
    if (isGlass && onTap != null) {
      return GestureDetector(
          onTap: onTap,
          child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: cardContent)));
    } else {
      // If onTap is null, we just return the content (no touch ripple)
      return onTap == null
          ? cardContent
          : GestureDetector(onTap: onTap, child: cardContent);
    }
  }

  Widget _buildPremiumBuildingCard({
    required BuildContext context,
    required String imagePath,
    required String title,
    required String subtitle,
    required String establishedYear,
    required String hours,
    required String locationHint,
    required VoidCallback onLocateTap,
    required VoidCallback onDetailsTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 25),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withValues(alpha: 0.9),
            const Color(0xFFE0C0A0).withValues(alpha: 0.6)
          ],
        ),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 20,
              offset: const Offset(0, 10))
        ],
        border:
            Border.all(color: Colors.white.withValues(alpha: 0.4), width: 1),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Column(
            children: [
              Stack(
                children: [
                  Image.asset(imagePath,
                      height: 200, width: double.infinity, fit: BoxFit.cover),
                  Positioned(
                    bottom: 12,
                    left: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20)),
                      child: Row(children: [
                        const Icon(Icons.history, size: 16),
                        const SizedBox(width: 4),
                        Text("Est. $establishedYear",
                            style: const TextStyle(
                                fontSize: 12, fontWeight: FontWeight.bold))
                      ]),
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: const TextStyle(
                            color: pupRedDark,
                            fontSize: 22,
                            fontWeight: FontWeight.w800)),
                    Text(subtitle,
                        style: TextStyle(
                            color: Colors.black.withValues(alpha: 0.6),
                            fontSize: 14)),
                    const SizedBox(height: 20),
                    Row(children: [
                      _buildChip(Icons.schedule, hours),
                      const SizedBox(width: 10),
                      _buildChip(Icons.location_on, locationHint),
                    ]),
                    const SizedBox(height: 25),
                    Row(children: [
                      Expanded(
                          child: _buildActionButton("Locate", Icons.pin_drop,
                              pupRedDark, Colors.white, onLocateTap)),
                      const SizedBox(width: 12),
                      Expanded(
                          child: _buildActionButton(
                              "Details",
                              Icons.info_outline,
                              Colors.white.withValues(alpha: 0.5),
                              Colors.black87,
                              onDetailsTap)),
                    ]),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.6),
          borderRadius: BorderRadius.circular(20)),
      child: Row(children: [
        Icon(icon, size: 16, color: Colors.orange),
        const SizedBox(width: 6),
        Text(label,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600))
      ]),
    );
  }

  Widget _buildActionButton(
      String label, IconData icon, Color bg, Color text, VoidCallback onTap) {
    return SizedBox(
      height: 48,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
            backgroundColor: bg,
            foregroundColor: text,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            elevation: 0),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(icon, size: 18),
          const SizedBox(width: 8),
          Text(label,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold))
        ]),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- Welcome Card ---
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 30),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF8E0E00), Color(0xFF1F1C18)]),
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                      color: pupRedDark.withValues(alpha: 0.5),
                      blurRadius: 20,
                      offset: const Offset(0, 10))
                ],
              ),
              child: Stack(
                children: [
                  Positioned(
                      top: -50,
                      right: -50,
                      child: Container(
                          width: 150,
                          height: 150,
                          decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white.withValues(alpha: 0.08)))),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Welcome back, $_guestName!",
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold)),
                      const SizedBox(height: 15),
                      Text(
                          "Explore the Polytechnic University of the Philippines campus with interactive maps and virtual tours.",
                          style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.9),
                              fontSize: 15)),
                      const SizedBox(height: 30),

                      // AI Guide Button
                      SizedBox(
                          height: 50,
                          width: double.infinity,
                          child: ElevatedButton(
                              onPressed: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (c) => const AIGuideScreen())),
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFEAA300),
                                  foregroundColor: Colors.black87,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(25))),
                              child: const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.auto_awesome),
                                    SizedBox(width: 10),
                                    Text("Ask AI Guide",
                                        style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold))
                                  ]))),
                      const SizedBox(height: 15),

                      // --- MAIN MAP BUTTON (Modified) ---
                      // Connects to _handleMapClick to update DB
                      SizedBox(
                          height: 45,
                          width: double.infinity,
                          child: OutlinedButton(
                              onPressed: _handleMapClick, // <--- CHANGED HERE
                              style: OutlinedButton.styleFrom(
                                  foregroundColor: Colors.white,
                                  side: const BorderSide(
                                      color: Colors.white, width: 1.5),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(25))),
                              child: const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.map_outlined, size: 20),
                                    SizedBox(width: 10),
                                    Text("View Campus Map",
                                        style: TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.bold))
                                  ]))),

                      if (_isVerified) ...[
                        const SizedBox(height: 15),
                        SizedBox(
                            height: 45,
                            width: double.infinity,
                            child: OutlinedButton(
                                onPressed: () => Navigator.pushNamed(
                                    context, AppRoutes.createEvent),
                                style: OutlinedButton.styleFrom(
                                    foregroundColor: Colors.white,
                                    side: const BorderSide(
                                        color: Colors.white, width: 1.5),
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(25))),
                                child: const Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.calendar_month_outlined,
                                          size: 20),
                                      SizedBox(width: 10),
                                      Text("Schedule Event",
                                          style: TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.bold))
                                    ]))),
                      ]
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 25),

            // --- Stats Cards ---

            // 1. View Campus Map (Count Only - No Arrow)
            _buildStatCard(
                icon: Icons.location_on_outlined,
                title: "View Campus Map",
                value: "$_mapViewCount Views",
                iconCircleColor: const Color(0xFF800000),
                iconColor: Colors.white,
                isDarkText: true,
                onTap: null), // <--- CHANGED TO NULL (Removes Arrow)

            // 2. Events Joined (Replaces Tours Completed)
            _buildStatCard(
                icon: Icons.event_available, // New Icon
                title: "Events Joined", // New Title
                value: "$_eventsJoined Joined", // New Value
                iconCircleColor: const Color(0xFFFFA500),
                iconColor: Colors.white,
                isDarkText: true,
                onTap: () => Navigator.pushNamed(
                    context,
                    AppRoutes
                        .myJoinedEvents)), // Link to your "My Joined Events" page!

            // 3. Saved Locations
            _buildStatCard(
                icon: Icons.bookmark,
                title: "Saved Locations",
                value: "$_savedLocations places bookmarked",
                iconCircleColor: Colors.white.withValues(alpha: 0.2),
                iconColor: Colors.white,
                isDarkText: false,
                gradientColors: const [Color(0xFF8E0E00), Color(0xFF1F1C18)],
                onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (c) => const SavedLocationsListScreen()))),

            const SizedBox(height: 25),

            // --- Featured Section ---
            const Text("Featured Buildings",
                style: TextStyle(
                    color: Colors.black,
                    fontSize: 22,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            const Text("Explore notable locations on campus",
                style: TextStyle(color: greyText, fontSize: 16)),
            const SizedBox(height: 20),

            _buildPremiumBuildingCard(
                context: context,
                imagePath: "assets/images/main_building.png",
                title: "Main Building",
                subtitle:
                    "The iconic flagship structure. Houses admin offices.",
                establishedYear: "1901",
                hours: "07:00 AM - 09:00 PM",
                locationHint: "Facing the Oval",
                onLocateTap: () =>
                    Navigator.pushNamed(context, AppRoutes.interactiveMap),
                onDetailsTap: () => Navigator.pushNamed(
                    context, AppRoutes.mainBuildingDetails)),
            _buildPremiumBuildingCard(
                context: context,
                imagePath: "assets/images/charlie.png",
                title: "Charlie Del Rosario",
                subtitle: "A hub for student services and organizations.",
                establishedYear: "1970s",
                hours: "08:00 AM - 06:00 PM",
                locationHint: "Near the Gate",
                onLocateTap: () =>
                    Navigator.pushNamed(context, AppRoutes.interactiveMap),
                onDetailsTap: () => Navigator.pushNamed(
                    context, AppRoutes.charlieBuildingDetails)),
            _buildPremiumBuildingCard(
                context: context,
                imagePath: "assets/images/library.png",
                title: "Ninoy Aquino Library",
                subtitle: "A vast resource center for academic research.",
                establishedYear: "1980s",
                hours: "07:00 AM - 08:00 PM",
                locationHint: "Central Campus",
                onLocateTap: () =>
                    Navigator.pushNamed(context, AppRoutes.interactiveMap),
                onDetailsTap: () => Navigator.pushNamed(
                    context, AppRoutes.libraryBuildingDetails)),
          ],
        ),
      ),
    );
  }
}
