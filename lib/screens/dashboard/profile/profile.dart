import 'dart:ui'; // Required for ImageFilter
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:puptourapp/routes/app_routes.dart';

// --- IMPORTS ---
import 'package:puptourapp/widgets/main_layout.dart';
import '../../../widgets/app_footer.dart'; 
import 'verify_account_screen.dart'; 

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  static const String routeName = '/profile';

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // --- Style Constants for Dark Theme ---
  static const Color neonYellow = Color(0xFFFFEA00);
  static const Color pupMaroon = Color(0xFF800000);
  static const Color whiteText = Colors.white;
  static const Color whiteText70 = Colors.white70;

  // --- State Variables ---
  String _fullName = "Loading...";
  String _email = "Loading...";
  String _initials = "..";
  String _memberSince = "Loading...";
  String _username = "Loading..."; 
  String _verificationStatus = "Unverified"; 

  // Stats Variables
  String _savedLocationsCount = "0";
  String _toursCompletedCount = "0";
  String _timeSpentExploring = "0 hours";

  @override
  void initState() {
    super.initState();
    _getProfileData();
  }

  // --- BACKEND LOGIC ---
  Future<void> _getProfileData() async {
    try {
      final supabase = Supabase.instance.client;
      final user = supabase.auth.currentUser;

      if (user != null) {
        setState(() {
          _email = user.email ?? "No Email";
          if (user.createdAt.isNotEmpty) {
            final createdDate = DateTime.parse(user.createdAt);
            _memberSince = _formatDate(createdDate);
          }
        });

        final userData = await supabase
            .from('users')
            .select('first_name, last_name, username, verification_status')
            .eq('user_id', user.id)
            .single();

        final savedLocs = await supabase
            .from('saved_locations')
            .select('*')
            .eq('user_id', user.id);

        final tourHistory = await supabase
            .from('tour_history')
            .select('time_spent_minutes')
            .eq('user_id', user.id);

        setState(() {
          String firstName = userData['first_name'] ?? "User";
          String lastName = userData['last_name'] ?? "";
          _fullName = "$firstName $lastName";

          String rawUsername = userData['username'] ?? "No Username";
          _username = rawUsername.startsWith('@') ? rawUsername : "@$rawUsername";

          _verificationStatus = userData['verification_status'] ?? "Unverified";

          if (firstName.isNotEmpty && lastName.isNotEmpty) {
            _initials = "${firstName[0]}${lastName[0]}".toUpperCase();
          } else if (firstName.isNotEmpty) {
            _initials = firstName[0].toUpperCase();
          } else {
            _initials = "U";
          }

          _savedLocationsCount = savedLocs.length.toString();
          _toursCompletedCount = tourHistory.length.toString();

          int totalMinutes = 0;
          for (var record in tourHistory) {
            totalMinutes += (record['time_spent_minutes'] as int? ?? 0);
          }
          double hours = totalMinutes / 60;
          _timeSpentExploring = "${hours.toStringAsFixed(1).replaceAll(RegExp(r'\.0$'), '')} hours";
        });
      }
    } catch (e) {
      debugPrint("Error fetching profile: $e");
      setState(() {
        _fullName = "User";
        _username = "@error";
      });
    }
  }

  String _formatDate(DateTime date) {
    const months = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"];
    return "${months[date.month - 1]} ${date.year}";
  }

  // --- VISUALS: Background ---
  Widget _buildBackground() {
    return Container(
      color: const Color(0xFF1A0505), // Deep Dark Maroon Base
      child: Stack(
        children: [
          // Blob 1: Neon Yellow (Top Left)
          Positioned(
            top: -50,
            left: -50,
            child: Container(
              width: 300,
              height: 300,
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
          // Blob 2: Maroon/Red (Center Right)
          Positioned(
            bottom: 200,
            right: -50,
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

  // --- VISUALS: Glass Card ---
  Widget _buildGlassCard({required Widget child}) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.all(20),
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withOpacity(0.15)),
            ),
            child: child,
          ),
        ),
      ),
    );
  }

  // --- VISUALS: Info Row ---
  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: whiteText70, fontSize: 14)),
          Text(value, style: const TextStyle(color: neonYellow, fontSize: 15, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  // --- VISUALS: Action Button ---
  Widget _buildActionButton({
    required String text,
    required VoidCallback onPressed,
    required IconData icon,
    bool isDestructive = false,
  }) {
    return Container(
      width: double.infinity,
      height: 50,
      margin: const EdgeInsets.only(bottom: 15),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: isDestructive ? Colors.red.withOpacity(0.2) : Colors.white.withOpacity(0.1),
          foregroundColor: whiteText,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
            side: BorderSide(
              color: isDestructive ? Colors.red.withOpacity(0.5) : Colors.white.withOpacity(0.2),
            ),
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: isDestructive ? Colors.redAccent : neonYellow, size: 22),
            const SizedBox(width: 15),
            Text(
              text,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isDestructive ? Colors.redAccent : whiteText,
              ),
            ),
            const Spacer(),
            Icon(Icons.arrow_forward_ios_rounded, size: 16, color: whiteText70),
          ],
        ),
      ),
    );
  }

  // --- HELPER: Verification Badge ---
  Widget _buildVerificationBadge() {
    Color badgeColor;
    String badgeText;
    IconData badgeIcon;

    if (_verificationStatus == 'Verified') {
      badgeColor = Colors.greenAccent;
      badgeText = "Verified Student";
      badgeIcon = Icons.verified;
    } else if (_verificationStatus == 'Pending') {
      badgeColor = Colors.orangeAccent;
      badgeText = "Verification Pending";
      badgeIcon = Icons.hourglass_top;
    } else {
      // Unverified State
      return Padding(
        padding: const EdgeInsets.only(top: 10),
        child: OutlinedButton.icon(
          onPressed: () {
             Navigator.push(context, MaterialPageRoute(builder: (context) => const VerifyAccountScreen()))
               .then((_) => _getProfileData());
          },
          icon: const Icon(Icons.verified_user_outlined, size: 18, color: neonYellow),
          label: const Text("Verify Account", style: TextStyle(color: neonYellow)),
          style: OutlinedButton.styleFrom(
            side: const BorderSide(color: neonYellow),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          ),
        ),
      );
    }

    // Verified/Pending Badge
    return Container(
      margin: const EdgeInsets.only(top: 10),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: badgeColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: badgeColor.withOpacity(0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(badgeIcon, size: 16, color: badgeColor),
          const SizedBox(width: 5),
          Text(badgeText, style: TextStyle(color: badgeColor, fontSize: 12, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      // --- CUSTOM SWITCHES for Dark Theme ---
      enableScroll: false, 
      useStandardBackground: false,
      extendBodyBehindAppBar: true, 
      showHeader: true, // Keep header so the Hamburger Menu works

      child: Stack(
        children: [
          // 1. Background
          _buildBackground(),

          // 2. Scrollable Content
          LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: IntrinsicHeight(
                    child: SafeArea(
                      child: Column(
                        children: [
                          const SizedBox(height: 20),
                          
                          // --- PROFILE HEADER (Avatar & Name) ---
                          Column(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(color: neonYellow, width: 2),
                                  boxShadow: [
                                    BoxShadow(color: neonYellow.withOpacity(0.3), blurRadius: 20)
                                  ],
                                ),
                                child: CircleAvatar(
                                  radius: 50,
                                  backgroundColor: pupMaroon,
                                  child: Text(
                                    _initials,
                                    style: const TextStyle(color: whiteText, fontSize: 36, fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 15),
                              Text(
                                _fullName,
                                style: const TextStyle(color: whiteText, fontSize: 24, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 5),
                              Text(
                                _email,
                                style: const TextStyle(color: whiteText70, fontSize: 14),
                              ),
                              _buildVerificationBadge(),
                            ],
                          ),
                          const SizedBox(height: 30),

                          // --- DETAILS CARD ---
                          _buildGlassCard(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text("Account Details", style: TextStyle(color: whiteText, fontSize: 18, fontWeight: FontWeight.bold)),
                                const Divider(color: Colors.white24, height: 20),
                                _buildInfoRow("Username", _username),
                                _buildInfoRow("Member Since", _memberSince),
                              ],
                            ),
                          ),

                          // --- STATS CARD ---
                          _buildGlassCard(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text("Activity Stats", style: TextStyle(color: whiteText, fontSize: 18, fontWeight: FontWeight.bold)),
                                const Divider(color: Colors.white24, height: 20),
                                _buildInfoRow("Tours Completed", _toursCompletedCount),
                                _buildInfoRow("Saved Locations", _savedLocationsCount),
                                _buildInfoRow("Time Exploring", _timeSpentExploring),
                              ],
                            ),
                          ),

                          const SizedBox(height: 10),

                          // --- ACTIONS ---
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: Column(
                              children: [
                                _buildActionButton(
                                  text: "My Joined Events",
                                  icon: Icons.event_available,
                                  onPressed: () => Navigator.pushNamed(context, AppRoutes.myJoinedEvents),
                                ),
                                
                                // --- RESTORED: Reset Password ---
                                _buildActionButton(
                                  text: "Reset Password",
                                  icon: Icons.lock_reset,
                                  onPressed: () => Navigator.pushNamed(context, AppRoutes.resetPassword),
                                ),

                                _buildActionButton(
                                  text: "Settings",
                                  icon: Icons.settings,
                                  onPressed: () => Navigator.pushNamed(context, AppRoutes.settings),
                                ),

                                _buildActionButton(
                                  text: "Sign Out",
                                  icon: Icons.logout,
                                  isDestructive: true,
                                  onPressed: () async {
                                    await Supabase.instance.client.auth.signOut();
                                    if (context.mounted) {
                                      Navigator.of(context).pushNamedAndRemoveUntil(AppRoutes.login, (route) => false);
                                    }
                                  },
                                ),
                              ],
                            ),
                          ),

                          const Spacer(),
                          const AppFooter(),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}