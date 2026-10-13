import 'dart:ui';
import 'package:flutter/material.dart';

class GlassCard extends StatelessWidget {
  final Widget child;
  final double? width;
  final double? height;
  final double borderRadius;
  final double blurStrength;

  const GlassCard({
    super.key,
    required this.child,
    this.width,
    this.height,
    this.borderRadius = 24.0, // Updated to match your curved design
    this.blurStrength = 15.0,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: SizedBox(
        width: width,
        height: height,
        child: Stack(
          children: [
            // 1. The Blur Effect
            BackdropFilter(
              filter: ImageFilter.blur(
                sigmaX: blurStrength,
                sigmaY: blurStrength,
              ),
              child: Container(color: Colors.transparent),
            ),

            // 2. The Gradient Surface & Border
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(borderRadius),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.3), // Glass edge
                  width: 1.5,
                ),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.white.withValues(alpha: 0.7), // Shiny top-left
                    Colors.white.withValues(alpha: 0.4), // See-through bottom-right
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
            ),

            // 3. The Content
            child,
          ],
        ),
      ),
    );
  }
}