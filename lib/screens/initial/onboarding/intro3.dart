import 'package:flutter/material.dart';
import '../../../utils/onboarding_util.dart'; // <<< NEW IMPORT
import '../../../routes/app_routes.dart'; // <<< ADDED IMPORT for routing

class Intro3 extends StatelessWidget {
  const Intro3({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              Center(
                child: Image.asset(
                  'assets/images/onboarding3.png',
                  width: 260,
                  height: 260,
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(height: 40),
              Text(
                'Learn every story behind the university',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 30),
              Text(
                'Take guided tours and discover campus trivia,\n'
                    'history, and hidden gems.',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  // <<< UPDATED LOGIC AND ASYNC >>>
                  onPressed: () async {
                    await completeOnboarding(); // <<< SET FLAG
                    Navigator.pushReplacementNamed(context, AppRoutes.login); // <<< Use AppRoutes.login
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFAA0000),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Get Started',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}