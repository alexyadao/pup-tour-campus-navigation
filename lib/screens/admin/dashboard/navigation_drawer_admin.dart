import 'package:flutter/material.dart';
import 'package:puptourapp/routes/app_routes.dart';

// --- Style Constants ---
const Color pupRedDark = Color(0xFF850909);
const Color pupRedDarker = Color(0xFF4A0606);
const Color pupRedLight = Color(0x66FF0000);
const Color whiteText = Colors.white;

class NavigationDrawerAdmin extends StatelessWidget {
  final VoidCallback? onSignOut; // <-- ADDED

  const NavigationDrawerAdmin({super.key, this.onSignOut}); // <-- ADDED

  // --- Drawer Item Widget ---
  Widget _buildDrawerItem(
      BuildContext context, {
        required String title,
        required String iconPath,
        required String routeName,
        bool isCurrent = false,
      }) {
    void handleTap() {
      Navigator.pop(context);
      if (!isCurrent) {
        Navigator.pushReplacementNamed(context, routeName);
      }
    }

    return Material(
      color: isCurrent ? pupRedDark : Colors.transparent,
      child: InkWell(
        splashColor: pupRedLight,
        onTap: handleTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 12.0),
          child: Row(
            children: [
              Image.asset(iconPath, width: 36, height: 36, color: whiteText),
              const SizedBox(width: 10),
              Text(
                title,
                style: const TextStyle(
                  color: whiteText,
                  fontSize: 17,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- Sign Out Drawer Item ---
  Widget _buildSignOutItem(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        splashColor: pupRedLight,
        onTap: () {
          Navigator.pop(context);
          onSignOut?.call(); // <-- CALL SIGN OUT FUNCTION
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25.0, vertical: 12.0),
          child: Row(
            children: const [
              Icon(Icons.logout, color: whiteText, size: 30),
              SizedBox(width: 18),
              Text(
                'Sign Out',
                style: TextStyle(
                  color: whiteText,
                  fontSize: 17,
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
    final currentRoute = ModalRoute.of(context)?.settings.name;

    bool isRouteCurrent(String routeName) {
      return currentRoute == routeName;
    }

    return Drawer(
      width: MediaQuery.of(context).size.width * 0.75,
      backgroundColor: pupRedDarker,

      child: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Drawer Header
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 30, 20, 20),
                child: Row(
                  children: [
                    Image.asset('assets/images/pup_logo.png', width: 45, height: 45),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          "PUP Tour",
                          style: TextStyle(
                            color: whiteText,
                            fontSize: 19,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          "Campus Navigation",
                          style: TextStyle(
                            color: whiteText,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const Divider(color: whiteText, thickness: 1),

              // Drawer Items
              _buildDrawerItem(
                context,
                title: 'Dashboard',
                iconPath: 'assets/admin_icons/dashboard.png',
                routeName: AppRoutes.admin,
                isCurrent: isRouteCurrent(AppRoutes.admin),
              ),

              _buildDrawerItem(
                context,
                title: 'User Account',
                iconPath: 'assets/admin_icons/userAccount.png',
                routeName: AppRoutes.adminUser,
                isCurrent: isRouteCurrent(AppRoutes.adminUser),
              ),

              _buildDrawerItem(
                context,
                title: 'Buildings',
                iconPath: 'assets/admin_icons/buildings.png',
                routeName: AppRoutes.adminBuildings,
                isCurrent: isRouteCurrent(AppRoutes.adminBuildings),
              ),

              _buildDrawerItem(
                context,
                title: 'Events',
                iconPath: 'assets/admin_icons/events.png',
                routeName: AppRoutes.adminEvents,
                isCurrent: isRouteCurrent(AppRoutes.adminEvents),
              ),


              _buildDrawerItem(
                context,
                title: 'Map Management',
                iconPath: 'assets/admin_icons/save.png',
                routeName: AppRoutes.adminSavelocations,
                isCurrent: isRouteCurrent(AppRoutes.adminSavelocations),
              ),

              _buildDrawerItem(
                context,
                title: 'Feedback Management',
                iconPath: 'assets/admin_icons/review.png',
                routeName: AppRoutes.adminFeedbacks,
                isCurrent: isRouteCurrent(AppRoutes.adminFeedbacks),
              ),

              const SizedBox(height: 20),

              const Divider(color: whiteText, thickness: 1),

              // SIGN OUT
              _buildSignOutItem(context),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
