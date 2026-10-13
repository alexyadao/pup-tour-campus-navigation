import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:puptourapp/routes/app_routes.dart';

// --- Style Constants ---
const Color drawerBackground = Color(0xFF2E0505); 
const Color activeTabColor = Color(0xFF4A0808); 
const Color whiteText = Colors.white;
const Color mutedText = Color(0xB3FFFFFF); 

class AppNavigationDrawer extends StatefulWidget {
  const AppNavigationDrawer({super.key});

  @override
  State<AppNavigationDrawer> createState() => _AppNavigationDrawerState();
}

class _AppNavigationDrawerState extends State<AppNavigationDrawer> {
  String _userEmail = "guest@pup.edu.ph";
  String _userName = "PUPTour User";

  @override
  void initState() {
    super.initState();
    _fetchUserProfile();
  }

  void _fetchUserProfile() {
    final user = Supabase.instance.client.auth.currentUser;
    if (user != null) {
      setState(() {
        _userEmail = user.email ?? "student@pup.edu.ph";
        _userName = user.userMetadata?['full_name'] ?? "Guest";
      });
    }
  }

  // --- Helper: Build Drawer Tile ---
  Widget _buildDrawerItem(
    BuildContext context, {
    required String title,
    required IconData icon, 
    required String routeName,
    bool isCurrent = false,
    bool isLogout = false,
  }) {
    
    Future<void> handleTap() async {
      Navigator.pop(context); // Close drawer

      // 1. LOGOUT LOGIC
      if (isLogout) {
        try {
          await Supabase.instance.client.auth.signOut();
          if (context.mounted) {
            Navigator.pushNamedAndRemoveUntil(
                context, AppRoutes.login, (route) => false);
          }
        } catch (e) {
          debugPrint("Error signing out: $e");
          if (context.mounted) {
            Navigator.pushReplacementNamed(context, AppRoutes.login);
          }
        }
        return;
      }

      // 2. NAVIGATION LOGIC
      if (!isCurrent) {
        try {
          Navigator.pushReplacementNamed(context, routeName);
        } catch (e) {
          debugPrint("Route $routeName not found yet.");
          ScaffoldMessenger.of(context).showSnackBar(
             SnackBar(content: Text("Coming Soon: $title"))
          );
        }
      }
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isCurrent ? activeTabColor : Colors.transparent,
        borderRadius: BorderRadius.circular(8), 
        border: isCurrent 
          ? Border(left: BorderSide(color: Colors.red.shade900, width: 4)) 
          : null, 
      ),
      child: ListTile(
        leading: Icon(
          icon,
          color: isLogout ? const Color(0xFFFF6B6B) : whiteText, 
          size: 24,
        ),
        title: Text(
          title,
          style: TextStyle(
            color: whiteText,
            fontSize: 16,
            fontWeight: isCurrent ? FontWeight.w600 : FontWeight.w400,
            letterSpacing: 0.5,
          ),
        ),
        onTap: handleTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Current route detection
    final currentRoute = ModalRoute.of(context)?.settings.name;

    bool isRouteCurrent(String routeName) {
      if (currentRoute == routeName) return true;
      // Handle nested routes keeping the parent tab active
      if (routeName == AppRoutes.events && currentRoute == AppRoutes.viewEvent) return true;
      if (routeName == AppRoutes.myJoinedEvents && currentRoute == AppRoutes.myJoinedEvents) return true;
      return false;
    }

    return Drawer(
      backgroundColor: drawerBackground,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- HEADER SECTION ---
          Padding(
            padding: const EdgeInsets.fromLTRB(25, 60, 25, 30),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Profile Row
                Row(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white24, width: 2),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          )
                        ],
                      ),
                      child: const CircleAvatar(
                        radius: 28,
                        backgroundColor: activeTabColor,
                        child: Icon(Icons.person, size: 30, color: whiteText),
                      ),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _userName,
                            style: const TextStyle(
                              color: whiteText,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _userEmail,
                            style: const TextStyle(
                              color: mutedText,
                              fontSize: 12,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 30),
                const Divider(color: Colors.white10),
                const SizedBox(height: 20),

                // App Title
                RichText(
                  text: const TextSpan(
                    style: TextStyle(
                      fontFamily: 'Roboto', 
                      fontSize: 22,
                      color: whiteText,
                    ),
                    children: [
                      TextSpan(
                        text: "PUP ", 
                        style: TextStyle(fontWeight: FontWeight.w300) 
                      ), 
                      TextSpan(
                        text: "TOUR", 
                        style: TextStyle(fontWeight: FontWeight.w900) 
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 5),
                const Text(
                  "NAVIGATION SYSTEM",
                  style: TextStyle(
                    color: mutedText,
                    fontSize: 10,
                    letterSpacing: 2.0, 
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

          Divider(color: Colors.white.withOpacity(0.1), thickness: 1, height: 1),
          const SizedBox(height: 10),

          // --- MENU ITEMS ---
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _buildDrawerItem(
                  context,
                  title: 'Overview',
                  icon: Icons.dashboard_rounded, 
                  routeName: AppRoutes.home,
                  isCurrent: isRouteCurrent(AppRoutes.home),
                ),

                // --- RESTORED: PROFILE TAB ---
                // Ensure AppRoutes.profile is defined in your routes file!
                _buildDrawerItem(
                  context,
                  title: 'Profile',
                  icon: Icons.person_rounded, 
                  routeName: AppRoutes.profile, 
                  isCurrent: isRouteCurrent(AppRoutes.profile),
                ),
                // -----------------------------
                
                _buildDrawerItem(
                  context,
                  title: 'Campus Map',
                  icon: Icons.map_outlined, 
                  routeName: AppRoutes.campusMap,
                  isCurrent: isRouteCurrent(AppRoutes.campusMap),
                ),

                _buildDrawerItem(
                  context,
                  title: 'Buildings',
                  icon: Icons.apartment_rounded, 
                  routeName: AppRoutes.buildings,
                  isCurrent: isRouteCurrent(AppRoutes.buildings),
                ),
                
                _buildDrawerItem(
                  context,
                  title: 'Campus Craves',
                  icon: Icons.storefront_rounded, 
                  routeName: AppRoutes.foodBazaars,
                  isCurrent: isRouteCurrent(AppRoutes.foodBazaars),
                ),
                
                _buildDrawerItem(
                  context,
                  title: 'Events',
                  icon: Icons.calendar_month_rounded, 
                  routeName: AppRoutes.events,
                  isCurrent: isRouteCurrent(AppRoutes.events),
                ),
                
                _buildDrawerItem(
                  context,
                  title: 'About Us',
                  icon: Icons.info_outline_rounded, 
                  routeName: '/about_us', 
                  isCurrent: isRouteCurrent('/about_us'),
                ),

                _buildDrawerItem(
                  context,
                  title: 'Settings',
                  icon: Icons.settings_rounded, 
                  routeName: '/settings', 
                  isCurrent: isRouteCurrent('/settings'),
                ),
              ],
            ),
          ),

          // --- BOTTOM SECTION (LOGOUT) ---
          Divider(color: Colors.white.withOpacity(0.1), thickness: 1),
          Padding(
            padding: const EdgeInsets.only(bottom: 30, top: 10),
            child: _buildDrawerItem(
              context,
              title: 'Logout',
              icon: Icons.logout_rounded, 
              routeName: AppRoutes.login,
              isLogout: true, 
            ),
          ),
        ],
      ),
    );
  }
}