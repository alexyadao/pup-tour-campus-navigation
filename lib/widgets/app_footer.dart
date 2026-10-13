import 'package:flutter/material.dart';

class AppFooter extends StatelessWidget {
  const AppFooter({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      // Add margin top to separate from content if needed
      margin: const EdgeInsets.only(top: 20), 
      padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
      decoration: const BoxDecoration(
        // MATCHING GRADIENT (Deep Maroon -> Darker)
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF8E0E00), // Deep Maroon
            Color(0xFF4a0000), // Darker/Blackish Maroon base
          ],
        ),
        // CURVED TOP CORNERS (Inverse of Header)
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, -5), // Shadow upwards
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // LOGO
              Container(
                width: 50,
                height: 50,
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Image.asset(
                  'assets/logo.png', // Using your consistent asset
                  fit: BoxFit.contain,
                  errorBuilder: (c, e, s) => const Icon(Icons.school, color: Color(0xFF8E0E00)),
                ),
              ),
              const SizedBox(width: 15),
              // TEXT
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "PUP Tour",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                  Text(
                    "Campus Navigation",
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 25),
          const Divider(color: Colors.white24, thickness: 1),
          const SizedBox(height: 15),
          const Text(
            "Polytechnic University of the Philippines\n© 2025 PUP Tour. All rights reserved.",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white60,
              fontSize: 11,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}