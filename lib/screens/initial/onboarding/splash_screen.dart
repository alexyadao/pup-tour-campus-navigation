import 'package:flutter/material.dart';
// REMOVED: import 'package:supabase_flutter/supabase_flutter.dart'; -> It was unused!
import '../../../routes/app_routes.dart';
import '../../../utils/onboarding_util.dart';
import '../../../../main.dart'; // This provides the 'supabase' variable we need

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAppStartup();
  }

  /// This function acts as the "Traffic Enforcer"
  Future<void> _checkAppStartup() async {
    // 1. REMOVED the artificial delay.
    // The app will now process this logic instantly.

    if (!mounted) return;

    // 2. CHECK: Is the user already logged in? (Session Check)
    // access 'supabase' from main.dart
    final session = supabase.auth.currentSession;

    if (session != null) {
      // --- USER IS LOGGED IN ---
      // We need to fetch their role to know WHICH home screen to send them to.
      // This usually takes milliseconds.
      await _redirectBasedOnRole(session.user.id);
    } else {
      // --- USER IS NOT LOGGED IN ---
      // 3. CHECK: Have they seen the onboarding before?
      final bool hasSeenOnboarding = await hasUserSeenOnboarding();

      if (mounted) {
        if (hasSeenOnboarding) {
          // They've seen intro before -> Go straight to Login
          Navigator.pushReplacementNamed(context, AppRoutes.guestHome);
        } else {
          // Brand new user -> Show Onboarding
          Navigator.pushReplacementNamed(context, AppRoutes.onboarding1);
        }
      }
    }
  }

  /// Helper to fetch role and navigate (Logic borrowed from your Login.dart)
  Future<void> _redirectBasedOnRole(String userId) async {
    try {
      final Map<String, dynamic> data = await supabase
          .from('users')
          .select('role_id')
          .eq('user_id', userId)
          .single();

      final int roleId = data['role_id'];

      if (mounted) {
        // UPDATED LOGIC: Removed explicit check for roleId 1.
        // Role ID 2 (Guest/General) goes to Home.
        // Legacy Role ID 1 will fall through to 'else' and also go to Home.
        if (roleId == 2) {
          Navigator.pushReplacementNamed(context, AppRoutes.home);
        } else if (roleId == 3) {
          Navigator.pushReplacementNamed(context, AppRoutes.admin); // Admin
        } else {
          // Fallback (includes legacy roleId 1 or unknown roles)
          Navigator.pushReplacementNamed(context, AppRoutes.home);
        }
      }
    } catch (e) {
      // If there's an error (e.g., internet issue fetching role),
      // safe fallback is the Login screen.
      if (mounted) {
        Navigator.pushReplacementNamed(context, AppRoutes.login);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Image
          Positioned.fill(
            child: Image.asset(
              "assets/images/splash_bg.png",
              fit: BoxFit.cover,
            ),
          ),

          // Dark Red Overlay
          Positioned.fill(
            child: Container(
              // 'withOpacity' is the standard way to set alpha.
              color: Colors.black.withValues(alpha: 0.45),
            ),
          ),

          // Logo
          Center(
            child: Image.asset(
              "assets/images/pup_logo.png",
              width: 180,
              height: 180,
              fit: BoxFit.contain,
            ),
          ),

          // REMOVED: The Loading Indicator (Spinner)
          // The screen will now be static and clean for the split second it takes to load.
        ],
      ),
    );
  }
}
