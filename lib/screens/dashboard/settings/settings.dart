import 'dart:ui'; // Required for Blur effects
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:puptourapp/routes/app_routes.dart';

// --- IMPORTS ---
import 'package:puptourapp/widgets/main_layout.dart';
import 'package:puptourapp/widgets/app_footer.dart';
import 'user_manual_screen.dart'; // Import the new manual file

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // --- Style Constants ---
  static const Color neonYellow = Color(0xFFFFEA00);
  static const Color pupMaroon = Color(0xFF800000); 
  static const Color whiteText = Colors.white;
  static const Color whiteText70 = Colors.white70;

  // --- STATE VARIABLES ---
  bool _notificationsEnabled = true;
  bool _locationAccessAllowed = true;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  // --- BACKEND: Load Preferences ---
  Future<void> _loadSettings() async {
    try {
      final supabase = Supabase.instance.client;
      final userId = supabase.auth.currentUser?.id;

      if (userId != null) {
        final data = await supabase
            .from('users')
            .select('preferences')
            .eq('user_id', userId)
            .single();

        if (data['preferences'] != null) {
          final prefs = data['preferences'] as Map<String, dynamic>;
          setState(() {
            _notificationsEnabled = prefs['notifications'] ?? true;
            _locationAccessAllowed = prefs['location_access'] ?? true;
            _isLoading = false;
          });
        } else {
          setState(() => _isLoading = false);
        }
      }
    } catch (e) {
      debugPrint("Error loading settings: $e");
      setState(() => _isLoading = false);
    }
  }

  // --- BACKEND: Update Database ---
  Future<void> _updatePreference(String key, bool value) async {
    setState(() {
      if (key == 'notifications') _notificationsEnabled = value;
      if (key == 'location_access') _locationAccessAllowed = value;
    });

    try {
      final supabase = Supabase.instance.client;
      final userId = supabase.auth.currentUser?.id;

      if (userId != null) {
        final updates = {
          'notifications': _notificationsEnabled,
          'location_access': _locationAccessAllowed,
        };

        await supabase
            .from('users')
            .update({'preferences': updates}).eq('user_id', userId);
      }
    } catch (e) {
      debugPrint("Error updating settings: $e");
    }
  }

  // --- FEATURE: Send Feedback Dialog ---
  void _showFeedbackDialog(BuildContext context) {
    final TextEditingController feedbackController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (ctx) {
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: AlertDialog(
            backgroundColor: const Color(0xFF1E1E1E),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: const Text("We value your feedback", 
              style: TextStyle(color: neonYellow, fontWeight: FontWeight.bold)),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text("Tell us what you think about PUPTour or report a bug.",
                  style: TextStyle(color: whiteText70, fontSize: 14)),
                const SizedBox(height: 15),
                TextField(
                  controller: feedbackController,
                  maxLines: 4,
                  style: const TextStyle(color: whiteText),
                  decoration: InputDecoration(
                    hintText: "Type your message here...",
                    hintStyle: const TextStyle(color: Colors.white30),
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.1),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text("Cancel", style: TextStyle(color: whiteText70)),
              ),
              ElevatedButton(
                onPressed: () async {
                  final text = feedbackController.text.trim();
                  if (text.isNotEmpty) {
                    Navigator.pop(ctx);
                    try {
                      final user = Supabase.instance.client.auth.currentUser;
                      if (user != null) {
                        // Using the new table we created
                        await Supabase.instance.client.from('feedback').insert({
                          'user_id': user.id,
                          'message': text,
                          // 'rating': 5 // Optional: Add star rating widget if desired
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Feedback sent! Thank you."), backgroundColor: Colors.green)
                        );
                      }
                    } catch (e) {
                      debugPrint("Feedback Error: $e");
                      ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Error sending feedback."), backgroundColor: Colors.red)
                        );
                    }
                  }
                },
                style: ElevatedButton.styleFrom(backgroundColor: pupMaroon),
                child: const Text("Send", style: TextStyle(color: whiteText)),
              ),
            ],
          ),
        );
      },
    );
  }

  // --- UI HELPER: Modal for Info ---
  void _showModalContent(BuildContext context, String title, String content) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: Dialog(
            backgroundColor: const Color(0xFF1E1E1E),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
            child: Container(
              padding: const EdgeInsets.all(24.0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white.withOpacity(0.1)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: neonYellow)),
                  const Divider(color: whiteText70, height: 30),
                  ConstrainedBox(
                    constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.4),
                    child: SingleChildScrollView(
                      child: Text(content, style: const TextStyle(fontSize: 16, color: whiteText, height: 1.5)),
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: pupMaroon, 
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))
                    ),
                    child: const Text('Close', style: TextStyle(color: whiteText)),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // --- WIDGETS ---
  Widget _buildGlassSwitchTile({
    required String title,
    required String subtitle,
    required bool value,
    required Function(bool) onChanged,
    IconData? icon,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.08),
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: Colors.white.withOpacity(0.1)),
            ),
            child: Row(
              children: [
                if (icon != null) ...[Icon(icon, color: neonYellow, size: 24), const SizedBox(width: 15)],
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: const TextStyle(color: whiteText, fontSize: 16, fontWeight: FontWeight.bold)),
                      if (subtitle.isNotEmpty) Text(subtitle, style: const TextStyle(color: whiteText70, fontSize: 12)),
                    ],
                  ),
                ),
                Switch(
                  value: value,
                  onChanged: onChanged,
                  activeThumbColor: neonYellow,
                  activeTrackColor: pupMaroon.withOpacity(0.5),
                  inactiveThumbColor: whiteText70,
                  inactiveTrackColor: Colors.black26,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGlassActionTile({
    required String title,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      child: GestureDetector(
        onTap: onTap,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(15),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.08),
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: Colors.white.withOpacity(0.1)),
              ),
              child: Row(
                children: [
                  Icon(icon, color: whiteText, size: 24),
                  const SizedBox(width: 15),
                  Expanded(child: Text(title, style: const TextStyle(color: whiteText, fontSize: 16, fontWeight: FontWeight.w500))),
                  const Icon(Icons.arrow_forward_ios_rounded, color: whiteText70, size: 16),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBackground() {
    return Container(
      color: const Color(0xFF1A0505),
      child: Stack(
        children: [
          Positioned(top: -100, right: -100, child: Container(width: 300, height: 300, decoration: BoxDecoration(shape: BoxShape.circle, color: neonYellow.withOpacity(0.1), boxShadow: [BoxShadow(color: neonYellow.withOpacity(0.15), blurRadius: 100, spreadRadius: 20)]))),
          Positioned(bottom: 50, left: -50, child: Container(width: 300, height: 300, decoration: BoxDecoration(shape: BoxShape.circle, color: pupMaroon.withOpacity(0.3), boxShadow: [BoxShadow(color: pupMaroon.withOpacity(0.3), blurRadius: 100, spreadRadius: 40)]))),
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
      showHeader: true,

      child: Stack(
        children: [
          _buildBackground(),
          
          SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 10),
                        const Text('Settings', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: whiteText, letterSpacing: 1.0)),
                        const Text('Preferences & Support', style: TextStyle(fontSize: 14, color: whiteText70)),
                        const SizedBox(height: 30),

                        // --- SECTION: APP PREFERENCES ---
                        const Text('PREFERENCES', style: TextStyle(color: neonYellow, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
                        const SizedBox(height: 15),
                        _buildGlassSwitchTile(
                          title: 'Enable Notifications',
                          subtitle: 'Receive updates about events',
                          value: _notificationsEnabled,
                          icon: Icons.notifications_active_rounded,
                          onChanged: (val) => _updatePreference('notifications', val),
                        ),
                        _buildGlassSwitchTile(
                          title: 'Location Access',
                          subtitle: 'Required for campus map navigation',
                          value: _locationAccessAllowed,
                          icon: Icons.location_on_rounded,
                          onChanged: (val) => _updatePreference('location_access', val),
                        ),

                        const SizedBox(height: 25),

                        // --- SECTION: HELP & SUPPORT ---
                        const Text('HELP & SUPPORT', style: TextStyle(color: neonYellow, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
                        const SizedBox(height: 15),

                        // 1. User Manual (Navigates to new screen)
                        _buildGlassActionTile(
                          title: 'User Manual',
                          icon: Icons.menu_book_rounded,
                          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const UserManualScreen())),
                        ),

                        // 2. Send Feedback (Opens Dialog)
                        _buildGlassActionTile(
                          title: 'Send Feedback',
                          icon: Icons.feedback_rounded,
                          onTap: () => _showFeedbackDialog(context),
                        ),

                        const SizedBox(height: 25),

                        // --- SECTION: ACCOUNT & INFO ---
                        const Text('ACCOUNT & INFO', style: TextStyle(color: neonYellow, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
                        const SizedBox(height: 15),

                        _buildGlassActionTile(
                          title: 'Change Password',
                          icon: Icons.lock_reset_rounded,
                          onTap: () => Navigator.pushNamed(context, AppRoutes.resetPassword),
                        ),
                        _buildGlassActionTile(
                          title: 'About the App',
                          icon: Icons.info_outline_rounded,
                          onTap: () => _showModalContent(context, 'About the App', "PUP Tour is your interactive guide to the campus."),
                        ),
                        _buildGlassActionTile(
                          title: 'Privacy Policy',
                          icon: Icons.privacy_tip_outlined,
                          onTap: () => _showModalContent(context, 'Privacy Policy', "We respect your privacy and only use GPS for navigation."),
                        ),

                        const SizedBox(height: 40),
                        
                        // Back Button
                        Center(
                          child: TextButton.icon(
                            onPressed: () => Navigator.pushNamed(context, AppRoutes.profile),
                            icon: const Icon(Icons.arrow_back, color: neonYellow),
                            label: const Text('Back to Profile',
                                style: TextStyle(fontSize: 16, color: neonYellow, fontWeight: FontWeight.bold)),
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),

                // Fixed Footer at the bottom of the screen
                const AppFooter(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}