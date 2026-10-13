import 'package:flutter/material.dart';
import '../../../routes/app_routes.dart';
import '../../../widgets/onboarding_template.dart';
import '../../../utils/onboarding_util.dart'; // <<< NEW IMPORT

class Intro1 extends StatelessWidget {
  const Intro1({super.key});

  @override
  Widget build(BuildContext context) {
    return OnboardingTemplate(
      title: "Navigate PUP with ease",
      subtitle:
      "Explore an interactive 3D campus map with all\n"
          "buildings, facilities, and points of interest",
      imagePath: "assets/images/onboarding1.png",
      buttonText: "Next",
      onSkip: () async { // <<< ADDED ASYNC
        await completeOnboarding(); // <<< SET FLAG
        Navigator.pushReplacementNamed(context, AppRoutes.login);
      },
      onNext: () => Navigator.pushNamed(context, AppRoutes.onboarding2),
    );
  }
}