import 'package:shared_preferences/shared_preferences.dart';

/// Sets the flag to TRUE so onboarding doesn't show again.
Future<void> completeOnboarding() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setBool('hasSeenOnboarding', true);
  // print('ONBOARDING_DEBUG: hasSeenOnboarding flag set to true.');
}

/// Checks if the user has already finished the onboarding.
/// Returns TRUE if they have, FALSE if they are new.
Future<bool> hasUserSeenOnboarding() async {
  final prefs = await SharedPreferences.getInstance();
  // Return the value, or 'false' if it doesn't exist yet
  return prefs.getBool('hasSeenOnboarding') ?? false;
}