import 'package:flutter/material.dart';
import 'package:puptourapp/routes/app_routes.dart';

// --- Style Constants ---
const Color pupRedDark = Color(0xFF850909);
const Color pupRedDarker = Color(0xFF4A0606);
// New color for tap feedback: a lighter, more transparent red
const Color pupRedLight = Color(0x66FF0000); // 40% opaque red
const Color whiteText = Colors.white;

class NavigationDrawerGuest extends StatelessWidget {
  const NavigationDrawerGuest({super.key});

  // --- Drawer Item Widget ---
  Widget _buildDrawerItem(BuildContext context, {
    required String title,
    required String iconPath,
    required String routeName,
    bool isCurrent = false,
  }) {
    // 1. Define the action to be taken when tapped
    void handleTap() {
      // Handle navigation and close the drawer
      Navigator.pop(context); // Close the drawer
      if (!isCurrent) {
        // Use pushReplacementNamed to prevent stacking the same screens
        Navigator.pushReplacementNamed(context, routeName);
      }
    }

    return Material(
      color: isCurrent ? pupRedDark : Colors.transparent, // Highlight the current screen
      child: InkWell(
        // Use splashColor to define the light red color on tap
        splashColor: pupRedLight,
        onTap: handleTap,
        child: Container(
          // Ensure the InkWell covers the whole list item area
          padding: const EdgeInsets.symmetric(horizontal: 25.0, vertical: 10.0),
          child: Row(
            children: [
              Image.asset(
                iconPath,
                width: 40,
                height: 40,
                color: whiteText,
              ),
              const SizedBox(width: 20), // Add spacing between icon and text
              Text(
                title,
                style: const TextStyle(
                  color: whiteText,
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
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
    // Determine the current route name for highlighting logic
    final currentRoute = ModalRoute.of(context)?.settings.name;

    // Helper function to check if the route is current or a detail screen related to it
    bool isRouteCurrent(String routeName) {
      if (currentRoute == routeName) return true;

      // Handle detail screens like ViewEvent or ViewStall
      if (routeName == AppRoutes.events && currentRoute == AppRoutes.viewEvent) return true;

      return false;
    }

    return Drawer(
      width: MediaQuery.of(context).size.width * 0.75,
      backgroundColor: pupRedDarker,
      child: SafeArea(
        bottom: false,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.only(
                  top: 30, left: 20, right: 20, bottom: 25),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Image.asset(
                        'assets/images/pup_logo.png',
                        width: 40,
                        height: 40,
                      ),
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            "PUP Tour",
                            style: TextStyle(
                              color: whiteText,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            "Campus Navigation",
                            style: TextStyle(
                              color: whiteText,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const Padding(
                    padding: EdgeInsets.only(top: 15.0),
                    child: Divider(color: whiteText, thickness: 1),
                  ),
                ],
              ),
            ),

            // Menu Items
            _buildDrawerItem(
              context,
              title: 'Overview',
              iconPath: 'assets/icons/overview.png',
              routeName: AppRoutes.guestHome,
              isCurrent: isRouteCurrent(AppRoutes.guestHome),
            ),

            _buildDrawerItem(
              context,
              title: 'Campus Map',
              iconPath: 'assets/icons/mapicon_white.png',
              routeName: AppRoutes.guestCampusMap,
              isCurrent: isRouteCurrent(AppRoutes.guestCampusMap),
            ),

            _buildDrawerItem(
              context,
              title: 'Buildings Info',
              iconPath: 'assets/icons/building_iconinfo.png',
              routeName: AppRoutes.guestBuildings,
              isCurrent: isRouteCurrent(AppRoutes.guestBuildings),
            ),
            _buildDrawerItem(
              context,
              title: 'Events',
              iconPath: 'assets/icons/event.png',
              routeName: AppRoutes.guestEvents,
              isCurrent: isRouteCurrent(AppRoutes.guestEvents),
            ),

            _buildDrawerItem(
              context,
              title: 'Campus Craves',
              iconPath: 'assets/icons/food.png',
              routeName: AppRoutes.guestBazaars,
              isCurrent: isRouteCurrent(AppRoutes.guestBazaars),
            ),

            _buildDrawerItem(
              context,
              title: 'Profile',
              iconPath: 'assets/icons/profile.png',
              routeName: AppRoutes.guestProfile,
              isCurrent: isRouteCurrent(AppRoutes.guestProfile),
            ),

            _buildDrawerItem(
              context,
              title: 'Log Out',
              iconPath: 'assets/icons/logout.png',
              routeName: AppRoutes.login,
              isCurrent: false, // Log Out should never be current
            ),
          ],
        ),
      ),
    );
  }
}