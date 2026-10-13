import 'package:flutter/material.dart';
import '../../../routes/app_routes.dart';
import '../../../widgets/onboarding_template.dart';
import '../../../utils/onboarding_util.dart'; // <<< NEW IMPORT

class Intro2 extends StatelessWidget {
  const Intro2({super.key});

  @override
  Widget build(BuildContext context) {
    return OnboardingTemplate(
      title: "Find buildings, rooms, and facilities instantly",
      subtitle:
      "Use GPS and real-time location tracking to \n"
          "navigate the campus like a pro.",
      imagePath: "assets/images/onboarding2.png",
      buttonText: "Next",
      onSkip: () async { // <<< ADDED ASYNC
        await completeOnboarding(); // <<< SET FLAG
        Navigator.pushReplacementNamed(context, AppRoutes.login);
      },
      onNext: () => Navigator.pushNamed(context, AppRoutes.onboarding3),
    );
  }
}