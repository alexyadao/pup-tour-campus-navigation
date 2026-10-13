import 'dart:ui'; // Required for Glassmorphism
import 'package:flutter/material.dart';

// --- IMPORTS ---
import '../../../widgets/app_navigation_drawer.dart'; 

class AboutUsScreen extends StatelessWidget {
  const AboutUsScreen({super.key});

  static const String routeName = '/about_us';

  // --- ASSET PATHS ---
  // Ensure these files exist in your assets folder!
  static const String adviserImage = 'assets/prof_icons/marasigan.png'; 
  static const String member1Image = 'assets/prof_icons/lozano.png';
  static const String member2Image = 'assets/prof_icons/tarriela.png';
  static const String member3Image = 'assets/prof_icons/castillo.png';
  static const String member4Image = 'assets/prof_icons/delacruz.png';
  static const String member5Image = 'assets/prof_icons/carcillar.png'; 
  static const String member6Image = 'assets/prof_icons/magisa.png';    
  // Added your image path here. If the file doesn't exist, it will show a default icon.
  static const String member7Image = 'assets/prof_icons/yadao.png';     

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 1. DRAWER INTEGRATION
      drawer: const AppNavigationDrawer(),

      // extendBodyBehindAppBar allows the glass effect to go behind the header
      extendBodyBehindAppBar: true,
      
      appBar: AppBar(
        // 2. FIXED NAVIGATION BUTTON
        leadingWidth: 70, 
        leading: Padding(
          padding: const EdgeInsets.only(left: 8.0, top: 8.0, bottom: 8.0),
          child: Builder(
            builder: (context) {
              return _ModernGlassButton(
                icon: Icons.menu_rounded, 
                onPressed: () {
                  Scaffold.of(context).openDrawer();
                },
              );
            },
          ),
        ),
        title: const Text(
          "About Us", 
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)
        ),
        centerTitle: true, 
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      
      body: Stack(
        children: [
          // Background
          _buildBackground(context),

          // Content
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- INTRODUCTION ---
                  _buildGlassCard(
                    child: Column(
                      children: [
                        const Icon(Icons.verified_outlined, color: Colors.yellowAccent, size: 40),
                        const SizedBox(height: 10),
                        const Text(
                          "Welcome to PUPTour",
                          style: TextStyle(
                            fontSize: 22, 
                            fontWeight: FontWeight.bold, 
                            color: Colors.white
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          "PUPTour is a mobile campus navigation application created for the Polytechnic University of the Philippines (PUP) Main Campus. Developed by PUP Computer Engineering students, the app aims to assist students and visitors by offering an interactive and user-friendly guide to help them explore and navigate the campus with ease.",
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.white.withOpacity(0.9), height: 1.5),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // --- VISION & MISSION ---
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: _buildGlassCard(
                          padding: 15,
                          child: const Column(
                            children: [
                              Icon(Icons.visibility_outlined, color: Colors.cyanAccent, size: 30),
                              SizedBox(height: 8),
                              Text("Vision", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                              SizedBox(height: 8),
                              Text(
                                "To become a reliable and innovative digital navigation platform, showcasing the capabilities of Computer Engineering students.",
                                textAlign: TextAlign.center,
                                style: TextStyle(color: Colors.white70, fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: _buildGlassCard(
                          padding: 15,
                          child: const Column(
                            children: [
                              Icon(Icons.rocket_launch_outlined, color: Colors.orangeAccent, size: 30),
                              SizedBox(height: 8),
                              Text("Mission", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                              SizedBox(height: 8),
                              Text(
                                "To deliver an efficient mobile campus navigation app applying engineering principles to improve campus orientation.",
                                textAlign: TextAlign.center,
                                style: TextStyle(color: Colors.white70, fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 30),
                  const Text("Project Adviser", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),

                  // --- ADVISER ---
                  _buildGlassCard(
                    child: Column(
                      children: [
                        _buildProfileImage(adviserImage),
                        const SizedBox(height: 15),
                        const Text(
                          "Dr. Rufo I. Marasigan Jr., PCpE",
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.yellowAccent, fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const Text(
                          "Professor of Computer Engineering",
                          style: TextStyle(color: Colors.white70, fontSize: 13),
                        ),
                        const Divider(color: Colors.white24, height: 30),
                        const Text(
                          "Expert in embedded systems, robotics, AI, and blockchain. An active member of NRCP, IEEE, ICPeP, and MRSP, he mentors students in both academic and entrepreneurial pursuits.",
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.white, fontSize: 13, height: 1.4),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 30),
                  const Text("The Developers", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),

                  // --- TEAM MEMBERS ---
                  
                  // 1. E.J. Laodicea
                  _buildTeamMemberCard(
                    name: "E.J. Laodicea G. Lozano",
                    role: "Documentation & Coordination",
                    desc: "Prepares project documentation and supports team coordination. Tracks progress to ensure objectives are met.",
                    imagePath: member1Image,
                    icon: Icons.assignment_outlined,
                  ),
                  const SizedBox(height: 15),
                  
                  // 2. Al Gene Lee
                  _buildTeamMemberCard(
                    name: "Al Gene Lee B. Tarriela",
                    role: "UI/UX Designer",
                    desc: "Creates clean, intuitive interfaces. His goal is to make exploring the campus effortless and enjoyable.",
                    imagePath: member2Image,
                    icon: Icons.brush_outlined,
                  ),
                  const SizedBox(height: 15),
                  
                  // 3. Ivhorre Levy
                  _buildTeamMemberCard(
                    name: "Ivhorre Levy C. Castillo",
                    role: "Backend Developer",
                    desc: "Manages the technical setup and ensures the consistency of the whole project.",
                    imagePath: member3Image,
                    icon: Icons.terminal_outlined,
                  ),
                  const SizedBox(height: 15),
                  
                  // 4. Heherson
                  _buildTeamMemberCard(
                    name: "Heherson D. Dela Cruz Jr.",
                    role: "Data & Documentation",
                    desc: "Responsible for project documentation and assisting with the collection of necessary information.",
                    imagePath: member4Image,
                    icon: Icons.folder_open_outlined,
                  ),
                  const SizedBox(height: 15),

                  // 5. Maxene Monina
                  _buildTeamMemberCard(
                    name: "Maxene Monina P. Carcillar",
                    role: "Project Documentation",
                    desc: "Tasked with creating project records, ensuring completeness and accuracy for proper application documentation.",
                    imagePath: member5Image,
                    icon: Icons.library_books_outlined,
                  ),
                  const SizedBox(height: 15),

                  // 6. Ma. Juliana Vanness
                  _buildTeamMemberCard(
                    name: "Ma. Juliana Vanness Mag-isa",
                    role: "Frontend Developer",
                    desc: "Responsible for the frontend, adjusting the app appearance to be visually pleasing and ensuring full functionality.",
                    imagePath: member6Image,
                    icon: Icons.palette_outlined,
                  ),
                  const SizedBox(height: 15),

                  // 7. Alexander Christian (YOU ARE HERE)
                  _buildTeamMemberCard(
                    name: "Alexander Christian R. Yadao",
                    role: "Backend Dev & DB Admin",
                    desc: "Manages server-side logic and database architecture. He ensures data integrity, security, and seamless API communication.",
                    imagePath: member7Image,
                    icon: Icons.storage_rounded,
                  ),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- WIDGET HELPER: Background ---
  Widget _buildBackground(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: const BoxDecoration(
        color: Color(0xFF2E0505),
      ),
      child: Stack(
        children: [
          Positioned(
            top: -100,
            left: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.yellowAccent.withOpacity(0.4),
                boxShadow: [
                  BoxShadow(color: Colors.yellowAccent.withOpacity(0.4), blurRadius: 100, spreadRadius: 50)
                ],
              ),
            ),
          ),
          Positioned(
            top: 300,
            right: -50,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF800000).withOpacity(0.6),
                boxShadow: [
                  BoxShadow(color: const Color(0xFF800000).withOpacity(0.6), blurRadius: 100, spreadRadius: 20)
                ],
              ),
            ),
          ),
          Positioned(
            bottom: -50,
            left: -50,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.amberAccent.withOpacity(0.3),
                boxShadow: [
                  BoxShadow(color: Colors.amberAccent.withOpacity(0.3), blurRadius: 100, spreadRadius: 30)
                ],
              ),
            ),
          ),
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
            child: Container(color: Colors.transparent),
          ),
        ],
      ),
    );
  }

  // --- WIDGET HELPER: Glass Card ---
  Widget _buildGlassCard({required Widget child, double padding = 20}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.all(padding),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withOpacity(0.2), width: 1.5),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }

  // --- WIDGET HELPER: Team Member Card ---
  Widget _buildTeamMemberCard({
    required String name,
    required String role,
    required String desc,
    required String imagePath,
    required IconData icon,
  }) {
    return _buildGlassCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildProfileImage(imagePath, size: 60),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        name,
                        style: const TextStyle(
                          color: Colors.yellowAccent, 
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                    ),
                    Icon(icon, color: Colors.white70, size: 18),
                  ],
                ),
                Text(
                  role,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  desc,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 11,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- WIDGET HELPER: Profile Image ---
  Widget _buildProfileImage(String path, {double size = 100}) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.yellowAccent.withOpacity(0.5), width: 2),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 5))
        ],
      ),
      child: ClipOval(
        child: Image.asset(
          path,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            // This is where it handles your missing image
            return Container(
              color: Colors.white24,
              child: const Icon(Icons.person, color: Colors.white),
            );
          },
        ),
      ),
    );
  }
}

// --- INTERNAL HELPER: Modern Glass Button ---
class _ModernGlassButton extends StatelessWidget {
  final VoidCallback onPressed;
  final IconData icon;
  
  const _ModernGlassButton({required this.onPressed, required this.icon});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(15.0),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
        child: Container(
          width: 45,
          height: 45,
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.4),
            borderRadius: BorderRadius.circular(15.0),
            border: Border.all(color: Colors.white.withOpacity(0.2), width: 1.5),
          ),
          child: IconButton(
            padding: EdgeInsets.zero,
            icon: Icon(icon, color: Colors.white, size: 22),
            onPressed: onPressed,
          ),
        ),
      ),
    );
  }
}