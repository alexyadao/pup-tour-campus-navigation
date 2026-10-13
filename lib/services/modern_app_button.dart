import 'package:flutter/material.dart';
import 'dart:ui'; // Required for ImageFilter

class ModernAppButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final bool isMenuButton;

  const ModernAppButton({
    super.key, 
    required this.icon, 
    required this.onPressed,
    this.isMenuButton = false, // Defaults to false (Back Button)
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      // ClipRRect creates the rounded corners for the blur effect
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15.0), // Soft rounded corners
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0), // Glass blur
          child: Container(
            width: 45, // Fixed size for consistency
            height: 45,
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.4), // Semi-transparent dark
              borderRadius: BorderRadius.circular(15.0),
              border: Border.all(
                color: Colors.white.withOpacity(0.2), // Subtle glass border
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: IconButton(
              padding: EdgeInsets.zero, // Remove default padding
              icon: Icon(
                icon,
                color: Colors.white,
                size: 22,
              ),
              onPressed: onPressed,
              tooltip: isMenuButton ? 'Open Menu' : 'Go Back',
            ),
          ),
        ),
      ),
    );
  }
}