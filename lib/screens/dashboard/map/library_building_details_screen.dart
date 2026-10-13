import 'dart:ui'; // Required for Blur effects
import 'package:flutter/material.dart';

// Use your existing drawer import
import 'package:puptourapp/widgets/app_navigation_drawer.dart';

class LibraryBuildingDetailsScreen extends StatelessWidget {
  const LibraryBuildingDetailsScreen({super.key});

  static const String routeName = '/libraryBuildingDetails';

  // --- Style Constants ---
  static const Color neonYellow = Color(0xFFFFEA00);
  static const Color pupMaroon = Color(0xFF800000);
  static const Color whiteText = Colors.white;
  static const Color whiteText70 = Colors.white70;

  @override
  Widget build(BuildContext context) {
    // Screen Dimensions
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      // 1. EXTEND BODY: Allows image/glass to go behind the status bar
      extendBodyBehindAppBar: true,

      // 2. DRAWER: Keep your navigation
      drawer: const AppNavigationDrawer(),

      // 3. APP BAR: Transparent
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: _buildGlassBackButton(context),
        ),
      ),

      body: Stack(
        children: [
          // A. BACKGROUND LAYER (Deep Maroon + Neon Blobs)
          _buildBackground(),

          // B. IMAGE LAYER (Top Hero Image)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: screenHeight * 0.4, // Occupies top 40%
            child: ShaderMask(
              shaderCallback: (rect) {
                return const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.black, Colors.transparent],
                ).createShader(Rect.fromLTRB(0, 0, rect.width, rect.height));
              },
              blendMode: BlendMode.dstIn,
              child: Image.asset(
                'assets/images/library.png', // Ensure this image exists
                fit: BoxFit.cover,
              ),
            ),
          ),

          // C. GLASS CONTENT LAYER
          Positioned.fill(
            top: screenHeight * 0.35, // Starts overlapping the image
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(30),
                topRight: Radius.circular(30),
              ),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15), // The Blur
                child: Container(
                  decoration: BoxDecoration(
                    color:
                        Colors.black.withOpacity(0.4), // Dark transparent tint
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                    border: Border(
                      top: BorderSide(
                          color: Colors.white.withOpacity(0.2), width: 1),
                    ),
                  ),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(25, 30, 25, 40),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // --- HEADER ROW ---
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Expanded(
                              child: Text(
                                "Ninoy Aquino Library",
                                style: TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.w900,
                                  color: whiteText,
                                  letterSpacing: 0.5,
                                  height: 1.2,
                                ),
                              ),
                            ),
                            // Bookmark Icon
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: pupMaroon.withOpacity(0.8),
                                shape: BoxShape.circle,
                                border: Border.all(
                                    color: neonYellow.withOpacity(0.5)),
                                boxShadow: [
                                  BoxShadow(
                                    color: neonYellow.withOpacity(0.3),
                                    blurRadius: 10,
                                  )
                                ],
                              ),
                              child: const Icon(
                                Icons.bookmark_rounded,
                                color: neonYellow,
                                size: 28,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 15),

                        // --- DESCRIPTION ---
                        const Text(
                          "The Ninoy Aquino Library and Learning Resources Center (NALRRC) is the university's primary repository of knowledge. It provides students and faculty with access to vast collections of books, journals, research papers, and digital resources in a conducive environment for study.",
                          style: TextStyle(
                            fontSize: 15,
                            color: whiteText70,
                            height: 1.6,
                          ),
                        ),

                        const SizedBox(height: 30),

                        // --- SECTION 1: WHAT'S INSIDE ---
                        _buildSectionTitle(
                            "What's Inside", Icons.local_library_outlined),
                        const SizedBox(height: 15),

                        // Icons specific to Library Sections
                        _buildModernInfoRow(
                            Icons.import_contacts_rounded,
                            "Circulation Section",
                            "Main collection of books for borrowing."),
                        _buildModernInfoRow(
                            Icons.newspaper_rounded,
                            "Periodicals Section",
                            "Newspapers, journals, and magazines."),
                        _buildModernInfoRow(
                            Icons.history_edu_rounded,
                            "Filipiniana Section",
                            "Books and publications about the Philippines."),
                        _buildModernInfoRow(
                            Icons.monitor_rounded,
                            "Multimedia Center",
                            "Access to digital learning materials and computers."),
                        _buildModernInfoRow(
                            Icons.people_alt_rounded,
                            "Discussion Rooms",
                            "Private areas for group study sessions."),

                        const SizedBox(height: 30),

                        // --- SECTION 2: BUILDING HOURS ---
                        _buildSectionTitle(
                            "Building Hours", Icons.access_time_filled_rounded),
                        const SizedBox(height: 15),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(15),
                            border:
                                Border.all(color: neonYellow.withOpacity(0.2)),
                          ),
                          child: const Row(
                            children: [
                              Icon(Icons.schedule, color: neonYellow, size: 24),
                              SizedBox(width: 15),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Monday–Saturday: 8:00 AM – 8:00 PM",
                                      style: TextStyle(
                                          color: whiteText,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15),
                                    ),
                                    SizedBox(height: 5),
                                    Text(
                                      "(Closed on Sundays and Holidays)",
                                      style: TextStyle(
                                          color: whiteText70,
                                          fontStyle: FontStyle.italic,
                                          fontSize: 12),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 30),

                        // --- SECTION 3: IMPORTANT REMINDERS ---
                        _buildSectionTitle("Important Reminders",
                            Icons.notifications_active_rounded),
                        const SizedBox(height: 15),
                        _buildSimpleReminder(
                            "Observe silence at all times inside the reading areas."),
                        _buildSimpleReminder(
                            "No eating or drinking allowed inside."),
                        _buildSimpleReminder(
                            "Leave your bags at the baggage counter upon entry."),
                        _buildSimpleReminder(
                            "Present your valid Library ID to borrow books."),

                        const SizedBox(height: 50),
                      ],
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

  // --- WIDGET: The Background with Neon Blobs ---
  Widget _buildBackground() {
    return Container(
      color: const Color(0xFF1A0505), // Very Dark Maroon/Black Base
      child: Stack(
        children: [
          // Blob 1: Neon Yellow (Top Right)
          Positioned(
            top: 100,
            right: -50,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: neonYellow.withOpacity(0.15),
                boxShadow: [
                  BoxShadow(
                      color: neonYellow.withOpacity(0.2),
                      blurRadius: 100,
                      spreadRadius: 20)
                ],
              ),
            ),
          ),
          // Blob 2: Maroon/Red (Center Left)
          Positioned(
            top: 300,
            left: -50,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: pupMaroon.withOpacity(0.4),
                boxShadow: [
                  BoxShadow(
                      color: pupMaroon.withOpacity(0.4),
                      blurRadius: 100,
                      spreadRadius: 40)
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- WIDGET: Glass Back Button ---
  Widget _buildGlassBackButton(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.3),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withOpacity(0.2)),
          ),
          child: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded,
                color: Colors.white, size: 20),
            onPressed: () => Navigator.pop(context),
          ),
        ),
      ),
    );
  }

  // --- WIDGET: Section Title ---
  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: neonYellow, size: 24),
        const SizedBox(width: 10),
        Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: whiteText,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }

  // --- WIDGET: Modern Bullet Point ---
  Widget _buildModernInfoRow(IconData icon, String title, String subtitle) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon Container
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Colors.white70, size: 18),
          ),
          const SizedBox(width: 15),
          // Text Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: whiteText,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 14,
                    color: whiteText70,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- WIDGET: Simple Bullet Point ---
  Widget _buildSimpleReminder(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 6.0),
            child: Icon(Icons.circle, size: 8, color: neonYellow),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 15,
                color: whiteText70,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
